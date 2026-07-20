import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecase/chat_usecase.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc(this._useCase) : super(const ChatState()) {
    on<LoadChat>(_onLoad);
    add(const LoadChat());
  }

  final ChatUseCase _useCase;

  Future<void> _onLoad(
    LoadChat event,
    Emitter<ChatState> emit,
  ) async {
    emit(state.copyWith(status: ChatStatus.loading));
    final result = await _useCase();
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: ChatStatus.failure,
          message: failure.message,
        ),
      ),
      (data) => emit(
        state.copyWith(
          status: ChatStatus.success,
          items: data,
        ),
      ),
    );
  }
}
