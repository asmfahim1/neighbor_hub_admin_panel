import 'package:injectable/injectable.dart';

import '../../../../core/constants/poll_status.dart';
import '../../../../core/firebase/firestore_collections.dart';
import '../../../../core/firebase/firestore_service.dart';
import '../../domain/entity/polls_entity.dart';

/// The swappable "endpoint" boundary for the Polls feature. A future custom
/// backend adds `PollsApiSource implements PollsRemoteSource` and flips the
/// DI binding — nothing in `domain/` or `data/repository` changes.
abstract class PollsRemoteSource {
  Stream<List<PollEntity>> watchPolls(String buildingId);
  Stream<List<PollVoteEntity>> watchVotes(String pollId);
  Future<void> createPoll(PollEntity poll);
  Future<void> closePoll(String pollId);
}

@LazySingleton(as: PollsRemoteSource)
class PollsFirestoreSource implements PollsRemoteSource {
  PollsFirestoreSource(this._firestore);

  final FirestoreService _firestore;

  @override
  Stream<List<PollEntity>> watchPolls(String buildingId) {
    final query = _firestore
        .buildingScoped(FirestoreCollections.polls, buildingId)
        .orderBy(FirestoreFields.createdAt, descending: true);
    return _firestore.watchQuery(query).map(
          (snapshot) =>
              snapshot.docs.map((doc) => PollEntity.fromJson(doc.data(), id: doc.id)).toList(),
        );
  }

  @override
  Stream<List<PollVoteEntity>> watchVotes(String pollId) {
    final query = _firestore.collection(FirestorePaths.pollVotes(pollId));
    return _firestore.watchQuery(query).map(
          (snapshot) => snapshot.docs
              .map((doc) => PollVoteEntity.fromJson(doc.data(), uid: doc.id, pollId: pollId))
              .toList(),
        );
  }

  @override
  Future<void> createPoll(PollEntity poll) async {
    await _firestore.addDocument(FirestoreCollections.polls, poll.toJson());
  }

  @override
  Future<void> closePoll(String pollId) async {
    await _firestore.updateDocument(FirestorePaths.poll(pollId), {
      'status': PollStatus.closed.value,
    });
  }
}
