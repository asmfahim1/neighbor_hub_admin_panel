import 'package:equatable/equatable.dart';

import '../../../../core/constants/apartment_status.dart';
import '../../domain/entity/apartments_entity.dart';

abstract class ApartmentsEvent extends Equatable {
  const ApartmentsEvent();

  @override
  List<Object?> get props => [];
}

class ApartmentsWatchStarted extends ApartmentsEvent {
  const ApartmentsWatchStarted(this.buildingId);
  final String buildingId;

  @override
  List<Object?> get props => [buildingId];
}

/// Internal — emitted by the bloc's own stream subscription.
class ApartmentsChanged extends ApartmentsEvent {
  const ApartmentsChanged(this.apartments);
  final List<ApartmentEntity> apartments;

  @override
  List<Object?> get props => [apartments];
}

class ApartmentCreateRequested extends ApartmentsEvent {
  const ApartmentCreateRequested(this.apartment);
  final ApartmentEntity apartment;

  @override
  List<Object?> get props => [apartment];
}

class ApartmentUpdateRequested extends ApartmentsEvent {
  const ApartmentUpdateRequested(this.apartment);
  final ApartmentEntity apartment;

  @override
  List<Object?> get props => [apartment];
}

class ApartmentDeleteRequested extends ApartmentsEvent {
  const ApartmentDeleteRequested(this.apartmentId);
  final String apartmentId;

  @override
  List<Object?> get props => [apartmentId];
}

/// Manual `vacant` <-> `blocked` toggle only — see
/// `ApartmentsRepository.setStatus` for why `occupied` is rejected here.
class ApartmentStatusChangeRequested extends ApartmentsEvent {
  const ApartmentStatusChangeRequested(this.apartmentId, this.status);
  final String apartmentId;
  final ApartmentStatus status;

  @override
  List<Object?> get props => [apartmentId, status];
}
