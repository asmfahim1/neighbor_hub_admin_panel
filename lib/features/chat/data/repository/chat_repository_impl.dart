import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/response_handler/api_failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entity/chat_entity.dart';
import '../../domain/repository/chat_repository.dart';
import '../source/chat_remote_source.dart';

@LazySingleton(as: ChatRepository)
class ChatRepositoryImpl implements ChatRepository {
  ChatRepositoryImpl(this._remote);

  final ChatRemoteSource _remote;

  @override
  Stream<List<ConversationEntity>> watchConversations(String myUid) =>
      _remote.watchConversations(myUid);

  @override
  Stream<List<MessageEntity>> watchMessages(String conversationId) =>
      _remote.watchMessages(conversationId);

  @override
  Future<Result<String>> startOrResumeConversation({
    required String buildingId,
    required String myUid,
    required String otherUid,
  }) async {
    try {
      final id = await _remote.startOrResumeConversation(
        buildingId: buildingId,
        myUid: myUid,
        otherUid: otherUid,
      );
      return Right(id);
    } catch (e, stack) {
      return Left(AppFailure.fromException(e, stack));
    }
  }

  @override
  Future<Result<void>> sendMessage({
    required String conversationId,
    required String senderUid,
    required String recipientUid,
    required String buildingId,
    required String text,
  }) async {
    try {
      await _remote.sendMessage(
        conversationId: conversationId,
        senderUid: senderUid,
        recipientUid: recipientUid,
        buildingId: buildingId,
        text: text,
      );
      return const Right(null);
    } catch (e, stack) {
      return Left(AppFailure.fromException(e, stack));
    }
  }
}
