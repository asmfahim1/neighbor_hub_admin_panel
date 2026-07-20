import '../../../../core/utils/result.dart';
import '../entity/profile_entity.dart';

abstract class ProfileRepository {
  Future<Result<List<ProfileEntity>>> getProfileData();
}
