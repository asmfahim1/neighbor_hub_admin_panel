import '../../../../core/utils/result.dart';
import '../entity/moderation_entity.dart';
import '../repository/moderation_repository.dart';
import 'package:injectable/injectable.dart';


@injectable

class ModerationUseCase {
  ModerationUseCase(this._repo);

  final ModerationRepository _repo;

  Future<Result<List<ModerationEntity>>> call() {
    return _repo.getModerationData();
  }
}
