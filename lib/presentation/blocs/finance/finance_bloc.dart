import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/models/finance.dart';
import '../../../core/constants/enums.dart';

part 'finance_event.dart';
part 'finance_state.dart';

class FinanceBloc extends Bloc<FinanceEvent, FinanceState> {
  final SupabaseClient supabaseClient;

  FinanceBloc({required this.supabaseClient}) : super(FinanceInitial()) {
    on<FinancesLoadRequested>(_onLoadRequested);
    on<FinancesByPeriodeLoadRequested>(_onByPeriodeLoadRequested);
    on<FinanceCreateRequested>(_onCreateRequested);
    on<ResumeMensuelLoadRequested>(_onResumeLoadRequested);
  }

  Future<void> _onLoadRequested(
    FinancesLoadRequested event,
    Emitter<FinanceState> emit,
  ) async {
    emit(FinancesLoading());
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        emit(const FinanceError(message: 'User not authenticated'));
        return;
      }
      final response = await supabaseClient
          .from('finances')
          .select('*, lapins(*)')
          .eq('user_id', userId)
          .order('date', ascending: false)
          .limit(50);
      
      final finances = (response as List)
          .map((json) => Finance.fromJson(json))
          .toList();
      
      emit(FinancesLoaded(finances: finances));
    } catch (e) {
      emit(FinanceError(message: e.toString()));
    }
  }

  Future<void> _onByPeriodeLoadRequested(
    FinancesByPeriodeLoadRequested event,
    Emitter<FinanceState> emit,
  ) async {
    emit(FinancesLoading());
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        emit(const FinanceError(message: 'User not authenticated'));
        return;
      }
      final debut = DateTime(event.annee, event.mois, 1);
      final fin = DateTime(event.annee, event.mois + 1, 0);
      
      final response = await supabaseClient
          .from('finances')
          .select('*, lapins(*)')
          .eq('user_id', userId)
          .gte('date', debut.toIso8601String().split('T')[0])
          .lte('date', fin.toIso8601String().split('T')[0])
          .order('date', ascending: false);
      
      final finances = (response as List)
          .map((json) => Finance.fromJson(json))
          .toList();
      
      emit(FinancesLoaded(finances: finances));
    } catch (e) {
      emit(FinanceError(message: e.toString()));
    }
  }

  Future<void> _onCreateRequested(
    FinanceCreateRequested event,
    Emitter<FinanceState> emit,
  ) async {
    emit(FinanceSaving());
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      
      if (userId == null) {
        emit(const FinanceError(message: 'User not authenticated'));
        return;
      }

      final idempotencyKey = '${userId}_${DateTime.now().millisecondsSinceEpoch}';
      
      final data = {
        'id': event.finance.id,
        'user_id': userId,
        'date': event.finance.date.toIso8601String().split('T')[0],
        'type': event.finance.type.dbValue,
        'categorie': event.finance.categorie.dbValue,
        'montant_fcfa': event.finance.montantFcfa,
        'description': event.finance.description,
        'lapin_id': event.finance.lapinId,
        'mode_paiement': event.finance.modePaiement.dbValue,
        'idempotency_key': idempotencyKey,
      };

      await supabaseClient.from('finances').insert(data);
      
      emit(FinanceCreated());
      add(FinancesLoadRequested());
    } catch (e) {
      emit(FinanceError(message: e.toString()));
    }
  }

  Future<void> _onResumeLoadRequested(
    ResumeMensuelLoadRequested event,
    Emitter<FinanceState> emit,
  ) async {
    emit(FinancesLoading());
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        emit(const FinanceError(message: 'User not authenticated'));
        return;
      }
      final debut = DateTime(event.annee, event.mois, 1);
      final fin = DateTime(event.annee, event.mois + 1, 0);
      
      final recettes = await supabaseClient
          .from('finances')
          .select('montant_fcfa')
          .eq('user_id', userId)
          .eq('type', 'RECETTE')
          .gte('date', debut.toIso8601String().split('T')[0])
          .lte('date', fin.toIso8601String().split('T')[0]);
      
      final depenses = await supabaseClient
          .from('finances')
          .select('montant_fcfa')
          .eq('user_id', userId)
          .eq('type', 'DEPENSE')
          .gte('date', debut.toIso8601String().split('T')[0])
          .lte('date', fin.toIso8601String().split('T')[0]);
      
      final totalRecettes = recettes.fold<int>(0, (sum, r) => sum + (r['montant_fcfa'] as int));
      final totalDepenses = depenses.fold<int>(0, (sum, d) => sum + (d['montant_fcfa'] as int));
      
      emit(ResumeMensuelLoaded(
        totalRecettes: totalRecettes,
        totalDepenses: totalDepenses,
        benefice: totalRecettes - totalDepenses,
      ));
    } catch (e) {
      emit(FinanceError(message: e.toString()));
    }
  }
}
