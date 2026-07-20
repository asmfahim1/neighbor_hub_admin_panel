import 'package:equatable/equatable.dart';

abstract class ResidentsEvent extends Equatable {
  const ResidentsEvent();

  @override
  List<Object?> get props => [];
}

class LoadResidents extends ResidentsEvent {
  const LoadResidents();
}
