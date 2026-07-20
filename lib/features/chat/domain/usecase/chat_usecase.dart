import '../../../../core/utils/result.dart';
import '../entity/chat_entity.dart';
import '../repository/chat_repository.dart';
import 'package:injectable/injectable.dart';


@injectable

class ChatUseCase {
  ChatUseCase(this._repo);

  final ChatRepository _repo;

  Future<Result<List<ChatEntity>>> call() {
    return _repo.getChatData();
  }
}
