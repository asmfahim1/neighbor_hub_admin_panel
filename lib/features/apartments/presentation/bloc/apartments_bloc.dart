import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecase/apartments_usecase.dart';
import 'apartments_event.dart';
import 'apartments_state.dart';

class ApartmentsBloc extends Bloc<ApartmentsEvent, ApartmentsState> {
  ApartmentsBloc(this._useCase) : super(const ApartmentsState()) {
    on<LoadApartments>(_onLoad);
    add(const LoadApartments());
  }

  final ApartmentsUseCase _useCase;

  Future<void> _onLoad(
    LoadApartments event,
    Emitter<ApartmentsState> emit,
  ) async {
    emit(state.copyWith(status: ApartmentsStatus.loading));
    final result = await _useCase();
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: ApartmentsStatus.failure,
          message: failure.message,
        ),
      ),
      (data) => emit(
        state.copyWith(
          status: ApartmentsStatus.success,
          items: data,
        ),
      ),
    );
  }
}
