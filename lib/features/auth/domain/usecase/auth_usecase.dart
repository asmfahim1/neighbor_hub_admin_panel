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
class SignUpAsAdminUseCase {
  SignUpAsAdminUseCase(this._repo);
  final AuthRepository _repo;

  Future<Result<AuthSessionEntity>> call({
    required String buildingName,
    required String buildingAddress,
    required String displayName,
    required String email,
    required String password,
  }) {
    return _repo.signUpAsAdmin(
      buildingName: buildingName,
      buildingAddress: buildingAddress,
      displayName: displayName,
      email: email,
      password: password,
    );
  }
}

@injectable
class SignUpAsAdminWithGoogleUseCase {
  SignUpAsAdminWithGoogleUseCase(this._repo);
  final AuthRepository _repo;

  Future<Result<AuthSessionEntity>> call({
    required String buildingName,
    required String buildingAddress,
  }) {
    return _repo.signUpAsAdminWithGoogle(
      buildingName: buildingName,
      buildingAddress: buildingAddress,
    );
  }
}

@injectable
class SignUpAsAdminWithAppleUseCase {
  SignUpAsAdminWithAppleUseCase(this._repo);
  final AuthRepository _repo;

  Future<Result<AuthSessionEntity>> call({
    required String buildingName,
    required String buildingAddress,
  }) {
    return _repo.signUpAsAdminWithApple(
      buildingName: buildingName,
      buildingAddress: buildingAddress,
    );
  }
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
