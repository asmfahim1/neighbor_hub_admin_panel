import 'package:equatable/equatable.dart';

import '../../domain/entity/apartments_entity.dart';

enum ApartmentsStatus { initial, loading, loaded, mutating, failure }

class ApartmentsState extends Equatable {
  const ApartmentsState({
    this.status = ApartmentsStatus.initial,
    this.apartments = const [],
    this.message,
  });

  final ApartmentsStatus status;
  final List<ApartmentEntity> apartments;
  final String? message;

  ApartmentsState copyWith({
    ApartmentsStatus? status,
    List<ApartmentEntity>? apartments,
    String? message,
    bool clearMessage = false,
  }) {
    return ApartmentsState(
      status: status ?? this.status,
      apartments: apartments ?? this.apartments,
      message: clearMessage ? null : (message ?? this.message),
    );
  }

  @override
  List<Object?> get props => [status, apartments, message];
}
