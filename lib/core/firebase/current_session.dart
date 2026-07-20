import 'package:injectable/injectable.dart';

import '../constants/user_role.dart';

/// In-memory cache of the signed-in admin's identity, populated by the Auth
/// feature right after sign-in (role-gate resolution) and cleared on
/// sign-out.
///
/// Every building-scoped query across every feature needs `buildingId`; this
/// is the single place that value lives so no feature re-derives or
/// hardcodes it. Reusable as-is in the future Resident App (the resident
/// flow populates the same fields after its own sign-in).
@lazySingleton
class CurrentSession {
  String? _uid;
  String? _buildingId;
  UserRole? _role;

  String? get uid => _uid;
  String? get buildingId => _buildingId;
  UserRole? get role => _role;

  bool get isSignedIn => _uid != null;
  bool get isAdmin => _role == UserRole.admin;

  void update({String? uid, String? buildingId, UserRole? role}) {
    _uid = uid ?? _uid;
    _buildingId = buildingId ?? _buildingId;
    _role = role ?? _role;
  }

  void clear() {
    _uid = null;
    _buildingId = null;
    _role = null;
  }

  /// Throws a [StateError] if called before sign-in has populated the
  /// session — every building-scoped query should call this instead of the
  /// nullable [buildingId] getter so a missing session fails loudly instead
  /// of silently querying with a null/empty `buildingId`.
  String requireBuildingId() {
    final id = _buildingId;
    if (id == null) {
      throw StateError('CurrentSession.buildingId requested before sign-in.');
    }
    return id;
  }

  String requireUid() {
    final id = _uid;
    if (id == null) {
      throw StateError('CurrentSession.uid requested before sign-in.');
    }
    return id;
  }
}
