import 'package:equatable/equatable.dart';

import '../../domain/entity/profile_entity.dart';

enum ProfileStatus { initial, loading, loaded, saving, signedOut, failure }

class ProfileState extends Equatable {
  const ProfileState({
    this.status = ProfileStatus.initial,
    this.profile,
    this.message,
  });

  final ProfileStatus status;
  final UserEntity? profile;
  final String? message;

  ProfileState copyWith({
    ProfileStatus? status,
    UserEntity? profile,
    bool clearProfile = false,
    String? message,
    bool clearMessage = false,
  }) {
    return ProfileState(
      status: status ?? this.status,
      profile: clearProfile ? null : (profile ?? this.profile),
      message: clearMessage ? null : (message ?? this.message),
    );
  }

  @override
  List<Object?> get props => [status, profile, message];
}
