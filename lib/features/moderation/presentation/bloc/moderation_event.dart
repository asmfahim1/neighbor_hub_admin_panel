import 'package:equatable/equatable.dart';

abstract class ModerationEvent extends Equatable {
  const ModerationEvent();

  @override
  List<Object?> get props => [];
}

class LoadModeration extends ModerationEvent {
  const LoadModeration();
}
