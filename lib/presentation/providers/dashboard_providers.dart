import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/constants/enums.dart';
import '../../core/models/dashboard_timeline_event.dart';
import '../../core/models/planned_event.dart';
import '../../core/models/rentability_score.dart';
import 'core_providers.dart';
import 'lapin_provider.dart';
import 'portee_provider.dart';
import 'settings_providers.dart';

final dailyAdviceProvider = FutureProvider<String?>((ref) async {
  final supabase = ref.read(supabaseClientProvider);
  final userId = supabase.auth.currentUser?.id;
  if (userId == null) return null;

  final profileService = ref.read(onboardingProfileServiceProvider);
  final profile = await profileService.getProfile();

  final lapins = await ref.watch(lapinsProvider.future);
  final portees = await ref.watch(porteesProvider.future);

  final gestantesCount =
      lapins.where((l) => l.statut == StatutLapin.enGestation).length;
  final context = <String, dynamic>{
    if (profile != null) ...profile.toJson(),
    'lapins_count': lapins.length,
    'portees_count': portees.length,
    'gestantes_count': gestantesCount,
  };

  return ref.read(dailyAdviceServiceProvider).getAdvice(
        userId: userId,
        context: context,
      );
});

final rentabilityScoreProvider = FutureProvider<RentabilityScore>((ref) async {
  final supabase = ref.read(supabaseClientProvider);
  final userId = supabase.auth.currentUser?.id;
  if (userId == null) {
    return const RentabilityScore(score: 0, actions: <String>[]);
  }

  final lapins = await ref.watch(lapinsProvider.future);
  final portees = await ref.watch(porteesProvider.future);
  final pending = ref.watch(pendingMutationsProvider).asData?.value ?? 0;
  final isOnline = ref.watch(connectivityStatusProvider).asData?.value ?? true;

  final gestantesCount =
      lapins.where((l) => l.statut == StatutLapin.enGestation).length;

  final context = <String, dynamic>{
    'lapins_count': lapins.length,
    'portees_count': portees.length,
    'gestantes_count': gestantesCount,
  };

  return ref.read(rentabilityServiceProvider).getScore(
        isOnline: isOnline,
        userId: userId,
        context: context,
        pendingMutations: pending,
      );
});

final plannedEventsNext7DaysProvider = FutureProvider<List<PlannedEventModel>>((ref) async {
  final supabase = ref.read(supabaseClientProvider);
  final userId = supabase.auth.currentUser?.id;
  if (userId == null) return const [];

  final now = DateTime.now();
  final start = DateTime(now.year, now.month, now.day);
  final end = start.add(const Duration(days: 7));
  return ref.read(plannedEventsServiceProvider).listRange(
        userId: userId,
        start: start,
        end: end,
      );
});

final dashboardTimelineProvider =
    FutureProvider<List<DashboardTimelineEvent>>((ref) async {
  final now = DateTime.now();
  final start = DateTime(now.year, now.month, now.day);
  final end = start.add(const Duration(days: 7));

  final portees = await ref.watch(porteesProvider.future);
  final planned = await ref.watch(plannedEventsNext7DaysProvider.future);

  final events = <DashboardTimelineEvent>[];

  for (final p in portees.where((p) => p.statut == StatutPortee.enGestation)) {
    final due = p.dateMiseBasPrevue ?? p.dateSaillie.add(const Duration(days: 31));
    if (due.isBefore(start) || due.isAfter(end)) continue;

    events.add(
      DashboardTimelineEvent(
        date: due,
        primary: p.mere?.nom,
        route: '/portee/${p.id}',
        type: 'birth',
      ),
    );
  }

  for (final e in planned) {
    switch (e.type) {
      case PlannedEventType.weight:
        events.add(
          DashboardTimelineEvent(
            date: e.date,
            primary: e.note,
            route: e.targetId != null ? '/lapin/${e.targetId}' : null,
            type: 'weight',
          ),
        );
      case PlannedEventType.vaccine:
        events.add(
          DashboardTimelineEvent(
            date: e.date,
            primary: e.note,
            route: e.targetId != null ? '/lapin/${e.targetId}' : null,
            type: 'vaccine',
          ),
        );
    }
  }

  events.sort((a, b) => a.date.compareTo(b.date));
  return events;
});
