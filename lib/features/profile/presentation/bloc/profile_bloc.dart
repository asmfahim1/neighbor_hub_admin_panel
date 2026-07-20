import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entity/profile_entity.dart';
import '../../domain/usecase/profile_usecase.dart';
import 'profile_event.dart';
import 'profile_state.dart';

@injectable
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc(
    this._watchOwnProfile,
    this._updateOwnProfile,
    this._signOut,
  ) : super(const ProfileState()) {
    on<ProfileWatchStarted>(_onWatchStarted);
    on<ProfileChanged>(_onProfileChanged);
    on<ProfileUpdateRequested>(_onUpdateRequested);
    on<ProfileSignOutRequested>(_onSignOutRequested);
  }

  final WatchOwnProfileUseCase _watchOwnProfile;
  final UpdateOwnProfileUseCase _updateOwnProfile;
  final ProfileSignOutUseCase _signOut;

  StreamSubscription<UserEntity?>? _subscription;
  String? _uid;

  Future<void> _onWatchStarted(
    ProfileWatchStarted event,
    Emitter<ProfileState> emit,
  ) async {
    _uid = event.uid;
    emit(state.copyWith(status: ProfileStatus.loading));
    await _subscription?.cancel();
    _subscription = _watchOwnProfile(event.uid).listen((profile) {
      add(ProfileChanged(profile));
    });
  }

  void _onProfileChanged(ProfileChanged event, Emitter<ProfileState> emit) {
    emit(state.copyWith(
      status: ProfileStatus.loaded,
      profile: event.profile,
      clearProfile: event.profile == null,
    ));
  }

  Future<void> _onUpdateRequested(
    ProfileUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    final uid = _uid;
    if (uid == null) return;
    emit(state.copyWith(status: ProfileStatus.saving, clearMessage: true));
    final result = await _updateOwnProfile(
      uid,
      displayName: event.displayName,
      photoUrl: event.photoUrl,
    );
    result.fold(
      (failure) => emit(state.copyWith(status: ProfileStatus.failure, message: failure.displayMessage)),
      // The realtime listener will push ProfileChanged with the saved data.
      (_) => emit(state.copyWith(status: ProfileStatus.loaded)),
    );
  }

  Future<void> _onSignOutRequested(
    ProfileSignOutRequested event,
    Emitter<ProfileState> emit,
  ) async {
    final result = await _signOut();
    result.fold(
      (failure) => emit(state.copyWith(status: ProfileStatus.failure, message: failure.displayMessage)),
      (_) => emit(state.copyWith(status: ProfileStatus.signedOut, clearProfile: true)),
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
