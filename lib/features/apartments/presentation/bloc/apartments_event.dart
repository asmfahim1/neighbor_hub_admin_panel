import 'package:equatable/equatable.dart';

abstract class ApartmentsEvent extends Equatable {
  const ApartmentsEvent();

  @override
  List<Object?> get props => [];
}

class LoadApartments extends ApartmentsEvent {
  const LoadApartments();
}
