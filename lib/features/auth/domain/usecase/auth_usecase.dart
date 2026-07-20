import '../../../../core/utils/result.dart';
import '../entity/auth_entity.dart';
import '../repository/auth_repository.dart';
import 'package:injectable/injectable.dart';


@injectable

class AuthUseCase {
  AuthUseCase(this._repo);

  final AuthRepository _repo;

  Future<Result<List<AuthEntity>>> call() {
    return _repo.getAuthData();
  }
}
