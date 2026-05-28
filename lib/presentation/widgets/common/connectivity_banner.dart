import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lapinia_mobile/l10n/app_localizations.dart';

import '../../providers/core_providers.dart';
import '../../providers/settings_providers.dart';

class ConnectivityBanner extends ConsumerWidget {
  const ConnectivityBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    final isOnline = ref.watch(connectivityStatusProvider).asData?.value ?? true;
    final pending = ref.watch(pendingMutationsProvider).asData?.value ?? 0;

    if (!isOnline) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Material(
          color: colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(Icons.wifi_off, color: colorScheme.onErrorContainer),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.settingsOffline,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: colorScheme.onErrorContainer,
                            ),
                      ),
                      Text(
                        l10n.settingsOfflineHelp,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.onErrorContainer,
                            ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => context.push('/settings'),
                  child: Text(l10n.settingsTitle),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (pending > 0) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Material(
          color: colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(Icons.sync, color: colorScheme.onSecondaryContainer),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.settingsQueueTitle(pending),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSecondaryContainer,
                        ),
                  ),
                ),
                TextButton(
                  onPressed: () async {
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
                  child: Text(l10n.syncNow),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
