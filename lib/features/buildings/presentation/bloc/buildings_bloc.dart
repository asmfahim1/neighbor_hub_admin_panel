import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecase/buildings_usecase.dart';
import 'buildings_event.dart';
import 'buildings_state.dart';

class BuildingsBloc extends Bloc<BuildingsEvent, BuildingsState> {
  BuildingsBloc(this._useCase) : super(const BuildingsState()) {
    on<LoadBuildings>(_onLoad);
    add(const LoadBuildings());
  }

  final BuildingsUseCase _useCase;

  Future<void> _onLoad(
    LoadBuildings event,
    Emitter<BuildingsState> emit,
  ) async {
    emit(state.copyWith(status: BuildingsStatus.loading));
    final result = await _useCase();
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: BuildingsStatus.failure,
          message: failure.message,
        ),
      ),
      (data) => emit(
        state.copyWith(
          status: BuildingsStatus.success,
          items: data,
        ),
      ),
    );
  }
}
