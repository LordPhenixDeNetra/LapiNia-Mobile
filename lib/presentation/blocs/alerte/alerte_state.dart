part of 'alerte_bloc.dart';

abstract class AlerteState extends Equatable {
  const AlerteState();

  @override
  List<Object?> get props => [];
}

class AlerteInitial extends AlerteState {}

class AlertesLoading extends AlerteState {}

class AlertesLoaded extends AlerteState {
  final List<Alerte> alertes;

  const AlertesLoaded({required this.alertes});

  @override
  List<Object?> get props => [alertes];
}

class AlerteCreated extends AlerteState {}

class AlerteUpdated extends AlerteState {}

class AlerteError extends AlerteState {
  final String message;

  const AlerteError({required this.message});

  @override
  List<Object?> get props => [message];
}
