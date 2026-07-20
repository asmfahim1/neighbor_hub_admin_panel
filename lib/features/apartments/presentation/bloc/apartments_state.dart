import 'package:equatable/equatable.dart';
import '../../domain/entity/apartments_entity.dart';

enum ApartmentsStatus { initial, loading, success, failure }

class ApartmentsState extends Equatable {
  const ApartmentsState({
    this.status = ApartmentsStatus.initial,
    this.items = const [],
    this.message,
  });

  final ApartmentsStatus status;
  final List<ApartmentsEntity> items;
  final String? message;

  ApartmentsState copyWith({
    ApartmentsStatus? status,
    List<ApartmentsEntity>? items,
    String? message,
  }) {
    return ApartmentsState(
      status: status ?? this.status,
      items: items ?? this.items,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, items, message];
}
