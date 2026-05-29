import 'package:flutter/material.dart';
import 'package:lapinia_mobile/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/constants/app_typography.dart';
import '../../../core/constants/enums.dart';
import '../../../core/models/alerte.dart';
import '../../../core/models/dashboard_timeline_event.dart';
import '../../../core/models/lapin.dart';
import '../../../core/models/portee.dart';
import '../../../core/models/planned_event.dart';
import '../../../core/models/rentability_score.dart';
import '../../providers/alerte_provider.dart';
import '../../providers/dashboard_providers.dart';
import '../../providers/lapin_provider.dart';
import '../../providers/portee_provider.dart';
import '../../providers/core_providers.dart';
import '../../providers/settings_providers.dart';
import '../../widgets/common/connectivity_banner.dart';
import '../../widgets/common/loading_widget.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    final lapins = ref.watch(lapinsProvider);
    final portees = ref.watch(porteesProvider);
    final alertesNonLues = ref.watch(alertesNonLuesProvider);
    final advice = ref.watch(dailyAdviceProvider);
    final rentability = ref.watch(rentabilityScoreProvider);
    final timeline = ref.watch(dashboardTimelineProvider);
    final isOnline = ref.watch(connectivityStatusProvider).asData?.value ?? true;
    final pending = ref.watch(pendingMutationsProvider).asData?.value ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: colorScheme.onPrimary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.pets,
                size: 20,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            const Text('lapiNia'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => ref.invalidate(alertesNonLuesProvider),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(lapinsProvider.notifier).refresh();
          await ref.read(porteesProvider.notifier).refresh();
          ref.invalidate(alertesNonLuesProvider);
          ref.invalidate(pendingMutationsProvider);
          ref.invalidate(dailyAdviceProvider);
          ref.invalidate(rentabilityScoreProvider);
          ref.invalidate(dashboardTimelineProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            16 + MediaQuery.of(context).padding.bottom + 72,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ConnectivityBanner(),
              _buildQuickActions(
                context: context,
                ref: ref,
                l10n: l10n,
                isOnline: isOnline,
                pending: pending,
              ),
              const SizedBox(height: 16),
              _buildConseilCard(context: context, l10n: l10n, advice: advice),
              const SizedBox(height: 16),
              _buildRentabilityCard(
                context: context,
                l10n: l10n,
                score: rentability,
                ref: ref,
              ),
              const SizedBox(height: 16),
              _buildKpiGrid(context: context, lapins: lapins, portees: portees),
              const SizedBox(height: 16),
              _buildAlertesSection(
                context: context,
                ref: ref,
                alertes: alertesNonLues,
                l10n: l10n,
              ),
              const SizedBox(height: 16),
              _buildTimelineSection(
                context: context,
                ref: ref,
                timeline: timeline,
                l10n: l10n,
              ),
              const SizedBox(height: 16),
              _buildProchainesPorteesSection(
                portees: portees,
                context: context,
                l10n: l10n,
                ref: ref,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions({
    required BuildContext context,
    required WidgetRef ref,
    required AppLocalizations l10n,
    required bool isOnline,
    required int pending,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.dashboardQuickActions,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
        ),
        const SizedBox(height: 8),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 2.4,
          children: [
            _QuickActionTile(
              icon: Icons.add_circle_outline,
              label: l10n.quickAddLapin,
              onTap: () => context.push('/lapin/new'),
            ),
            _QuickActionTile(
              icon: Icons.child_friendly_outlined,
              label: l10n.quickNewSaillie,
              onTap: () => context.push('/saillie/new'),
            ),
            _QuickActionTile(
              icon: Icons.playlist_add_check_circle_outlined,
              label: l10n.quickRecordEvent,
              onTap: () => _showRecordEventSheet(
                context: context,
                l10n: l10n,
                ref: ref,
                isOnline: isOnline,
              ),
            ),
            _QuickActionTile(
              icon: Icons.sync,
              label: pending > 0 ? l10n.quickSyncPending(pending) : l10n.quickSync,
              onTap: () async {
                if (!isOnline) {
                  context.push('/settings');
                  return;
                }
                if (pending <= 0) {
                  context.push('/settings');
                  return;
                }

                final messenger = ScaffoldMessenger.of(context);
                try {
                  await ref.read(syncManagerProvider).forceSync();
                  ref.invalidate(pendingMutationsProvider);
                  messenger.showSnackBar(
                    SnackBar(content: Text(l10n.syncStarted)),
                  );
                } catch (_) {
                  messenger.showSnackBar(
                    SnackBar(content: Text(l10n.errorGeneric)),
                  );
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _showRecordEventSheet({
    required BuildContext context,
    required AppLocalizations l10n,
    required WidgetRef ref,
    required bool isOnline,
  }) async {
    final rootContext = context;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.monitor_weight_outlined),
                  title: Text(l10n.quickEventWeight),
                  onTap: () {
                    Navigator.of(context).pop();
                    Future<void>.delayed(Duration.zero, () {
                      if (!rootContext.mounted) return;
                      _showQuickWeightSheet(
                        context: rootContext,
                        l10n: l10n,
                        ref: ref,
                        isOnline: isOnline,
                      );
                    });
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.medical_services_outlined),
                  title: Text(l10n.quickEventHealth),
                  onTap: () => Navigator.of(context).pop(),
                ),
                ListTile(
                  leading: const Icon(Icons.inventory_2_outlined),
                  title: Text(l10n.quickEventStock),
                  onTap: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildConseilCard({
    required BuildContext context,
    required AppLocalizations l10n,
    required AsyncValue<String?> advice,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final text = advice.asData?.value;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.secondary, colorScheme.tertiary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.onSecondary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                l10n.dashboardAiTipTitle,
                style: AppTypography.subtitle1.copyWith(
                  color: colorScheme.onSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          advice.when(
            loading: () => Text(
              l10n.loading,
              style: AppTypography.body2.copyWith(
                color: colorScheme.onSecondary.withValues(alpha: 0.9),
              ),
            ),
            error: (_, _) => Text(
              l10n.dashboardAiTipBody,
              style: AppTypography.body2.copyWith(
                color: colorScheme.onSecondary.withValues(alpha: 0.9),
              ),
            ),
            data: (_) => Text(
              (text == null || text.trim().isEmpty)
                  ? l10n.dashboardAiTipBody
                  : text,
              style: AppTypography.body2.copyWith(
                color: colorScheme.onSecondary.withValues(alpha: 0.9),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.wb_sunny,
                color: colorScheme.tertiaryContainer,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                l10n.dashboardAiTipWeather,
                style: AppTypography.caption.copyWith(
                  color: colorScheme.onSecondary.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRentabilityCard({
    required BuildContext context,
    required AppLocalizations l10n,
    required AsyncValue<RentabilityScore> score,
    required WidgetRef ref,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return score.when(
      loading: () => const LoadingWidget(),
      error: (e, _) => ErrorDisplayWidget(
        message: e.toString(),
        onRetry: () => ref.invalidate(rentabilityScoreProvider),
      ),
      data: (data) {
        if (data.actions.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.insights,
                    color: colorScheme.onSecondaryContainer,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.rentabilityTitle,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: colorScheme.onSecondaryContainer,
                          ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      l10n.rentabilityScoreValue(data.score),
                      style: AppTypography.caption.copyWith(
                        color: colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              for (final action in data.actions)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '• ',
                        style: AppTypography.body2.copyWith(
                          color: colorScheme.onSecondaryContainer,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          action,
                          style: AppTypography.body2.copyWith(
                            color: colorScheme.onSecondaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildKpiGrid({
    required BuildContext context,
    required AsyncValue<LapinsListState> lapins,
    required AsyncValue<List<Portee>> portees,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final lapinsList = lapins.asData?.value.items ?? const [];
    final porteesList = portees.asData?.value ?? const [];

    final nbLapins = lapinsList.length;
    final nbGestantes = lapinsList
        .where((l) => l.statut.dbValue == 'EN_GESTATION')
        .length;

    final nbLapereauxAttendus = porteesList
        .where((p) => p.statut.dbValue == 'EN_GESTATION')
        .fold<int>(
          0,
          (sum, p) => sum + (p.mere?.race?.taillePorteeMoyenne?.toInt() ?? 7),
        );

    final nextBirth = porteesList
        .where((p) => p.statut == StatutPortee.enGestation)
        .map((p) => p.dateMiseBasPrevue ?? p.dateSaillie.add(const Duration(days: 31)))
        .where((d) => !d.isBefore(DateTime.now()))
        .fold<DateTime?>(null, (prev, curr) => prev == null || curr.isBefore(prev) ? curr : prev);

    final nextBirthValue = nextBirth == null
        ? l10n.kpiNextBirthNone
        : l10n.kpiNextBirthValue(
            MaterialLocalizations.of(context).formatShortDate(nextBirth),
            nextBirth.difference(DateTime.now()).inDays.clamp(0, 365),
          );

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.85,
      children: [
        _buildKpiCard(
          context: context,
          icon: Icons.pets,
          label: l10n.kpiLapins,
          value: nbLapins.toString(),
          color: colorScheme.primary,
        ),
        _buildKpiCard(
          context: context,
          icon: Icons.pregnant_woman,
          label: l10n.kpiGestantes,
          value: nbGestantes.toString(),
          color: colorScheme.tertiary,
        ),
        _buildKpiCard(
          context: context,
          icon: Icons.child_friendly,
          label: l10n.kpiAttendus,
          value: nbLapereauxAttendus.toString(),
          color: colorScheme.secondary,
        ),
        _buildKpiCard(
          context: context,
          icon: Icons.event,
          label: l10n.kpiNextBirth,
          value: nextBirthValue,
          color: colorScheme.primary,
        ),
      ],
    );
  }

  Widget _buildKpiCard({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 4),
              Text(
                value,
                style: AppTypography.headline3.copyWith(
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                label,
                style: AppTypography.caption.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlertesSection({
    required BuildContext context,
    required WidgetRef ref,
    required AsyncValue<List<Alerte>> alertes,
    required AppLocalizations l10n,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.dashboardAlerts,
              style: AppTypography.headline3.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            TextButton(
              onPressed: () => context.go('/alertes'),
              child: Text(l10n.dashboardSeeAll),
            ),
          ],
        ),
        const SizedBox(height: 8),
        alertes.when(
          loading: () => const LoadingWidget(),
          error: (e, _) => ErrorDisplayWidget(
            message: e.toString(),
            onRetry: () => ref.invalidate(alertesNonLuesProvider),
          ),
          data: (items) {
            if (items.isEmpty) {
              return EmptyStateWidget(
                icon: Icons.check_circle_outline,
                title: l10n.dashboardNoAlerts,
                subtitle: l10n.alertesEmptySubtitle,
                buttonText: l10n.dashboardSeeAll,
                onButtonPressed: () => context.go('/alertes'),
              );
            }

            return Column(
              children: items.take(3).map((alerte) {
                final prio = alerte.priorite.value;
                final accent = _getAlerteColor(colorScheme, prio);
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: accent,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: accent,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              alerte.type.label,
                              style: AppTypography.subtitle2,
                            ),
                            Text(
                              alerte.message,
                              style: AppTypography.caption,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.check_circle_outline),
                        onPressed: () async {
                          await ref
                              .read(alertesControllerProvider.notifier)
                              .markAsActionDone(alerte.id);
                          ref.invalidate(alertesNonLuesProvider);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.done),
                        onPressed: () async {
                          await ref
                              .read(alertesControllerProvider.notifier)
                              .markAsRead(alerte.id);
                          ref.invalidate(alertesNonLuesProvider);
                        },
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Color _getAlerteColor(ColorScheme scheme, int priorite) {
    switch (priorite) {
      case 1:
        return scheme.error;
      case 2:
        return scheme.tertiary;
      default:
        return scheme.primary;
    }
  }

  Widget _buildTimelineSection({
    required BuildContext context,
    required WidgetRef ref,
    required AsyncValue<List<DashboardTimelineEvent>> timeline,
    required AppLocalizations l10n,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.timelineTitle,
              style: AppTypography.headline3.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            IconButton(
              onPressed: () => _showAddPlannedEventSheet(
                context: context,
                ref: ref,
                l10n: l10n,
              ),
              icon: const Icon(Icons.add),
              tooltip: l10n.timelineAdd,
            ),
          ],
        ),
        const SizedBox(height: 8),
        timeline.when(
          loading: () => const LoadingWidget(),
          error: (e, _) => ErrorDisplayWidget(
            message: e.toString(),
            onRetry: () => ref.invalidate(dashboardTimelineProvider),
          ),
          data: (items) {
            if (items.isEmpty) {
              return EmptyStateWidget(
                icon: Icons.event_available,
                title: l10n.timelineEmptyTitle,
                subtitle: l10n.timelineEmptySubtitle,
                buttonText: l10n.timelineAdd,
                onButtonPressed: () => _showAddPlannedEventSheet(
                  context: context,
                  ref: ref,
                  l10n: l10n,
                ),
              );
            }

            return Column(
              children: [
                for (final event in items.take(7))
                  _TimelineTile(
                    event: event,
                    onTap: event.route == null
                        ? null
                        : () => context.push(event.route!),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  Future<void> _showQuickWeightSheet({
    required BuildContext context,
    required AppLocalizations l10n,
    required WidgetRef ref,
    required bool isOnline,
  }) async {
    if (!isOnline) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.quickWeightOffline)),
      );
      return;
    }

    final lapins =
        ref.read(lapinsProvider).asData?.value.items ?? const <Lapin>[];
    if (lapins.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.quickWeightNoLapins)),
      );
      return;
    }

    String selectedId = lapins.first.id;
    final controller = TextEditingController();

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final bottomInset = MediaQuery.of(context).viewInsets.bottom;
            return Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 16 + bottomInset),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.quickWeightTitle,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: selectedId,
                    decoration: InputDecoration(labelText: l10n.quickWeightLapin),
                    items: [
                      for (final l in lapins)
                        DropdownMenuItem(
                          value: l.id,
                          child: Text(l.nom),
                        ),
                    ],
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() => selectedId = v);
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: l10n.quickWeightValueLabel,
                      suffixText: l10n.quickWeightUnit,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () async {
                        final raw = controller.text.trim();
                        final poids = int.tryParse(raw);
                        if (poids == null || poids <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.quickWeightInvalid)),
                          );
                          return;
                        }

                        final messenger = ScaffoldMessenger.of(context);
                        try {
                          await ref.read(lapinsProvider.notifier).recordPesee(
                                lapinId: selectedId,
                                poidsG: poids,
                              );
                          if (!context.mounted) return;
                          Navigator.of(context).pop();
                          messenger.showSnackBar(
                            SnackBar(content: Text(l10n.quickWeightSaved)),
                          );
                        } catch (_) {
                          messenger.showSnackBar(
                            SnackBar(content: Text(l10n.errorGeneric)),
                          );
                        }
                      },
                      child: Text(l10n.quickWeightSave),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showAddPlannedEventSheet({
    required BuildContext context,
    required WidgetRef ref,
    required AppLocalizations l10n,
  }) async {
    final supabase = ref.read(supabaseClientProvider);
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    final lapins =
        ref.read(lapinsProvider).asData?.value.items ?? const <Lapin>[];
    PlannedEventType type = PlannedEventType.weight;
    DateTime date = DateTime.now().add(const Duration(days: 1));
    String? targetId = lapins.isEmpty ? null : lapins.first.id;
    final noteController = TextEditingController();

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final bottomInset = MediaQuery.of(context).viewInsets.bottom;
            final scheme = Theme.of(context).colorScheme;
            return Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 16 + bottomInset),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.timelineAddTitle,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  SegmentedButton<PlannedEventType>(
                    segments: [
                      ButtonSegment(
                        value: PlannedEventType.weight,
                        label: Text(l10n.timelineAddWeight),
                        icon: const Icon(Icons.monitor_weight_outlined),
                      ),
                      ButtonSegment(
                        value: PlannedEventType.vaccine,
                        label: Text(l10n.timelineAddVaccine),
                        icon: const Icon(Icons.medical_services_outlined),
                      ),
                    ],
                    selected: {type},
                    onSelectionChanged: (v) => setState(() => type = v.first),
                  ),
                  const SizedBox(height: 12),
                  if (lapins.isNotEmpty)
                    DropdownButtonFormField<String>(
                      initialValue: targetId,
                      decoration: InputDecoration(labelText: l10n.timelineAddLapin),
                      items: [
                        for (final l in lapins)
                          DropdownMenuItem(value: l.id, child: Text(l.nom)),
                      ],
                      onChanged: (v) => setState(() => targetId = v),
                    ),
                  if (lapins.isNotEmpty) const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.event, color: scheme.onSurfaceVariant),
                    title: Text(l10n.timelineAddDate),
                    subtitle: Text(
                      MaterialLocalizations.of(context).formatFullDate(date),
                    ),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: date,
                        firstDate: DateTime.now().subtract(const Duration(days: 1)),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (!context.mounted) return;
                      if (picked == null) return;
                      setState(() => date = picked);
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: noteController,
                    decoration: InputDecoration(
                      labelText: l10n.timelineAddNote,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        try {
                          await ref.read(plannedEventsServiceProvider).create(
                                userId: userId,
                                type: type,
                                date: date,
                                targetId: targetId,
                                note: noteController.text.trim().isEmpty
                                    ? null
                                    : noteController.text.trim(),
                              );
                          ref.invalidate(plannedEventsNext7DaysProvider);
                          ref.invalidate(dashboardTimelineProvider);
                          if (!context.mounted) return;
                          Navigator.of(context).pop();
                          messenger.showSnackBar(
                            SnackBar(content: Text(l10n.timelineAddSaved)),
                          );
                        } catch (_) {
                          messenger.showSnackBar(
                            SnackBar(content: Text(l10n.errorGeneric)),
                          );
                        }
                      },
                      child: Text(l10n.timelineAddSave),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildProchainesPorteesSection({
    required AsyncValue<List<Portee>> portees,
    required BuildContext context,
    required AppLocalizations l10n,
    required WidgetRef ref,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.dashboardNextBirths,
              style: AppTypography.headline3.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            TextButton(
              onPressed: () => context.go('/portees'),
              child: Text(l10n.dashboardSeeAllPortees),
            ),
          ],
        ),
        const SizedBox(height: 8),
        portees.when(
          loading: () => const LoadingWidget(),
          error: (e, _) => ErrorDisplayWidget(
            message: e.toString(),
            onRetry: () => ref.read(porteesProvider.notifier).refresh(),
          ),
          data: (items) {
            final gestantes = items
                .where((p) => p.statut.dbValue == 'EN_GESTATION')
                .toList();

            if (gestantes.isEmpty) {
              return EmptyStateWidget(
                icon: Icons.child_friendly_outlined,
                title: l10n.dashboardNoGestation,
                subtitle: l10n.porteesEmptySubtitle,
                buttonText: l10n.porteesEmptyAction,
                onButtonPressed: () => context.push('/saillie/new'),
              );
            }

            return Column(
              children: gestantes.take(3).map((portee) {
                final joursEcoules = portee.joursGestationEcoules ?? 0;
                final joursRestants = 31 - joursEcoules;
                final progressColor = _getProgressColor(colorScheme, joursEcoules);

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Icon(
                          Icons.child_friendly,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              portee.mere?.nom ?? l10n.dashboardUnknownMother,
                              style: AppTypography.subtitle2,
                            ),
                            Text(
                              l10n.dashboardGestationProgress(joursEcoules, joursRestants),
                              style: AppTypography.caption,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: progressColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${((joursEcoules / 31) * 100).toInt()}%',
                          style: AppTypography.caption.copyWith(
                            color: _onProgressColor(colorScheme, progressColor),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Color _getProgressColor(ColorScheme scheme, int jours) {
    if (jours >= 28) return scheme.error;
    if (jours >= 21) return scheme.tertiary;
    return scheme.primary;
  }

  Color _onProgressColor(ColorScheme scheme, Color progressColor) {
    if (progressColor == scheme.error) return scheme.onError;
    if (progressColor == scheme.tertiary) return scheme.onTertiary;
    return scheme.onPrimary;
  }
}

class _QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(icon, color: colorScheme.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimelineTile extends StatelessWidget {
  final DashboardTimelineEvent event;
  final VoidCallback? onTap;

  const _TimelineTile({
    required this.event,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final dateText = MaterialLocalizations.of(context).formatShortDate(event.date);

    final (IconData icon, String title, String subtitle, Color accent) = switch (event.type) {
      'birth' => (
          Icons.child_friendly,
          l10n.timelineBirthTitle(event.primary ?? l10n.dashboardUnknownMother),
          l10n.timelineBirthSubtitle,
          scheme.primary,
        ),
      'vaccine' => (
          Icons.medical_services_outlined,
          l10n.timelineVaccineTitle,
          event.primary ?? l10n.timelineVaccineSubtitle,
          scheme.tertiary,
        ),
      _ => (
          Icons.monitor_weight_outlined,
          l10n.timelineWeightTitle,
          event.primary ?? l10n.timelineWeightSubtitle,
          scheme.secondary,
        ),
    };

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: accent),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: scheme.onSurface,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              dateText,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
