import 'package:injectable/injectable.dart';

import '../../../../core/utils/result.dart';
import '../entity/chat_entity.dart';
import '../repository/chat_repository.dart';

@injectable
class WatchConversationsUseCase {
  WatchConversationsUseCase(this._repo);
  final ChatRepository _repo;

  Stream<List<ConversationEntity>> call(String myUid) => _repo.watchConversations(myUid);
}

@injectable
class WatchMessagesUseCase {
  WatchMessagesUseCase(this._repo);
  final ChatRepository _repo;

  Stream<List<MessageEntity>> call(String conversationId) => _repo.watchMessages(conversationId);
}

@injectable
class StartOrResumeConversationUseCase {
  StartOrResumeConversationUseCase(this._repo);
  final ChatRepository _repo;

  Future<Result<String>> call({
    required String buildingId,
    required String myUid,
    required String otherUid,
  }) {
    return _repo.startOrResumeConversation(buildingId: buildingId, myUid: myUid, otherUid: otherUid);
  }
}

@injectable
class SendMessageUseCase {
  SendMessageUseCase(this._repo);
  final ChatRepository _repo;

  Future<Result<void>> call({
    required String conversationId,
    required String senderUid,
    required String recipientUid,
    required String buildingId,
    required String text,
  }) {
    return _repo.sendMessage(
      conversationId: conversationId,
      senderUid: senderUid,
      recipientUid: recipientUid,
      buildingId: buildingId,
      text: text,
    );
  }
}
