import 'package:equatable/equatable.dart';

import '../../domain/entity/residents_entity.dart';

enum ResidentsStatus { initial, loading, loaded, mutating, failure }

class ResidentsState extends Equatable {
  const ResidentsState({
    this.status = ResidentsStatus.initial,
    this.pendingRequests = const [],
    this.directory = const [],
    this.selectedResident,
    this.selectedResidentActivity,
    this.message,
  });

  final ResidentsStatus status;
  final List<ApartmentRequestEntity> pendingRequests;
  final List<UserEntity> directory;
  final UserEntity? selectedResident;
  final ResidentActivitySummaryEntity? selectedResidentActivity;
  final String? message;

  ResidentsState copyWith({
    ResidentsStatus? status,
    List<ApartmentRequestEntity>? pendingRequests,
    List<UserEntity>? directory,
    UserEntity? selectedResident,
    ResidentActivitySummaryEntity? selectedResidentActivity,
    String? message,
    bool clearMessage = false,
  }) {
    return ResidentsState(
      status: status ?? this.status,
      pendingRequests: pendingRequests ?? this.pendingRequests,
      directory: directory ?? this.directory,
      selectedResident: selectedResident ?? this.selectedResident,
      selectedResidentActivity: selectedResidentActivity ?? this.selectedResidentActivity,
      message: clearMessage ? null : (message ?? this.message),
    );
  }

  @override
  List<Object?> get props => [
        status,
        pendingRequests,
        directory,
        selectedResident,
        selectedResidentActivity,
        message,
      ];
}
