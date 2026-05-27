import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/models/alerte.dart';

part 'alerte_event.dart';
part 'alerte_state.dart';

class AlerteBloc extends Bloc<AlerteEvent, AlerteState> {
  final SupabaseClient supabaseClient;

  AlerteBloc({required this.supabaseClient}) : super(AlerteInitial()) {
    on<AlertesLoadRequested>(_onLoadRequested);
    on<AlertesNonLuesLoadRequested>(_onNonLuesLoadRequested);
    on<AlerteMarkAsReadRequested>(_onMarkAsReadRequested);
    on<AlerteMarkAsActionDoneRequested>(_onMarkAsActionDoneRequested);
    on<AlerteCreateRequested>(_onCreateRequested);
  }

  Future<void> _onLoadRequested(
    AlertesLoadRequested event,
    Emitter<AlerteState> emit,
  ) async {
    emit(AlertesLoading());
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        emit(const AlerteError(message: 'User not authenticated'));
        return;
      }
      final response = await supabaseClient
          .from('alertes')
          .select('*, lapins(*)')
          .eq('user_id', userId)
          .order('priorite')
          .order('created_at', ascending: false);
      
      final alertes = (response as List)
          .map((json) => Alerte.fromJson(json))
          .toList();
      
      emit(AlertesLoaded(alertes: alertes));
    } catch (e) {
      emit(AlerteError(message: e.toString()));
    }
  }

  Future<void> _onNonLuesLoadRequested(
    AlertesNonLuesLoadRequested event,
    Emitter<AlerteState> emit,
  ) async {
    emit(AlertesLoading());
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        emit(const AlerteError(message: 'User not authenticated'));
        return;
      }
      final response = await supabaseClient
          .from('alertes')
          .select('*, lapins(*)')
          .eq('user_id', userId)
          .eq('lue', false)
          .order('priorite')
          .order('created_at', ascending: false);
      
      final alertes = (response as List)
          .map((json) => Alerte.fromJson(json))
          .toList();
      
      emit(AlertesLoaded(alertes: alertes));
    } catch (e) {
      emit(AlerteError(message: e.toString()));
    }
  }

  Future<void> _onMarkAsReadRequested(
    AlerteMarkAsReadRequested event,
    Emitter<AlerteState> emit,
  ) async {
    try {
      await supabaseClient
          .from('alertes')
          .update({'lue': true})
          .eq('id', event.id);
      
      emit(AlerteUpdated());
      add(AlertesLoadRequested());
    } catch (e) {
      emit(AlerteError(message: e.toString()));
    }
  }

  Future<void> _onMarkAsActionDoneRequested(
    AlerteMarkAsActionDoneRequested event,
    Emitter<AlerteState> emit,
  ) async {
    try {
      await supabaseClient
          .from('alertes')
          .update({
            'action_effectuee': true,
            'lue': true,
          })
          .eq('id', event.id);
      
      emit(AlerteUpdated());
      add(AlertesLoadRequested());
    } catch (e) {
      emit(AlerteError(message: e.toString()));
    }
  }

  Future<void> _onCreateRequested(
    AlerteCreateRequested event,
    Emitter<AlerteState> emit,
  ) async {
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      
      if (userId == null) {
        emit(const AlerteError(message: 'User not authenticated'));
        return;
      }

      final data = {
        'id': event.alerte.id,
        'user_id': userId,
        'lapin_id': event.alerte.lapinId,
        'type': event.alerte.type.dbValue,
        'message': event.alerte.message,
        'priorite': event.alerte.priorite.value,
        'date_echeance': event.alerte.dateEcheance?.toIso8601String(),
      };

      await supabaseClient
          .from('alertes')
          .insert(data);
      
      emit(AlerteCreated());
      add(AlertesLoadRequested());
    } catch (e) {
      emit(AlerteError(message: e.toString()));
    }
  }
}
