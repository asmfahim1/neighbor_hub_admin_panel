import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import 'firestore_collections.dart';

/// Thin, typed wrapper around [FirebaseFirestore] — the one place every
/// feature's remote source touches Firestore directly.
///
/// Keeping this as the sole seam means:
/// * building-scoped queries and bulk-write chunking are implemented once,
///   correctly, and reused everywhere (`04_UI_UX_GUIDELINES.md` /
///   `admen_web_app_ui_functionality.md` §5 "Atomicity via WriteBatch").
/// * a future REST backend swap never touches this file — only a new
///   `XApiSource` per feature is added, `FirestoreService` simply stops
///   being injected into that feature's remote source.
///
/// Reusable as-is in the future Resident App.
@lazySingleton
class FirestoreService {
  FirestoreService(this._firestore);

  final FirebaseFirestore _firestore;

  /// Escape hatch for call sites that need the raw SDK (e.g. `Transaction`).
  FirebaseFirestore get instance => _firestore;

  CollectionReference<Map<String, dynamic>> collection(String path) =>
      _firestore.collection(path);

  DocumentReference<Map<String, dynamic>> document(String path) => _firestore.doc(path);

  /// Building-scoped query helper — every building-scoped collection filters
  /// on `buildingId` (`05_FIRESTORE_DATABASE.md` §6).
  Query<Map<String, dynamic>> buildingScoped(
    String collectionPath,
    String buildingId, {
    String field = FirestoreFields.buildingId,
  }) =>
      collection(collectionPath).where(field, isEqualTo: buildingId);

  Future<DocumentSnapshot<Map<String, dynamic>>> getDocument(String path) =>
      document(path).get();

  Future<QuerySnapshot<Map<String, dynamic>>> getQuery(
    Query<Map<String, dynamic>> query,
  ) =>
      query.get();

  Stream<DocumentSnapshot<Map<String, dynamic>>> watchDocument(String path) =>
      document(path).snapshots();

  Stream<QuerySnapshot<Map<String, dynamic>>> watchQuery(
    Query<Map<String, dynamic>> query,
  ) =>
      query.snapshots();

  /// Creates a document with an auto-generated ID and returns it.
  Future<DocumentReference<Map<String, dynamic>>> addDocument(
    String collectionPath,
    Map<String, dynamic> data,
  ) =>
      collection(collectionPath).add(data);

  /// Creates/overwrites a document at a known path (e.g. deterministic IDs
  /// like `apartment_requests/{uid}` or `conversations/{uidA_uidB}`).
  Future<void> setDocument(
    String path,
    Map<String, dynamic> data, {
    bool merge = false,
  }) =>
      document(path).set(data, SetOptions(merge: merge));

  Future<void> updateDocument(String path, Map<String, dynamic> data) =>
      document(path).update(data);

  Future<void> deleteDocument(String path) => document(path).delete();

  WriteBatch newBatch() => _firestore.batch();

  Future<void> commitBatch(WriteBatch batch) => batch.commit();

  /// Applies [action] once per item across chunks of at most [chunkSize],
  /// committing (and awaiting) each chunk's batch before starting the next.
  ///
  /// Firestore caps a single `WriteBatch` at 500 writes; [chunkSize] defaults
  /// to a safety margin under that. Used for bulk apartment generation
  /// (Buildings §7.3) and per-resident notification fan-out (Announcements
  /// §7.7) — anywhere the doc calls for "chunk accordingly".
  Future<void> writeInChunks<T>(
    List<T> items,
    void Function(WriteBatch batch, T item) action, {
    int chunkSize = 450,
  }) async {
    for (var i = 0; i < items.length; i += chunkSize) {
      final chunk = items.skip(i).take(chunkSize);
      final batch = newBatch();
      for (final item in chunk) {
        action(batch, item);
      }
      await batch.commit();
    }
  }

  /// Runs a single read-modify-write as a Firestore [Transaction] — use when
  /// a write depends on a value just read in the same operation (e.g.
  /// incrementing a denormalized counter based on a check), as opposed to
  /// the fire-and-forget batch writes used for approve/reject/remove/transfer.
  Future<T> runTransaction<T>(
    Future<T> Function(Transaction transaction) action,
  ) =>
      _firestore.runTransaction(action);

  FieldValue get serverTimestamp => FieldValue.serverTimestamp();

  FieldValue increment(num value) => FieldValue.increment(value);

  FieldValue arrayUnion(List<dynamic> values) => FieldValue.arrayUnion(values);

  FieldValue arrayRemove(List<dynamic> values) => FieldValue.arrayRemove(values);
}
