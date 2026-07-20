/// Mirrors `apartments/{apartmentId}.status` in `05_FIRESTORE_DATABASE.md` §3.3.
///
/// `occupied` is never set directly by the Apartments feature — it is only
/// reached through the Residents approval `WriteBatch` (§7.5.1). Apartments
/// itself may freely toggle between [vacant] and [blocked].
enum ApartmentStatus {
  vacant,
  pendingApproval,
  occupied,
  blocked;

  String get value => switch (this) {
        ApartmentStatus.vacant => 'vacant',
        ApartmentStatus.pendingApproval => 'pending_approval',
        ApartmentStatus.occupied => 'occupied',
        ApartmentStatus.blocked => 'blocked',
      };

  static ApartmentStatus fromValue(String? value) => switch (value) {
        'occupied' => ApartmentStatus.occupied,
        'blocked' => ApartmentStatus.blocked,
        'pending_approval' => ApartmentStatus.pendingApproval,
        _ => ApartmentStatus.vacant,
      };
}
