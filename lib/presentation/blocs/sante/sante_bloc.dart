import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/models/evenement_sante.dart';

part 'sante_event.dart';
part 'sante_state.dart';

class SanteBloc extends Bloc<SanteEvent, SanteState> {
  final SupabaseClient supabaseClient;

  SanteBloc({required this.supabaseClient}) : super(SanteInitial()) {
    on<SanteLoadRequested>(_onLoadRequested);
    on<SanteByLapinLoadRequested>(_onByLapinLoadRequested);
    on<EvenementSanteCreateRequested>(_onCreateRequested);
    on<TraitementTerminerRequested>(_onTerminerRequested);
  }

  Future<void> _onLoadRequested(
    SanteLoadRequested event,
    Emitter<SanteState> emit,
  ) async {
    emit(SanteLoading());
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        emit(const SanteError(message: 'User not authenticated'));
        return;
      }
      final response = await supabaseClient
          .from('sante')
          .select('*, lapins(*), medicaments(*)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      
      final evenements = (response as List)
          .map((json) => EvenementSante.fromJson(json))
          .toList();
      
      emit(SanteLoaded(evenements: evenements));
    } catch (e) {
      emit(SanteError(message: e.toString()));
    }
  }

  Future<void> _onByLapinLoadRequested(
    SanteByLapinLoadRequested event,
    Emitter<SanteState> emit,
  ) async {
    emit(SanteLoading());
    try {
      final response = await supabaseClient
          .from('sante')
          .select('*, medicaments(*)')
          .eq('lapin_id', event.lapinId)
          .order('created_at', ascending: false);
      
      final evenements = (response as List)
          .map((json) => EvenementSante.fromJson(json))
          .toList();
      
      emit(SanteLoaded(evenements: evenements));
    } catch (e) {
      emit(SanteError(message: e.toString()));
    }
  }

  Future<void> _onCreateRequested(
    EvenementSanteCreateRequested event,
    Emitter<SanteState> emit,
  ) async {
    emit(SanteSaving());
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      
      if (userId == null) {
        emit(const SanteError(message: 'User not authenticated'));
        return;
      }

      final data = {
        'id': event.evenement.id,
        'user_id': userId,
        'lapin_id': event.evenement.lapinId,
        'date': event.evenement.date.toIso8601String().split('T')[0],
        'type': event.evenement.type.dbValue,
        'description': event.evenement.description,
        'medicament_id': event.evenement.medicamentId,
        'dosage_ml': event.evenement.dosageMl,
        'duree_jours': event.evenement.dureeJours,
        'statut': event.evenement.statut.dbValue,
      };

      await supabaseClient.from('sante').insert(data);
      
      emit(EvenementSanteCreated());
      add(SanteLoadRequested());
    } catch (e) {
      emit(SanteError(message: e.toString()));
    }
  }

  Future<void> _onTerminerRequested(
    TraitementTerminerRequested event,
    Emitter<SanteState> emit,
  ) async {
    try {
      await supabaseClient
          .from('sante')
          .update({'statut': 'TERMINE'})
          .eq('id', event.evenementId);
      
      emit(TraitementTermine());
      add(SanteLoadRequested());
    } catch (e) {
      emit(SanteError(message: e.toString()));
    }
  }
}
