import 'package:equatable/equatable.dart';

abstract class PollsEvent extends Equatable {
  const PollsEvent();

  @override
  List<Object?> get props => [];
}

class LoadPolls extends PollsEvent {
  const LoadPolls();
}
