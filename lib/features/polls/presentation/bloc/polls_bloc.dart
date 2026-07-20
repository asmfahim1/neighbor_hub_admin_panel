import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecase/polls_usecase.dart';
import 'polls_event.dart';
import 'polls_state.dart';

class PollsBloc extends Bloc<PollsEvent, PollsState> {
  PollsBloc(this._useCase) : super(const PollsState()) {
    on<LoadPolls>(_onLoad);
    add(const LoadPolls());
  }

  final PollsUseCase _useCase;

  Future<void> _onLoad(
    LoadPolls event,
    Emitter<PollsState> emit,
  ) async {
    emit(state.copyWith(status: PollsStatus.loading));
    final result = await _useCase();
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: PollsStatus.failure,
          message: failure.message,
        ),
      ),
      (data) => emit(
        state.copyWith(
          status: PollsStatus.success,
          items: data,
        ),
      ),
    );
  }
}
