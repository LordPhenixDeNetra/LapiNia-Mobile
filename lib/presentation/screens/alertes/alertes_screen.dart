import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lapinia_mobile/l10n/app_localizations.dart';

import '../../providers/alerte_provider.dart';
import '../../widgets/common/connectivity_banner.dart';
import '../../widgets/common/loading_widget.dart';

enum _AlertFilter { unread, all }

class AlertesScreen extends HookConsumerWidget {
  const AlertesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    final filter = useState(_AlertFilter.unread);
    final asyncAlertes = ref.watch(alertesControllerProvider);

    Future<void> refresh() async {
      final notifier = ref.read(alertesControllerProvider.notifier);
      if (filter.value == _AlertFilter.unread) {
        await notifier.refreshUnread();
      } else {
        await notifier.refreshAll();
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.alertesTitle),
      ),
      body: Column(
        children: [
          const ConnectivityBanner(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: SegmentedButton<_AlertFilter>(
                segments: [
                  ButtonSegment(
                    value: _AlertFilter.unread,
                    label: Text(l10n.alertesFilterUnread),
                  ),
                  ButtonSegment(
                    value: _AlertFilter.all,
                    label: Text(l10n.alertesFilterAll),
                  ),
                ],
                selected: {filter.value},
                onSelectionChanged: (selection) {
                  filter.value = selection.first;
                  refresh();
                },
              ),
            ),
          ),
          Expanded(
            child: asyncAlertes.when(
              loading: () => const LoadingWidget(),
              error: (e, _) => ErrorDisplayWidget(
                message: e.toString(),
                onRetry: refresh,
              ),
              data: (items) {
                final shown = filter.value == _AlertFilter.unread
                    ? items.where((a) => !a.lue).toList()
                    : items;

                if (shown.isEmpty) {
                  return EmptyStateWidget(
                    icon: Icons.notifications_outlined,
                    title: l10n.alertesEmptyTitle,
                    subtitle: l10n.alertesEmptySubtitle,
                  );
                }

                return RefreshIndicator(
                  onRefresh: refresh,
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: shown.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final alerte = shown[index];
                      final accent = _priorityColor(colorScheme, alerte.priorite.value);

                      return Card(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            final id = alerte.lapinId;
                            if (id == null) return;
                            context.push('/lapin/$id');
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  margin: const EdgeInsets.only(top: 6),
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
                                        style: Theme.of(context).textTheme.titleSmall,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        alerte.message,
                                        style: Theme.of(context).textTheme.bodyMedium,
                                      ),
                                      if (alerte.lapin != null) ...[
                                        const SizedBox(height: 6),
                                        Text(
                                          alerte.lapin!.nom,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(color: colorScheme.onSurfaceVariant),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (!alerte.actionEffectuee)
                                      IconButton(
                                        tooltip: l10n.alertesActionDone,
                                        icon: Icon(Icons.check_circle_outline, color: accent),
                                        onPressed: () async {
                                          final messenger = ScaffoldMessenger.of(context);
                                          try {
                                            await ref
                                                .read(alertesControllerProvider.notifier)
                                                .markAsActionDone(alerte.id);
                                          } catch (_) {
                                            messenger.showSnackBar(
                                              SnackBar(content: Text(l10n.errorGeneric)),
                                            );
                                          }
                                        },
                                      ),
                                    if (!alerte.lue)
                                      IconButton(
                                        tooltip: l10n.alertesMarkRead,
                                        icon: Icon(Icons.done, color: colorScheme.onSurfaceVariant),
                                        onPressed: () async {
                                          final messenger = ScaffoldMessenger.of(context);
                                          try {
                                            await ref
                                                .read(alertesControllerProvider.notifier)
                                                .markAsRead(alerte.id);
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
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _priorityColor(ColorScheme scheme, int priorite) {
    switch (priorite) {
      case 1:
        return scheme.error;
      case 2:
        return scheme.tertiary;
      default:
        return scheme.primary;
    }
  }
}
