part of 'lapin_bloc.dart';

abstract class LapinState extends Equatable {
  const LapinState();

  @override
  List<Object?> get props => [];
}

class LapinInitial extends LapinState {}

class LapinsLoading extends LapinState {}

class LapinsLoaded extends LapinState {
  final List<Lapin> lapins;

  const LapinsLoaded({required this.lapins});

  @override
  List<Object?> get props => [lapins];
}

class LapinLoading extends LapinState {}

class LapinLoaded extends LapinState {
  final Lapin lapin;

  const LapinLoaded({required this.lapin});

  @override
  List<Object?> get props => [lapin];
}

class LapinSaving extends LapinState {}

class LapinCreated extends LapinState {
  final Lapin lapin;

  const LapinCreated({required this.lapin});

  @override
  List<Object?> get props => [lapin];
}

class LapinUpdated extends LapinState {
  final Lapin lapin;

  const LapinUpdated({required this.lapin});

  @override
  List<Object?> get props => [lapin];
}

class LapinDeleted extends LapinState {}

class PeseeRecorded extends LapinState {}

class RacesLoaded extends LapinState {
  final List<Race> races;

  const RacesLoaded({required this.races});

  @override
  List<Object?> get props => [races];
}

class LapinError extends LapinState {
  final String message;

  const LapinError({required this.message});

  @override
  List<Object?> get props => [message];
}
