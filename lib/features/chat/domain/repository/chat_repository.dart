import '../../../../core/utils/result.dart';
import '../entity/chat_entity.dart';

abstract class ChatRepository {
  Future<Result<List<ChatEntity>>> getChatData();
}
