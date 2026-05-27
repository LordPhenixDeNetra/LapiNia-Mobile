part of 'finance_bloc.dart';

abstract class FinanceState extends Equatable {
  const FinanceState();

  @override
  List<Object?> get props => [];
}

class FinanceInitial extends FinanceState {}

class FinancesLoading extends FinanceState {}

class FinancesLoaded extends FinanceState {
  final List<Finance> finances;

  const FinancesLoaded({required this.finances});

  int get totalRecettes => finances
      .where((f) => f.type == TypeFinance.recette)
      .fold(0, (sum, f) => sum + f.montantFcfa);

  int get totalDepenses => finances
      .where((f) => f.type == TypeFinance.depense)
      .fold(0, (sum, f) => sum + f.montantFcfa);

  int get benefice => totalRecettes - totalDepenses;

  @override
  List<Object?> get props => [finances];
}

class ResumeMensuelLoaded extends FinanceState {
  final int totalRecettes;
  final int totalDepenses;
  final int benefice;

  const ResumeMensuelLoaded({
    required this.totalRecettes,
    required this.totalDepenses,
    required this.benefice,
  });

  @override
  List<Object?> get props => [totalRecettes, totalDepenses, benefice];
}

class FinanceSaving extends FinanceState {}

class FinanceCreated extends FinanceState {}

class FinanceError extends FinanceState {
  final String message;

  const FinanceError({required this.message});

  @override
  List<Object?> get props => [message];
}
