part of 'lapin_bloc.dart';

abstract class LapinEvent extends Equatable {
  const LapinEvent();

  @override
  List<Object?> get props => [];
}

class LapinsLoadRequested extends LapinEvent {}

class LapinLoadRequested extends LapinEvent {
  final String id;

  const LapinLoadRequested({required this.id});

  @override
  List<Object?> get props => [id];
}

class LapinCreateRequested extends LapinEvent {
  final Lapin lapin;

  const LapinCreateRequested({required this.lapin});

  @override
  List<Object?> get props => [lapin];
}

class LapinUpdateRequested extends LapinEvent {
  final Lapin lapin;

  const LapinUpdateRequested({required this.lapin});

  @override
  List<Object?> get props => [lapin];
}

class LapinDeleteRequested extends LapinEvent {
  final String id;

  const LapinDeleteRequested({required this.id});

  @override
  List<Object?> get props => [id];
}

class LapinPeserRequested extends LapinEvent {
  final String lapinId;
  final int poidsG;

  const LapinPeserRequested({required this.lapinId, required this.poidsG});

  @override
  List<Object?> get props => [lapinId, poidsG];
}

class RacesLoadRequested extends LapinEvent {}
