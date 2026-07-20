import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecase/residents_usecase.dart';
import 'residents_event.dart';
import 'residents_state.dart';

class ResidentsBloc extends Bloc<ResidentsEvent, ResidentsState> {
  ResidentsBloc(this._useCase) : super(const ResidentsState()) {
    on<LoadResidents>(_onLoad);
    add(const LoadResidents());
  }

  final ResidentsUseCase _useCase;

  Future<void> _onLoad(
    LoadResidents event,
    Emitter<ResidentsState> emit,
  ) async {
    emit(state.copyWith(status: ResidentsStatus.loading));
    final result = await _useCase();
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: ResidentsStatus.failure,
          message: failure.message,
        ),
      ),
      (data) => emit(
        state.copyWith(
          status: ResidentsStatus.success,
          items: data,
        ),
      ),
    );
  }
}
