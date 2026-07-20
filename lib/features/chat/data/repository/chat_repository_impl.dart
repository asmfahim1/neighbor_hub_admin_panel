import '../../../../core/response_handler/api_failure.dart';
import '../../../../core/utils/result.dart';
import 'package:dartz/dartz.dart';
import '../../domain/entity/chat_entity.dart';
import '../../domain/repository/chat_repository.dart';
// import '../model/chat_model.dart';
import '../source/chat_remote_source.dart';
import 'package:injectable/injectable.dart';


@LazySingleton(as: ChatRepository)

class ChatRepositoryImpl implements ChatRepository {
  ChatRepositoryImpl(this._remote);

  final ChatRemoteSource _remote;

  @override
  Future<Result<List<ChatEntity>>> getChatData() async {
    try {
      final models = await _remote.fetchData();
      final entities = models.map((e) => e.toEntity()).toList();
      return Right(entities);
    } catch (e, stack) {
      return Left(AppFailure.fromException(e, stack));
    }
  }
}
