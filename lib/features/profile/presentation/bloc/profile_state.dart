import 'package:equatable/equatable.dart';
import '../../domain/entity/profile_entity.dart';

enum ProfileStatus { initial, loading, success, failure }

class ProfileState extends Equatable {
  const ProfileState({
    this.status = ProfileStatus.initial,
    this.items = const [],
    this.message,
  });

  final ProfileStatus status;
  final List<ProfileEntity> items;
  final String? message;

  ProfileState copyWith({
    ProfileStatus? status,
    List<ProfileEntity>? items,
    String? message,
  }) {
    return ProfileState(
      status: status ?? this.status,
      items: items ?? this.items,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, items, message];
}
