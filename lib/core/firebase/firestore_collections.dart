/// Top-level Firestore collection names, per `05_FIRESTORE_DATABASE.md` §6
/// naming conventions (plural, snake_case where multi-word). Never spell a
/// collection name as a raw string literal outside this file — reuse this
/// (or [FirestorePaths]) so the admin app and the future resident app can
/// never drift on a collection name.
class FirestoreCollections {
  const FirestoreCollections._();

  static const buildings = 'buildings';
  static const users = 'users';
  static const apartments = 'apartments';
  static const apartmentRequests = 'apartment_requests';
  static const posts = 'posts';
  static const postAuthorship = 'post_authorship';
  static const bookmarks = 'bookmarks';
  static const announcements = 'announcements';
  static const polls = 'polls';
  static const notifications = 'notifications';
  static const conversations = 'conversations';

  // Subcollection segment names.
  static const privateSubcollection = 'private';
  static const reactionsSubcollection = 'reactions';
  static const commentsSubcollection = 'comments';
  static const votesSubcollection = 'votes';
  static const messagesSubcollection = 'messages';
}

/// Common field names shared across multiple collections, per
/// `05_FIRESTORE_DATABASE.md` §6 ("every building-scoped document has a
/// `buildingId` field — no exceptions").
class FirestoreFields {
  const FirestoreFields._();

  static const buildingId = 'buildingId';
  static const createdAt = 'createdAt';
  static const updatedAt = 'updatedAt';
  static const status = 'status';
}

/// Deterministic document/collection path builders for every collection in
/// `05_FIRESTORE_DATABASE.md` §3. Centralizing these means the deterministic
/// ID schemes (apartment_requests keyed by uid, bookmarks by `uid_postId`,
/// conversations by sorted uid pair, reactions/votes keyed by uid) are only
/// ever computed in one place.
class FirestorePaths {
  const FirestorePaths._();

  static String building(String buildingId) =>
      '${FirestoreCollections.buildings}/$buildingId';

  static String user(String uid) => '${FirestoreCollections.users}/$uid';

  /// `users/{uid}/private/account` — the single private subdocument per user.
  static String userPrivateAccount(String uid) =>
      '${user(uid)}/${FirestoreCollections.privateSubcollection}/account';

  static String apartment(String apartmentId) =>
      '${FirestoreCollections.apartments}/$apartmentId';

  /// Document ID is the requester's uid — see `05_FIRESTORE_DATABASE.md` §3.4.
  static String apartmentRequest(String uid) =>
      '${FirestoreCollections.apartmentRequests}/$uid';

  static String post(String postId) => '${FirestoreCollections.posts}/$postId';

  static String postAuthorship(String postId) =>
      '${FirestoreCollections.postAuthorship}/$postId';

  static String postReactions(String postId) =>
      '${post(postId)}/${FirestoreCollections.reactionsSubcollection}';

  /// Document ID is the reacting user's uid — one reaction per user per post.
  static String postReaction(String postId, String uid) =>
      '${postReactions(postId)}/$uid';

  static String postComments(String postId) =>
      '${post(postId)}/${FirestoreCollections.commentsSubcollection}';

  static String postComment(String postId, String commentId) =>
      '${postComments(postId)}/$commentId';

  /// Document ID is `${uid}_${postId}` — see `05_FIRESTORE_DATABASE.md` §3.9.
  static String bookmark(String uid, String postId) =>
      '${FirestoreCollections.bookmarks}/${uid}_$postId';

  static String announcement(String announcementId) =>
      '${FirestoreCollections.announcements}/$announcementId';

  static String poll(String pollId) => '${FirestoreCollections.polls}/$pollId';

  static String pollVotes(String pollId) =>
      '${poll(pollId)}/${FirestoreCollections.votesSubcollection}';

  /// Document ID is the voter's uid — one vote per resident, immutable.
  static String pollVote(String pollId, String uid) => '${pollVotes(pollId)}/$uid';

  static String notification(String notificationId) =>
      '${FirestoreCollections.notifications}/$notificationId';

  static String conversation(String conversationId) =>
      '${FirestoreCollections.conversations}/$conversationId';

  static String conversationMessages(String conversationId) =>
      '${conversation(conversationId)}/${FirestoreCollections.messagesSubcollection}';

  static String conversationMessage(String conversationId, String messageId) =>
      '${conversationMessages(conversationId)}/$messageId';

  /// Document ID for a 1:1 conversation is the two participant uids, sorted
  /// and joined — see `05_FIRESTORE_DATABASE.md` §3.14. Structurally prevents
  /// duplicate conversations between the same pair.
  static String conversationIdFor(String uidA, String uidB) {
    final sorted = [uidA, uidB]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }
}
