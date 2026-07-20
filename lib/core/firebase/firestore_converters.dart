import 'package:cloud_firestore/cloud_firestore.dart';

/// Boundary helpers that keep every model's `fromJson`/`toJson` tolerant of
/// more than one wire format for date/time values.
///
/// Firestore reads give back a [Timestamp]; a future REST backend will most
/// likely give back an ISO-8601 string or epoch millis. Routing every model
/// through [FirestoreConverters.toDate] means a backend swap never requires
/// touching model classes for date handling — only the remote source (the
/// actual endpoint call) changes.
class FirestoreConverters {
  const FirestoreConverters._();

  static DateTime? toDate(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  static DateTime toDateOrNow(dynamic value) => toDate(value) ?? DateTime.now();

  /// `cloud_firestore` auto-converts a plain [DateTime] to a [Timestamp] on
  /// write, so this is a no-op today — kept as an explicit conversion point
  /// so a REST-based remote source can instead call `.toIso8601String()`
  /// without touching any model.
  static dynamic fromDate(DateTime? date) => date;
}
