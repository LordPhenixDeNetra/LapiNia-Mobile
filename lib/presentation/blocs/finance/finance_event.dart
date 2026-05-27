part of 'finance_bloc.dart';

abstract class FinanceEvent extends Equatable {
  const FinanceEvent();

  @override
  List<Object?> get props => [];
}

class FinancesLoadRequested extends FinanceEvent {}

class FinancesByPeriodeLoadRequested extends FinanceEvent {
  final int annee;
  final int mois;

  const FinancesByPeriodeLoadRequested({required this.annee, required this.mois});

  @override
  List<Object?> get props => [annee, mois];
}

class FinanceCreateRequested extends FinanceEvent {
  final Finance finance;

  const FinanceCreateRequested({required this.finance});

  @override
  List<Object?> get props => [finance];
}

class ResumeMensuelLoadRequested extends FinanceEvent {
  final int annee;
  final int mois;

  const ResumeMensuelLoadRequested({required this.annee, required this.mois});

  @override
  List<Object?> get props => [annee, mois];
}
