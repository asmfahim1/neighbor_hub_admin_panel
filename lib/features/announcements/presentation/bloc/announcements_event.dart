import 'package:equatable/equatable.dart';

abstract class AnnouncementsEvent extends Equatable {
  const AnnouncementsEvent();

  @override
  List<Object?> get props => [];
}

class LoadAnnouncements extends AnnouncementsEvent {
  const LoadAnnouncements();
}
