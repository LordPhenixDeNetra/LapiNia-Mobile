part of 'portee_bloc.dart';

abstract class PorteeEvent extends Equatable {
  const PorteeEvent();

  @override
  List<Object?> get props => [];
}

class PorteesLoadRequested extends PorteeEvent {}

class PorteeLoadRequested extends PorteeEvent {
  final String id;

  const PorteeLoadRequested({required this.id});

  @override
  List<Object?> get props => [id];
}

class PorteeCreateRequested extends PorteeEvent {
  final Portee portee;

  const PorteeCreateRequested({required this.portee});

  @override
  List<Object?> get props => [portee];
}

class PorteeUpdateRequested extends PorteeEvent {
  final Portee portee;

  const PorteeUpdateRequested({required this.portee});

  @override
  List<Object?> get props => [portee];
}

class SaillieCreateRequested extends PorteeEvent {
  final String porteeId;
  final String mereId;
  final String pereId;
  final DateTime dateSaillie;

  const SaillieCreateRequested({
    required this.porteeId,
    required this.mereId,
    required this.pereId,
    required this.dateSaillie,
  });

  @override
  List<Object?> get props => [porteeId, mereId, pereId, dateSaillie];
}

class MiseBasRecordRequested extends PorteeEvent {
  final String porteeId;
  final String mereId;
  final DateTime dateMiseBas;
  final int nbVivants;
  final int nbMorts;
  final int poidsTotalG;

  const MiseBasRecordRequested({
    required this.porteeId,
    required this.mereId,
    required this.dateMiseBas,
    required this.nbVivants,
    required this.nbMorts,
    required this.poidsTotalG,
  });

  @override
  List<Object?> get props => [porteeId, mereId, dateMiseBas, nbVivants, nbMorts, poidsTotalG];
}

class SevrageRecordRequested extends PorteeEvent {
  final String porteeId;
  final String mereId;

  const SevrageRecordRequested({
    required this.porteeId,
    required this.mereId,
  });

  @override
  List<Object?> get props => [porteeId, mereId];
}
