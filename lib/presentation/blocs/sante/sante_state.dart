part of 'sante_bloc.dart';

abstract class SanteState extends Equatable {
  const SanteState();

  @override
  List<Object?> get props => [];
}

class SanteInitial extends SanteState {}

class SanteLoading extends SanteState {}

class SanteLoaded extends SanteState {
  final List<EvenementSante> evenements;

  const SanteLoaded({required this.evenements});

  @override
  List<Object?> get props => [evenements];
}

class SanteSaving extends SanteState {}

class EvenementSanteCreated extends SanteState {}

class TraitementTermine extends SanteState {}

class SanteError extends SanteState {
  final String message;

  const SanteError({required this.message});

  @override
  List<Object?> get props => [message];
}
