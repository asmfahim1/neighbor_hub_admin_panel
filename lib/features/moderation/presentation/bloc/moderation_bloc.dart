import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/models/models.dart';
import '../../../../core/utils/result.dart';
import '../../domain/usecase/moderation_usecase.dart';
import 'moderation_event.dart';
import 'moderation_state.dart';

@injectable
class ModerationBloc extends Bloc<ModerationEvent, ModerationState> {
  ModerationBloc(
    this._watchFeed,
    this._watchComments,
    this._resolveRealAuthor,
    this._deletePost,
    this._deleteComment,
    this._setLocked,
    this._setPinned,
  ) : super(const ModerationState()) {
    on<ModerationFeedWatchStarted>(_onFeedWatchStarted);
    on<ModerationFeedUpdated>(_onFeedUpdated);
    on<PostThreadOpened>(_onThreadOpened);
    on<ModerationCommentsUpdated>(_onCommentsUpdated);
    on<PostThreadClosed>(_onThreadClosed);
    on<RealAuthorRequested>(_onRealAuthorRequested);
    on<PostDeleteRequested>(_onPostDeleteRequested);
    on<CommentDeleteRequested>(_onCommentDeleteRequested);
    on<PostLockToggled>(_onLockToggled);
    on<PostPinToggled>(_onPinToggled);
  }

  final WatchModerationFeedUseCase _watchFeed;
  final WatchPostCommentsUseCase _watchComments;
  final ResolveRealAuthorUseCase _resolveRealAuthor;
  final DeletePostUseCase _deletePost;
  final DeleteCommentUseCase _deleteComment;
  final SetPostLockedUseCase _setLocked;
  final SetPostPinnedUseCase _setPinned;

  StreamSubscription<List<PostEntity>>? _feedSubscription;
  StreamSubscription<List<CommentEntity>>? _commentsSubscription;

  Future<void> _onFeedWatchStarted(
    ModerationFeedWatchStarted event,
    Emitter<ModerationState> emit,
  ) async {
    emit(state.copyWith(status: ModerationStatus.loading));
    await _feedSubscription?.cancel();
    _feedSubscription = _watchFeed(event.buildingId).listen((posts) {
      add(ModerationFeedUpdated(posts));
    });
  }

  void _onFeedUpdated(ModerationFeedUpdated event, Emitter<ModerationState> emit) {
    emit(state.copyWith(status: ModerationStatus.loaded, feed: event.posts));
  }

  Future<void> _onThreadOpened(PostThreadOpened event, Emitter<ModerationState> emit) async {
    emit(state.copyWith(openPostId: event.postId, comments: const []));
    await _commentsSubscription?.cancel();
    _commentsSubscription = _watchComments(event.postId).listen((comments) {
      add(ModerationCommentsUpdated(comments));
    });
  }

  void _onCommentsUpdated(ModerationCommentsUpdated event, Emitter<ModerationState> emit) {
    emit(state.copyWith(comments: event.comments));
  }

  Future<void> _onThreadClosed(PostThreadClosed event, Emitter<ModerationState> emit) async {
    await _commentsSubscription?.cancel();
    _commentsSubscription = null;
    emit(state.copyWith(clearOpenPostId: true, clearRealAuthorUid: true));
  }

  Future<void> _onRealAuthorRequested(
    RealAuthorRequested event,
    Emitter<ModerationState> emit,
  ) async {
    final result = await _resolveRealAuthor(event.postId);
    result.fold(
      (failure) => emit(state.copyWith(status: ModerationStatus.failure, message: failure.displayMessage)),
      (authorship) => emit(state.copyWith(realAuthorUid: authorship?.authorUid ?? '')),
    );
  }

  Future<void> _onPostDeleteRequested(
    PostDeleteRequested event,
    Emitter<ModerationState> emit,
  ) async {
    emit(state.copyWith(status: ModerationStatus.mutating, clearMessage: true));
    final result = await _deletePost(event.postId);
    _emitMutationResult(result, emit);
  }

  Future<void> _onCommentDeleteRequested(
    CommentDeleteRequested event,
    Emitter<ModerationState> emit,
  ) async {
    emit(state.copyWith(status: ModerationStatus.mutating, clearMessage: true));
    final result = await _deleteComment(event.postId, event.commentId);
    _emitMutationResult(result, emit);
  }

  Future<void> _onLockToggled(PostLockToggled event, Emitter<ModerationState> emit) async {
    emit(state.copyWith(status: ModerationStatus.mutating, clearMessage: true));
    final result = await _setLocked(event.postId, event.isLocked);
    _emitMutationResult(result, emit);
  }

  Future<void> _onPinToggled(PostPinToggled event, Emitter<ModerationState> emit) async {
    emit(state.copyWith(status: ModerationStatus.mutating, clearMessage: true));
    final result = await _setPinned(event.postId, event.isPinned);
    _emitMutationResult(result, emit);
  }

  /// After any successful mutation, fall back to [ModerationStatus.loaded] —
  /// the realtime feed listener will follow shortly with authoritative data.
  void _emitMutationResult(Result<void> result, Emitter<ModerationState> emit) {
    result.fold(
      (failure) => emit(state.copyWith(status: ModerationStatus.failure, message: failure.displayMessage)),
      (_) => emit(state.copyWith(status: ModerationStatus.loaded)),
    );
  }

  @override
  Future<void> close() async {
    await _feedSubscription?.cancel();
    await _commentsSubscription?.cancel();
    return super.close();
  }
}
