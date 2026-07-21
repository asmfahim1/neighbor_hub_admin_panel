import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/models/models.dart';
import '../../domain/usecase/chat_usecase.dart';
import 'chat_event.dart';
import 'chat_state.dart';

@injectable
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc(
    this._watchConversations,
    this._watchMessages,
    this._startOrResumeConversation,
    this._sendMessage,
  ) : super(const ChatState()) {
    on<ConversationsWatchStarted>(_onConversationsWatchStarted);
    on<ConversationsUpdated>(_onConversationsUpdated);
    on<ConversationOpened>(_onConversationOpened);
    on<ConversationClosed>(_onConversationClosed);
    on<MessagesUpdated>(_onMessagesUpdated);
    on<ConversationStartRequested>(_onConversationStartRequested);
    on<MessageSendRequested>(_onMessageSendRequested);
    on<ChatFailed>(_onFailed);
  }

  final WatchConversationsUseCase _watchConversations;
  final WatchMessagesUseCase _watchMessages;
  final StartOrResumeConversationUseCase _startOrResumeConversation;
  final SendMessageUseCase _sendMessage;

  StreamSubscription<List<ConversationEntity>>? _conversationsSubscription;
  StreamSubscription<List<MessageEntity>>? _messagesSubscription;

  Future<void> _onConversationsWatchStarted(
    ConversationsWatchStarted event,
    Emitter<ChatState> emit,
  ) async {
    emit(state.copyWith(status: ChatStatus.loading));
    await _conversationsSubscription?.cancel();
    _conversationsSubscription = _watchConversations(event.myUid).listen(
      (conversations) => add(ConversationsUpdated(conversations)),
      onError: (Object e) => add(ChatFailed(e.toString())),
    );
  }

  void _onConversationsUpdated(ConversationsUpdated event, Emitter<ChatState> emit) {
    emit(state.copyWith(status: ChatStatus.loaded, conversations: event.conversations));
  }

  Future<void> _onConversationOpened(
    ConversationOpened event,
    Emitter<ChatState> emit,
  ) async {
    emit(state.copyWith(openConversationId: event.conversationId, messages: const []));
    await _messagesSubscription?.cancel();
    _messagesSubscription = _watchMessages(event.conversationId).listen(
      (messages) => add(MessagesUpdated(messages)),
      onError: (Object e) => add(ChatFailed(e.toString())),
    );
  }

  Future<void> _onConversationClosed(
    ConversationClosed event,
    Emitter<ChatState> emit,
  ) async {
    await _messagesSubscription?.cancel();
    _messagesSubscription = null;
    emit(state.copyWith(clearOpenConversationId: true, messages: const []));
  }

  void _onMessagesUpdated(MessagesUpdated event, Emitter<ChatState> emit) {
    emit(state.copyWith(messages: event.messages));
  }

  Future<void> _onConversationStartRequested(
    ConversationStartRequested event,
    Emitter<ChatState> emit,
  ) async {
    emit(state.copyWith(status: ChatStatus.loading, clearMessage: true));
    final result = await _startOrResumeConversation(
      buildingId: event.buildingId,
      myUid: event.myUid,
      otherUid: event.otherUid,
    );
    result.fold(
      (failure) => emit(state.copyWith(status: ChatStatus.failure, message: failure.displayMessage)),
      (conversationId) => add(ConversationOpened(conversationId)),
    );
  }

  Future<void> _onMessageSendRequested(
    MessageSendRequested event,
    Emitter<ChatState> emit,
  ) async {
    emit(state.copyWith(status: ChatStatus.sending, clearMessage: true));
    final result = await _sendMessage(
      conversationId: event.conversationId,
      senderUid: event.senderUid,
      recipientUid: event.recipientUid,
      buildingId: event.buildingId,
      text: event.text,
    );
    result.fold(
      (failure) => emit(state.copyWith(status: ChatStatus.failure, message: failure.displayMessage)),
      // The realtime messages listener will follow shortly with the sent message.
      (_) => emit(state.copyWith(status: ChatStatus.loaded)),
    );
  }

  void _onFailed(ChatFailed event, Emitter<ChatState> emit) {
    emit(state.copyWith(status: ChatStatus.failure, message: event.message));
  }

  @override
  Future<void> close() async {
    await _conversationsSubscription?.cancel();
    await _messagesSubscription?.cancel();
    return super.close();
  }
}
