import 'package:injectable/injectable.dart';

import '../../../../core/firebase/firebase_auth_service.dart';
import '../../../../core/firebase/firestore_collections.dart';
import '../../../../core/firebase/firestore_service.dart';
import '../../../../core/models/user_entity.dart';
import '../../../../core/models/user_model.dart';

/// The swappable "endpoint" boundary for the Profile feature. A future
/// custom backend adds `ProfileApiSource implements ProfileRemoteSource` and
/// flips the DI binding — nothing in `domain/` or `data/repository` changes.
///
/// Deliberately does NOT depend on the Auth feature's `domain`/`data` layers
/// (illegal cross-feature coupling) — it injects `FirebaseAuthService`
/// directly for sign-out, exactly like `AuthFirestoreSource` does.
abstract class ProfileRemoteSource {
  Stream<UserEntity?> watchOwnProfile(String uid);

  Future<void> updateOwnProfile(
    String uid, {
    String? displayName,
    String? photoUrl,
  });

  Future<void> signOut();
}

@LazySingleton(as: ProfileRemoteSource)
class ProfileFirestoreSource implements ProfileRemoteSource {
  ProfileFirestoreSource(this._firestore, this._auth);

  final FirestoreService _firestore;
  final FirebaseAuthService _auth;

  @override
  Stream<UserEntity?> watchOwnProfile(String uid) {
    return _firestore.watchDocument(FirestorePaths.user(uid)).map((snapshot) {
      final data = snapshot.data();
      if (!snapshot.exists || data == null) return null;
      return UserModel.fromJson(data, uid: uid);
    });
  }

  @override
  Future<void> updateOwnProfile(
    String uid, {
    String? displayName,
    String? photoUrl,
  }) async {
    final updates = <String, dynamic>{
      if (displayName != null) 'displayName': displayName,
      if (photoUrl != null) 'photoUrl': photoUrl,
    };
    if (updates.isEmpty) return;
    await _firestore.updateDocument(FirestorePaths.user(uid), updates);
  }

  @override
  Future<void> signOut() async {
    final result = await _auth.signOut();
    result.fold((failure) => throw failure, (_) {});
  }
}
