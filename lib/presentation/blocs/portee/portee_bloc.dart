import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/models/portee.dart';

part 'portee_event.dart';
part 'portee_state.dart';

class PorteeBloc extends Bloc<PorteeEvent, PorteeState> {
  final SupabaseClient supabaseClient;

  PorteeBloc({required this.supabaseClient}) : super(PorteeInitial()) {
    on<PorteesLoadRequested>(_onLoadRequested);
    on<PorteeLoadRequested>(_onSingleLoadRequested);
    on<PorteeCreateRequested>(_onCreateRequested);
    on<PorteeUpdateRequested>(_onUpdateRequested);
    on<SaillieCreateRequested>(_onSaillieCreateRequested);
    on<MiseBasRecordRequested>(_onMiseBasRecordRequested);
    on<SevrageRecordRequested>(_onSevrageRecordRequested);
  }

  Future<void> _onLoadRequested(
    PorteesLoadRequested event,
    Emitter<PorteeState> emit,
  ) async {
    emit(PorteesLoading());
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        emit(const PorteeError(message: 'User not authenticated'));
        return;
      }
      final response = await supabaseClient
          .from('portees')
          .select('*, lapins_mere:lapins!mere_id(*), lapins_pere:lapins!pere_id(*)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      
      final portees = (response as List)
          .map((json) => Portee.fromJson(json))
          .toList();
      
      emit(PorteesLoaded(portees: portees));
    } catch (e) {
      emit(PorteeError(message: e.toString()));
    }
  }

  Future<void> _onSingleLoadRequested(
    PorteeLoadRequested event,
    Emitter<PorteeState> emit,
  ) async {
    emit(PorteeLoading());
    try {
      final response = await supabaseClient
          .from('portees')
          .select('*, lapins_mere:lapins!mere_id(*), lapins_pere:lapins!pere_id(*)')
          .eq('id', event.id)
          .single();
      
      final portee = Portee.fromJson(response);
      emit(PorteeLoaded(portee: portee));
    } catch (e) {
      emit(PorteeError(message: e.toString()));
    }
  }

  Future<void> _onCreateRequested(
    PorteeCreateRequested event,
    Emitter<PorteeState> emit,
  ) async {
    emit(PorteeSaving());
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      
      if (userId == null) {
        emit(const PorteeError(message: 'User not authenticated'));
        return;
      }

      final dateMiseBasPrevue = event.portee.dateSaillie.add(const Duration(days: 31));

      final data = {
        'id': event.portee.id,
        'user_id': userId,
        'mere_id': event.portee.mereId,
        'pere_id': event.portee.pereId,
        'date_saillie': event.portee.dateSaillie.toIso8601String().split('T')[0],
        'date_mise_bas_prevue': dateMiseBasPrevue.toIso8601String().split('T')[0],
        'statut': event.portee.statut.dbValue,
        'notes': event.portee.notes,
      };

      await supabaseClient
          .from('portees')
          .insert(data);

      await supabaseClient
          .from('lapins')
          .update({'statut': 'EN_GESTATION'})
          .eq('id', event.portee.mereId);

      emit(PorteeCreated(portee: event.portee));
      add(PorteesLoadRequested());
    } catch (e) {
      emit(PorteeError(message: e.toString()));
    }
  }

  Future<void> _onUpdateRequested(
    PorteeUpdateRequested event,
    Emitter<PorteeState> emit,
  ) async {
    emit(PorteeSaving());
    try {
      final data = event.portee.toJson();
      
      await supabaseClient
          .from('portees')
          .update(data)
          .eq('id', event.portee.id);
      
      emit(PorteeUpdated(portee: event.portee));
      add(PorteesLoadRequested());
    } catch (e) {
      emit(PorteeError(message: e.toString()));
    }
  }

  Future<void> _onSaillieCreateRequested(
    SaillieCreateRequested event,
    Emitter<PorteeState> emit,
  ) async {
    emit(PorteeSaving());
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      
      if (userId == null) {
        emit(const PorteeError(message: 'User not authenticated'));
        return;
      }

      final dateMiseBasPrevue = event.dateSaillie.add(const Duration(days: 31));

      final porteeData = {
        'id': event.porteeId,
        'user_id': userId,
        'mere_id': event.mereId,
        'pere_id': event.mereId,
        'date_saillie': event.dateSaillie.toIso8601String().split('T')[0],
        'date_mise_bas_prevue': dateMiseBasPrevue.toIso8601String().split('T')[0],
        'statut': 'EN_GESTATION',
      };

      await supabaseClient
          .from('portees')
          .insert(porteeData);

      await supabaseClient
          .from('lapins')
          .update({'statut': 'EN_GESTATION'})
          .eq('id', event.mereId);

      emit(SaillieRecorded());
      add(PorteesLoadRequested());
    } catch (e) {
      emit(PorteeError(message: e.toString()));
    }
  }

  Future<void> _onMiseBasRecordRequested(
    MiseBasRecordRequested event,
    Emitter<PorteeState> emit,
  ) async {
    emit(PorteeSaving());
    try {
      await supabaseClient
          .from('portees')
          .update({
            'date_mise_bas_reelle': event.dateMiseBas.toIso8601String().split('T')[0],
            'nb_vivants': event.nbVivants,
            'nb_morts': event.nbMorts,
            'poids_total_portee_g': event.poidsTotalG,
            'statut': 'LACTATION',
          })
          .eq('id', event.porteeId);

      await supabaseClient
          .from('lapins')
          .update({'statut': 'LACTATION'})
          .eq('id', event.mereId);

      emit(MiseBasRecorded());
      add(PorteesLoadRequested());
    } catch (e) {
      emit(PorteeError(message: e.toString()));
    }
  }

  Future<void> _onSevrageRecordRequested(
    SevrageRecordRequested event,
    Emitter<PorteeState> emit,
  ) async {
    emit(PorteeSaving());
    try {
      await supabaseClient
          .from('portees')
          .update({'statut': 'SEVRAGE'})
          .eq('id', event.porteeId);

      await supabaseClient
          .from('lapins')
          .update({'statut': 'REPOS'})
          .eq('id', event.mereId);

      emit(SevrageRecorded());
      add(PorteesLoadRequested());
    } catch (e) {
      emit(PorteeError(message: e.toString()));
    }
  }
}
