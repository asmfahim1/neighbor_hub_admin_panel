import 'package:injectable/injectable.dart';

import '../../../../core/utils/result.dart';
import '../entity/auth_entity.dart';
import '../repository/auth_repository.dart';

@injectable
class WatchAuthStateUseCase {
  WatchAuthStateUseCase(this._repo);
  final AuthRepository _repo;

  Stream<AuthSessionEntity?> call() => _repo.watchAuthState();
}

@injectable
class SignInWithEmailUseCase {
  SignInWithEmailUseCase(this._repo);
  final AuthRepository _repo;

  Future<Result<AuthSessionEntity>> call(String email, String password) =>
      _repo.signInWithEmailAndPassword(email, password);
}

@injectable
class SignInWithGoogleUseCase {
  SignInWithGoogleUseCase(this._repo);
  final AuthRepository _repo;

  Future<Result<AuthSessionEntity>> call() => _repo.signInWithGoogle();
}

@injectable
class SignInWithAppleUseCase {
  SignInWithAppleUseCase(this._repo);
  final AuthRepository _repo;

  Future<Result<AuthSessionEntity>> call() => _repo.signInWithApple();
}

@injectable
class SendPasswordResetEmailUseCase {
  SendPasswordResetEmailUseCase(this._repo);
  final AuthRepository _repo;

  Future<Result<void>> call(String email) => _repo.sendPasswordResetEmail(email);
}

@injectable
class SignOutUseCase {
  SignOutUseCase(this._repo);
  final AuthRepository _repo;

  Future<Result<void>> call() => _repo.signOut();
}
