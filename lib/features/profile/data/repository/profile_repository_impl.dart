import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/firebase/current_session.dart';
import '../../../../core/response_handler/api_failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entity/profile_entity.dart';
import '../../domain/repository/profile_repository.dart';
import '../source/profile_remote_source.dart';

@LazySingleton(as: ProfileRepository)
class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._remote, this._session);

  final ProfileRemoteSource _remote;
  final CurrentSession _session;

  @override
  Stream<UserEntity?> watchOwnProfile(String uid) => _remote.watchOwnProfile(uid);

  @override
  Future<Result<void>> updateOwnProfile(
    String uid, {
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      await _remote.updateOwnProfile(uid, displayName: displayName, photoUrl: photoUrl);
      return const Right(null);
    } catch (e, stack) {
      return Left(AppFailure.fromException(e, stack));
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _remote.signOut();
      _session.clear();
      return const Right(null);
    } catch (e, stack) {
      return Left(AppFailure.fromException(e, stack));
    }
  }
}
