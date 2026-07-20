import 'package:equatable/equatable.dart';

import '../../domain/entity/profile_entity.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class ProfileWatchStarted extends ProfileEvent {
  const ProfileWatchStarted(this.uid);
  final String uid;

  @override
  List<Object?> get props => [uid];
}

/// Internal — emitted by the bloc's own stream subscription.
class ProfileChanged extends ProfileEvent {
  const ProfileChanged(this.profile);
  final UserEntity? profile;

  @override
  List<Object?> get props => [profile];
}

class ProfileUpdateRequested extends ProfileEvent {
  const ProfileUpdateRequested({this.displayName, this.photoUrl});
  final String? displayName;
  final String? photoUrl;

  @override
  List<Object?> get props => [displayName, photoUrl];
}

class ProfileSignOutRequested extends ProfileEvent {
  const ProfileSignOutRequested();
}
