import 'package:equatable/equatable.dart';

abstract class BuildingsEvent extends Equatable {
  const BuildingsEvent();

  @override
  List<Object?> get props => [];
}

class LoadBuildings extends BuildingsEvent {
  const LoadBuildings();
}
