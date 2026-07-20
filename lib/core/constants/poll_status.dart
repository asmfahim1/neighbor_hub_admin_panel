/// Mirrors `polls/{pollId}.status` in `05_FIRESTORE_DATABASE.md` §3.11.
enum PollStatus {
  active,
  closed;

  String get value => switch (this) {
        PollStatus.active => 'active',
        PollStatus.closed => 'closed',
      };

  static PollStatus fromValue(String? value) => switch (value) {
        'closed' => PollStatus.closed,
        _ => PollStatus.active,
      };
}
