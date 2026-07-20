import 'package:injectable/injectable.dart';

import '../../../../core/utils/result.dart';
import '../entity/profile_entity.dart';
import '../repository/profile_repository.dart';

@injectable
class WatchOwnProfileUseCase {
  WatchOwnProfileUseCase(this._repo);
  final ProfileRepository _repo;

  Stream<UserEntity?> call(String uid) => _repo.watchOwnProfile(uid);
}

@injectable
class UpdateOwnProfileUseCase {
  UpdateOwnProfileUseCase(this._repo);
  final ProfileRepository _repo;

  Future<Result<void>> call(String uid, {String? displayName, String? photoUrl}) =>
      _repo.updateOwnProfile(uid, displayName: displayName, photoUrl: photoUrl);
}

@injectable
class ProfileSignOutUseCase {
  ProfileSignOutUseCase(this._repo);
  final ProfileRepository _repo;

  Future<Result<void>> call() => _repo.signOut();
}
