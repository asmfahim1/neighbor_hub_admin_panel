import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecase/dashboard_usecase.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc(this._useCase) : super(const DashboardState()) {
    on<LoadDashboard>(_onLoad);
    add(const LoadDashboard());
  }

  final DashboardUseCase _useCase;

  Future<void> _onLoad(
    LoadDashboard event,
    Emitter<DashboardState> emit,
  ) async {
    emit(state.copyWith(status: DashboardStatus.loading));
    final result = await _useCase();
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: DashboardStatus.failure,
          message: failure.message,
        ),
      ),
      (data) => emit(
        state.copyWith(
          status: DashboardStatus.success,
          items: data,
        ),
      ),
    );
  }
}
