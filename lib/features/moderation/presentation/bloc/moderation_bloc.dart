import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecase/moderation_usecase.dart';
import 'moderation_event.dart';
import 'moderation_state.dart';

class ModerationBloc extends Bloc<ModerationEvent, ModerationState> {
  ModerationBloc(this._useCase) : super(const ModerationState()) {
    on<LoadModeration>(_onLoad);
    add(const LoadModeration());
  }

  final ModerationUseCase _useCase;

  Future<void> _onLoad(
    LoadModeration event,
    Emitter<ModerationState> emit,
  ) async {
    emit(state.copyWith(status: ModerationStatus.loading));
    final result = await _useCase();
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: ModerationStatus.failure,
          message: failure.message,
        ),
      ),
      (data) => emit(
        state.copyWith(
          status: ModerationStatus.success,
          items: data,
        ),
      ),
    );
  }
}
