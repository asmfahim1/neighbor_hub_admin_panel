import '../../../../core/utils/result.dart';
import '../entity/profile_entity.dart';
import '../repository/profile_repository.dart';
import 'package:injectable/injectable.dart';


@injectable

class ProfileUseCase {
  ProfileUseCase(this._repo);

  final ProfileRepository _repo;

  Future<Result<List<ProfileEntity>>> call() {
    return _repo.getProfileData();
  }
}
