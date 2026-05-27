part of 'sante_bloc.dart';

abstract class SanteEvent extends Equatable {
  const SanteEvent();

  @override
  List<Object?> get props => [];
}

class SanteLoadRequested extends SanteEvent {}

class SanteByLapinLoadRequested extends SanteEvent {
  final String lapinId;

  const SanteByLapinLoadRequested({required this.lapinId});

  @override
  List<Object?> get props => [lapinId];
}

class EvenementSanteCreateRequested extends SanteEvent {
  final EvenementSante evenement;

  const EvenementSanteCreateRequested({required this.evenement});

  @override
  List<Object?> get props => [evenement];
}

class TraitementTerminerRequested extends SanteEvent {
  final String evenementId;

  const TraitementTerminerRequested({required this.evenementId});

  @override
  List<Object?> get props => [evenementId];
}
