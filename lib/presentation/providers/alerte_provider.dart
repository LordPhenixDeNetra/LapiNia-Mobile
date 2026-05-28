import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/models/alerte.dart';
import '../../core/utils/error_mapper.dart';
import 'core_providers.dart';

class AlertesController extends AsyncNotifier<List<Alerte>> {
  @override
  FutureOr<List<Alerte>> build() async {
    return _load(includeRead: true);
  }

  Future<List<Alerte>> _load({required bool includeRead}) async {
    final supabase = ref.read(supabaseClientProvider);
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return [];

    var q = supabase
        .from('alertes')
        .select('*, lapins(*)')
        .eq('user_id', userId);

    if (!includeRead) {
      q = q.eq('lue', false);
    }

    try {
      final response =
          await q.order('priorite').order('created_at', ascending: false);
      return (response as List).map((e) => Alerte.fromJson(e)).toList();
    } catch (e) {
      throw humanizeError(e as Object);
    }
  }

  Future<void> refreshAll() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _load(includeRead: true));
  }

  Future<void> refreshUnread() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _load(includeRead: false));
  }

  Future<void> markAsRead(String id) async {
    final supabase = ref.read(supabaseClientProvider);
    try {
      await supabase.from('alertes').update({'lue': true}).eq('id', id);
      await refreshAll();
    } catch (e) {
      throw humanizeError(e as Object);
    }
  }

  Future<void> markAsActionDone(String id) async {
    final supabase = ref.read(supabaseClientProvider);
    try {
      await supabase
          .from('alertes')
          .update({'action_effectuee': true, 'lue': true})
          .eq('id', id);
      await refreshAll();
    } catch (e) {
      throw humanizeError(e as Object);
    }
  }
}

final alertesControllerProvider =
    AsyncNotifierProvider<AlertesController, List<Alerte>>(AlertesController.new);

final alertesNonLuesProvider = FutureProvider<List<Alerte>>((ref) async {
  final supabase = ref.read(supabaseClientProvider);
  final userId = supabase.auth.currentUser?.id;
  if (userId == null) return [];

  try {
    final response = await supabase
        .from('alertes')
        .select('*, lapins(*)')
        .eq('user_id', userId)
        .eq('lue', false)
        .order('priorite')
        .order('created_at', ascending: false);

    return (response as List).map((e) => Alerte.fromJson(e)).toList();
  } catch (e) {
    throw humanizeError(e as Object);
  }
});
