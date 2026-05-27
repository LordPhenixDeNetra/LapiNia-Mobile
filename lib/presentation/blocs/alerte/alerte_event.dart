part of 'alerte_bloc.dart';

abstract class AlerteEvent extends Equatable {
  const AlerteEvent();

  @override
  List<Object?> get props => [];
}

class AlertesLoadRequested extends AlerteEvent {}

class AlertesNonLuesLoadRequested extends AlerteEvent {}

class AlerteMarkAsReadRequested extends AlerteEvent {
  final String id;

  const AlerteMarkAsReadRequested({required this.id});

  @override
  List<Object?> get props => [id];
}

class AlerteMarkAsActionDoneRequested extends AlerteEvent {
  final String id;

  const AlerteMarkAsActionDoneRequested({required this.id});

  @override
  List<Object?> get props => [id];
}

class AlerteCreateRequested extends AlerteEvent {
  final Alerte alerte;

  const AlerteCreateRequested({required this.alerte});

  @override
  List<Object?> get props => [alerte];
}
