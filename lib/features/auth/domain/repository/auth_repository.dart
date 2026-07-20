import '../../../../core/utils/result.dart';
import '../entity/auth_entity.dart';

abstract class AuthRepository {
  Future<Result<List<AuthEntity>>> getAuthData();
}
