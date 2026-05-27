import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/models/lapin.dart';
import '../../../core/models/race.dart';
import '../../../core/utils/sync_manager.dart';
import '../../../core/utils/idempotency_key.dart';

part 'lapin_event.dart';
part 'lapin_state.dart';

class LapinBloc extends Bloc<LapinEvent, LapinState> {
  final SupabaseClient supabaseClient;
  final SyncManager syncManager;

  LapinBloc({
    required this.supabaseClient,
    required this.syncManager,
  }) : super(LapinInitial()) {
    on<LapinsLoadRequested>(_onLoadRequested);
    on<LapinLoadRequested>(_onSingleLoadRequested);
    on<LapinCreateRequested>(_onCreateRequested);
    on<LapinUpdateRequested>(_onUpdateRequested);
    on<LapinDeleteRequested>(_onDeleteRequested);
    on<LapinPeserRequested>(_onPeserRequested);
    on<RacesLoadRequested>(_onRacesLoadRequested);
  }

  Future<void> _onLoadRequested(
    LapinsLoadRequested event,
    Emitter<LapinState> emit,
  ) async {
    emit(LapinsLoading());
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        emit(const LapinError(message: 'User not authenticated'));
        return;
      }
      final response = await supabaseClient
          .from('lapins')
          .select('*, races(*)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      
      final lapins = (response as List)
          .map((json) => Lapin.fromJson(json))
          .toList();
      
      emit(LapinsLoaded(lapins: lapins));
    } catch (e) {
      emit(LapinError(message: e.toString()));
    }
  }

  Future<void> _onSingleLoadRequested(
    LapinLoadRequested event,
    Emitter<LapinState> emit,
  ) async {
    emit(LapinLoading());
    try {
      final response = await supabaseClient
          .from('lapins')
          .select('*, races(*), pesees(*), sante(*), genealogie(*)')
          .eq('id', event.id)
          .single();
      
      final lapin = Lapin.fromJson(response);
      emit(LapinLoaded(lapin: lapin));
    } catch (e) {
      emit(LapinError(message: e.toString()));
    }
  }

  Future<void> _onCreateRequested(
    LapinCreateRequested event,
    Emitter<LapinState> emit,
  ) async {
    emit(LapinSaving());
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      
      if (userId == null) {
        emit(const LapinError(message: 'User not authenticated'));
        return;
      }

      final data = {
        'id': event.lapin.id,
        'user_id': userId,
        'nom': event.lapin.nom,
        'race_id': event.lapin.raceId,
        'sexe': event.lapin.sexe.dbValue,
        'date_naissance': event.lapin.dateNaissance?.toIso8601String().split('T')[0],
        'poids_actuel_g': event.lapin.poidsActuelG,
        'statut': event.lapin.statut.dbValue,
        'numero_identification': event.lapin.numeroIdentification,
        'photo_url': event.lapin.photoUrl,
        'notes': event.lapin.notes,
      };

      await syncManager.addMutation(
        tableName: 'lapins',
        operation: MutationType.insert,
        payload: data.toString(),
      );

      final response = await supabaseClient
          .from('lapins')
          .insert(data)
          .select('*, races(*)')
          .single();
      
      final lapin = Lapin.fromJson(response);
      emit(LapinCreated(lapin: lapin));
      add(LapinsLoadRequested());
    } catch (e) {
      emit(LapinError(message: e.toString()));
    }
  }

  Future<void> _onUpdateRequested(
    LapinUpdateRequested event,
    Emitter<LapinState> emit,
  ) async {
    emit(LapinSaving());
    try {
      final data = event.lapin.toJson();
      data['updated_at'] = DateTime.now().toIso8601String();
      
      await supabaseClient
          .from('lapins')
          .update(data)
          .eq('id', event.lapin.id);
      
      final response = await supabaseClient
          .from('lapins')
          .select('*, races(*)')
          .eq('id', event.lapin.id)
          .single();
      
      final lapin = Lapin.fromJson(response);
      emit(LapinUpdated(lapin: lapin));
      add(LapinsLoadRequested());
    } catch (e) {
      emit(LapinError(message: e.toString()));
    }
  }

  Future<void> _onDeleteRequested(
    LapinDeleteRequested event,
    Emitter<LapinState> emit,
  ) async {
    emit(LapinSaving());
    try {
      await supabaseClient
          .from('lapins')
          .delete()
          .eq('id', event.id);
      
      emit(LapinDeleted());
      add(LapinsLoadRequested());
    } catch (e) {
      emit(LapinError(message: e.toString()));
    }
  }

  Future<void> _onPeserRequested(
    LapinPeserRequested event,
    Emitter<LapinState> emit,
  ) async {
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      
      if (userId == null) {
        emit(const LapinError(message: 'User not authenticated'));
        return;
      }

      final peseeData = {
        'id': IdempotencyKey.generate(),
        'lapin_id': event.lapinId,
        'user_id': userId,
        'date': DateTime.now().toIso8601String().split('T')[0],
        'poids_g': event.poidsG,
      };

      await supabaseClient
          .from('pesees')
          .insert(peseeData);

      await supabaseClient
          .from('lapins')
          .update({'poids_actuel_g': event.poidsG})
          .eq('id', event.lapinId);
      
      emit(PeseeRecorded());
      add(LapinLoadRequested(id: event.lapinId));
    } catch (e) {
      emit(LapinError(message: e.toString()));
    }
  }

  Future<void> _onRacesLoadRequested(
    RacesLoadRequested event,
    Emitter<LapinState> emit,
  ) async {
    try {
      final response = await supabaseClient
          .from('races')
          .select()
          .order('nom');
      
      final races = (response as List)
          .map((json) => Race.fromJson(json))
          .toList();
      
      emit(RacesLoaded(races: races));
    } catch (e) {
      emit(LapinError(message: e.toString()));
    }
  }
}
