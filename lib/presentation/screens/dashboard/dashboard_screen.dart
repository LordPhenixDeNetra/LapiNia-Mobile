import 'package:flutter/material.dart';
import 'package:lapinia_mobile/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/constants/app_typography.dart';
import '../../../core/models/alerte.dart';
import '../../../core/models/lapin.dart';
import '../../../core/models/portee.dart';
import '../../providers/alerte_provider.dart';
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
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
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
              _buildConseilCard(context: context, l10n: l10n),
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
              onTap: () => _showRecordEventSheet(context: context, l10n: l10n),
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
  }) async {
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
                  onTap: () => Navigator.of(context).pop(),
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
  }) {
    final colorScheme = Theme.of(context).colorScheme;
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
          Text(
            l10n.dashboardAiTipBody,
            style: AppTypography.body2.copyWith(
              color: colorScheme.onSecondary.withValues(alpha: 0.9),
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

  Widget _buildKpiGrid({
    required BuildContext context,
    required AsyncValue<List<Lapin>> lapins,
    required AsyncValue<List<Portee>> portees,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final lapinsList = lapins.asData?.value ?? const [];
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

    return Row(
      children: [
        Expanded(
          child: _buildKpiCard(
            context: context,
            icon: Icons.pets,
            label: l10n.kpiLapins,
            value: nbLapins.toString(),
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildKpiCard(
            context: context,
            icon: Icons.pregnant_woman,
            label: l10n.kpiGestantes,
            value: nbGestantes.toString(),
            color: colorScheme.tertiary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildKpiCard(
            context: context,
            icon: Icons.child_friendly,
            label: l10n.kpiAttendus,
            value: nbLapereauxAttendus.toString(),
            color: colorScheme.secondary,
          ),
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTypography.headline3.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
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
