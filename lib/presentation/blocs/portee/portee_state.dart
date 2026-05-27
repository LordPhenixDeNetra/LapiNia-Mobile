part of 'portee_bloc.dart';

abstract class PorteeState extends Equatable {
  const PorteeState();

  @override
  List<Object?> get props => [];
}

class PorteeInitial extends PorteeState {}

class PorteesLoading extends PorteeState {}

class PorteesLoaded extends PorteeState {
  final List<Portee> portees;

  const PorteesLoaded({required this.portees});

  @override
  List<Object?> get props => [portees];
}

class PorteeLoading extends PorteeState {}

class PorteeLoaded extends PorteeState {
  final Portee portee;

  const PorteeLoaded({required this.portee});

  @override
  List<Object?> get props => [portee];
}

class PorteeSaving extends PorteeState {}

class PorteeCreated extends PorteeState {
  final Portee portee;

  const PorteeCreated({required this.portee});

  @override
  List<Object?> get props => [portee];
}

class PorteeUpdated extends PorteeState {
  final Portee portee;

  const PorteeUpdated({required this.portee});

  @override
  List<Object?> get props => [portee];
}

class SaillieRecorded extends PorteeState {}

class MiseBasRecorded extends PorteeState {}

class SevrageRecorded extends PorteeState {}

class PorteeError extends PorteeState {
  final String message;

  const PorteeError({required this.message});

  @override
  List<Object?> get props => [message];
}
