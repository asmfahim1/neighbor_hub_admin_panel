import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecase/analytics_usecase.dart';
import 'analytics_event.dart';
import 'analytics_state.dart';

class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  AnalyticsBloc(this._useCase) : super(const AnalyticsState()) {
    on<LoadAnalytics>(_onLoad);
    add(const LoadAnalytics());
  }

  final AnalyticsUseCase _useCase;

  Future<void> _onLoad(
    LoadAnalytics event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(state.copyWith(status: AnalyticsStatus.loading));
    final result = await _useCase();
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: AnalyticsStatus.failure,
          message: failure.message,
        ),
      ),
      (data) => emit(
        state.copyWith(
          status: AnalyticsStatus.success,
          items: data,
        ),
      ),
    );
  }
}
