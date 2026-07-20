/// Mirrors `apartment_requests/{uid}.status` in `05_FIRESTORE_DATABASE.md` §3.4.
enum ApartmentRequestStatus {
  pending,
  approved,
  rejected;

  String get value => switch (this) {
        ApartmentRequestStatus.pending => 'pending',
        ApartmentRequestStatus.approved => 'approved',
        ApartmentRequestStatus.rejected => 'rejected',
      };

  static ApartmentRequestStatus fromValue(String? value) => switch (value) {
        'approved' => ApartmentRequestStatus.approved,
        'rejected' => ApartmentRequestStatus.rejected,
        _ => ApartmentRequestStatus.pending,
      };
}
