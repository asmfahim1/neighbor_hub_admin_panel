import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/utils/result.dart';
import '../../domain/entity/residents_entity.dart';
import '../../domain/usecase/residents_usecase.dart';
import 'residents_event.dart';
import 'residents_state.dart';

@injectable
class ResidentsBloc extends Bloc<ResidentsEvent, ResidentsState> {
  ResidentsBloc(
    this._watchPendingRequests,
    this._approveRequest,
    this._rejectRequest,
    this._watchResidentDirectory,
    this._getResident,
    this._getResidentActivitySummary,
    this._removeResident,
    this._transferAdminRole,
  ) : super(const ResidentsState()) {
    on<PendingRequestsWatchStarted>(_onPendingRequestsWatchStarted);
    on<PendingRequestsUpdated>(_onPendingRequestsUpdated);
    on<RequestApproveRequested>(_onApproveRequested);
    on<RequestRejectRequested>(_onRejectRequested);
    on<DirectoryWatchStarted>(_onDirectoryWatchStarted);
    on<DirectoryUpdated>(_onDirectoryUpdated);
    on<ResidentDetailRequested>(_onDetailRequested);
    on<ResidentRemoveRequested>(_onRemoveRequested);
    on<TransferAdminRoleRequested>(_onTransferRequested);
    on<ResidentsFailed>(_onFailed);
  }

  final WatchPendingRequestsUseCase _watchPendingRequests;
  final ApproveRequestUseCase _approveRequest;
  final RejectRequestUseCase _rejectRequest;
  final WatchResidentDirectoryUseCase _watchResidentDirectory;
  final GetResidentUseCase _getResident;
  final GetResidentActivitySummaryUseCase _getResidentActivitySummary;
  final RemoveResidentUseCase _removeResident;
  final TransferAdminRoleUseCase _transferAdminRole;

  StreamSubscription<List<ApartmentRequestEntity>>? _pendingRequestsSubscription;
  StreamSubscription<List<UserEntity>>? _directorySubscription;

  Future<void> _onPendingRequestsWatchStarted(
    PendingRequestsWatchStarted event,
    Emitter<ResidentsState> emit,
  ) async {
    emit(state.copyWith(status: ResidentsStatus.loading));
    await _pendingRequestsSubscription?.cancel();
    _pendingRequestsSubscription = _watchPendingRequests(event.buildingId).listen(
      (requests) => add(PendingRequestsUpdated(requests)),
      onError: (Object e) => add(ResidentsFailed(e.toString())),
    );
  }

  void _onPendingRequestsUpdated(PendingRequestsUpdated event, Emitter<ResidentsState> emit) {
    emit(state.copyWith(status: ResidentsStatus.loaded, pendingRequests: event.requests));
  }

  Future<void> _onApproveRequested(
    RequestApproveRequested event,
    Emitter<ResidentsState> emit,
  ) async {
    emit(state.copyWith(status: ResidentsStatus.mutating, clearMessage: true));
    final result = await _approveRequest(request: event.request, adminUid: event.adminUid);
    _emitMutationResult(result, emit);
  }

  Future<void> _onRejectRequested(
    RequestRejectRequested event,
    Emitter<ResidentsState> emit,
  ) async {
    emit(state.copyWith(status: ResidentsStatus.mutating, clearMessage: true));
    final result = await _rejectRequest(request: event.request, adminUid: event.adminUid);
    _emitMutationResult(result, emit);
  }

  Future<void> _onDirectoryWatchStarted(
    DirectoryWatchStarted event,
    Emitter<ResidentsState> emit,
  ) async {
    emit(state.copyWith(status: ResidentsStatus.loading));
    await _directorySubscription?.cancel();
    _directorySubscription = _watchResidentDirectory(event.buildingId).listen(
      (residents) => add(DirectoryUpdated(residents)),
      onError: (Object e) => add(ResidentsFailed(e.toString())),
    );
  }

  void _onDirectoryUpdated(DirectoryUpdated event, Emitter<ResidentsState> emit) {
    emit(state.copyWith(status: ResidentsStatus.loaded, directory: event.residents));
  }

  Future<void> _onDetailRequested(
    ResidentDetailRequested event,
    Emitter<ResidentsState> emit,
  ) async {
    emit(state.copyWith(status: ResidentsStatus.loading, clearMessage: true));
    final residentResult = await _getResident(event.uid);
    final activityResult = await _getResidentActivitySummary(
      buildingId: event.buildingId,
      uid: event.uid,
    );

    final resident = residentResult.fold((_) => null, (value) => value);
    final activity = activityResult.fold((_) => null, (value) => value);

    final failure = residentResult.fold((f) => f, (_) => null) ??
        activityResult.fold((f) => f, (_) => null);

    if (failure != null) {
      emit(state.copyWith(status: ResidentsStatus.failure, message: failure.displayMessage));
      return;
    }

    emit(state.copyWith(
      status: ResidentsStatus.loaded,
      selectedResident: resident,
      selectedResidentActivity: activity,
    ));
  }

  Future<void> _onRemoveRequested(
    ResidentRemoveRequested event,
    Emitter<ResidentsState> emit,
  ) async {
    emit(state.copyWith(status: ResidentsStatus.mutating, clearMessage: true));
    final result = await _removeResident(uid: event.uid, apartmentId: event.apartmentId);
    _emitMutationResult(result, emit);
  }

  Future<void> _onTransferRequested(
    TransferAdminRoleRequested event,
    Emitter<ResidentsState> emit,
  ) async {
    emit(state.copyWith(status: ResidentsStatus.mutating, clearMessage: true));
    final result = await _transferAdminRole(
      buildingId: event.buildingId,
      currentAdminUid: event.currentAdminUid,
      successorUid: event.successorUid,
    );
    _emitMutationResult(result, emit);
  }

  void _onFailed(ResidentsFailed event, Emitter<ResidentsState> emit) {
    emit(state.copyWith(status: ResidentsStatus.failure, message: event.message));
  }

  void _emitMutationResult(Result<void> result, Emitter<ResidentsState> emit) {
    result.fold(
      (failure) => emit(state.copyWith(status: ResidentsStatus.failure, message: failure.displayMessage)),
      (_) => emit(state.copyWith(status: ResidentsStatus.loaded)),
    );
  }

  @override
  Future<void> close() async {
    await _pendingRequestsSubscription?.cancel();
    await _directorySubscription?.cancel();
    return super.close();
  }
}
