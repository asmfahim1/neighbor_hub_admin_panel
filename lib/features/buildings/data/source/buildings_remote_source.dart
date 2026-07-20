import 'package:injectable/injectable.dart';

import '../../../../core/constants/apartment_status.dart';
import '../../../../core/firebase/firestore_collections.dart';
import '../../../../core/firebase/firestore_service.dart';
import '../../domain/entity/buildings_entity.dart';

/// The swappable "endpoint" boundary for the Buildings feature. A future
/// custom backend adds `BuildingsApiSource implements BuildingsRemoteSource`
/// and flips the DI binding — nothing in `domain/` or `data/repository` changes.
abstract class BuildingsRemoteSource {
  Stream<BuildingEntity?> watchBuilding(String buildingId);
  Future<BuildingEntity?> fetchBuilding(String buildingId);
  Future<void> saveBuilding(BuildingEntity building);

  /// Returns the number of apartments actually created (after dedupe).
  Future<int> generateApartments({
    required String buildingId,
    required int totalFloors,
    required int apartmentsPerFloor,
  });
}

@LazySingleton(as: BuildingsRemoteSource)
class BuildingsFirestoreSource implements BuildingsRemoteSource {
  BuildingsFirestoreSource(this._firestore);

  final FirestoreService _firestore;

  @override
  Stream<BuildingEntity?> watchBuilding(String buildingId) {
    return _firestore.watchDocument(FirestorePaths.building(buildingId)).map((snapshot) {
      final data = snapshot.data();
      if (!snapshot.exists || data == null) return null;
      return BuildingEntity.fromJson(data, id: buildingId);
    });
  }

  @override
  Future<BuildingEntity?> fetchBuilding(String buildingId) async {
    final snapshot = await _firestore.getDocument(FirestorePaths.building(buildingId));
    final data = snapshot.data();
    if (!snapshot.exists || data == null) return null;
    return BuildingEntity.fromJson(data, id: buildingId);
  }

  @override
  Future<void> saveBuilding(BuildingEntity building) async {
    await _firestore.setDocument(
      FirestorePaths.building(building.id),
      building.toJson(),
      merge: true,
    );
  }

  @override
  Future<int> generateApartments({
    required String buildingId,
    required int totalFloors,
    required int apartmentsPerFloor,
  }) async {
    // Dedupe check (§7.3): never regenerate an apartment that already exists
    // for a floor/number combination.
    final existingSnapshot = await _firestore.getQuery(
      _firestore.buildingScoped(FirestoreCollections.apartments, buildingId),
    );
    final existingNumbers = existingSnapshot.docs
        .map((doc) => doc.data()['number']?.toString())
        .whereType<String>()
        .toSet();

    final numbersToCreate = <String>[];
    for (var floor = 1; floor <= totalFloors; floor++) {
      for (var unit = 1; unit <= apartmentsPerFloor; unit++) {
        final number = '$floor-${unit.toString().padLeft(2, '0')}';
        if (!existingNumbers.contains(number)) {
          numbersToCreate.add(number);
        }
      }
    }

    if (numbersToCreate.isEmpty) return 0;

    await _firestore.writeInChunks<String>(numbersToCreate, (batch, number) {
      final floor = int.parse(number.split('-').first);
      final ref = _firestore.collection(FirestoreCollections.apartments).doc();
      batch.set(ref, {
        'buildingId': buildingId,
        'number': number,
        'floor': floor,
        'description': null,
        'status': ApartmentStatus.vacant.value,
        'primaryResidentUid': null,
        'updatedAt': _firestore.serverTimestamp,
      });
    });

    return numbersToCreate.length;
  }
}
