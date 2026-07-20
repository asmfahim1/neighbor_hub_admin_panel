import 'package:injectable/injectable.dart';

import '../../../../core/constants/apartment_status.dart';
import '../../../../core/firebase/firestore_collections.dart';
import '../../../../core/firebase/firestore_service.dart';
import '../../../../core/models/user_entity.dart';
import '../../domain/entity/apartments_entity.dart';

/// The swappable "endpoint" boundary for the Apartments feature. A future
/// custom backend adds `ApartmentsApiSource implements ApartmentsRemoteSource`
/// and flips the DI binding — nothing in `domain/` or `data/repository` changes.
abstract class ApartmentsRemoteSource {
  Stream<List<ApartmentEntity>> watchApartments(String buildingId);
  Future<void> createApartment(ApartmentEntity apartment);
  Future<void> updateApartment(ApartmentEntity apartment);
  Future<void> deleteApartment(String apartmentId);
  Future<void> updateStatus(String apartmentId, ApartmentStatus status);
  Future<UserEntity?> fetchUser(String uid);
}

@LazySingleton(as: ApartmentsRemoteSource)
class ApartmentsFirestoreSource implements ApartmentsRemoteSource {
  ApartmentsFirestoreSource(this._firestore);

  final FirestoreService _firestore;

  @override
  Stream<List<ApartmentEntity>> watchApartments(String buildingId) {
    final query = _firestore.buildingScoped(FirestoreCollections.apartments, buildingId);
    return _firestore.watchQuery(query).map(
          (snapshot) => snapshot.docs
              .map((doc) => ApartmentEntity.fromJson(doc.data(), id: doc.id))
              .toList(),
        );
  }

  @override
  Future<void> createApartment(ApartmentEntity apartment) async {
    await _firestore.addDocument(FirestoreCollections.apartments, apartment.toJson());
  }

  @override
  Future<void> updateApartment(ApartmentEntity apartment) async {
    await _firestore.updateDocument(FirestorePaths.apartment(apartment.id), apartment.toJson());
  }

  @override
  Future<void> deleteApartment(String apartmentId) async {
    await _firestore.deleteDocument(FirestorePaths.apartment(apartmentId));
  }

  @override
  Future<void> updateStatus(String apartmentId, ApartmentStatus status) async {
    await _firestore.updateDocument(FirestorePaths.apartment(apartmentId), {
      'status': status.value,
      'updatedAt': _firestore.serverTimestamp,
    });
  }

  @override
  Future<UserEntity?> fetchUser(String uid) async {
    final snapshot = await _firestore.getDocument(FirestorePaths.user(uid));
    final data = snapshot.data();
    if (!snapshot.exists || data == null) return null;
    return UserEntity.fromJson(data, uid: uid);
  }
}
