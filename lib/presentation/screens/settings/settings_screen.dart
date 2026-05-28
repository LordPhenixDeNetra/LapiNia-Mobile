import 'package:flutter/material.dart';
import 'package:lapinia_mobile/l10n/app_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../providers/settings_providers.dart';
import '../../providers/theme_provider.dart';
import '../../providers/core_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    final connectivity = ref.watch(connectivityStatusProvider);
    final pendingMutations = ref.watch(pendingMutationsProvider);
    final themeMode = ref.watch(themeModeProvider).asData?.value ?? ThemeMode.system;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.settingsConnection, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: connectivity.when(
              loading: () => const ListTile(
                leading: CircularProgressIndicator(),
                title: Text('...'),
              ),
              error: (e, _) => ListTile(
                leading: const Icon(Icons.wifi_off),
                title: Text(l10n.settingsStatusUnknown),
                subtitle: Text(e.toString()),
              ),
              data: (isOnline) => ListTile(
                leading: Icon(isOnline ? Icons.wifi : Icons.wifi_off),
                title: Text(isOnline ? l10n.settingsOnline : l10n.settingsOffline),
                subtitle: Text(
                  isOnline
                      ? l10n.settingsOnlineHelp
                      : l10n.settingsOfflineHelp,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(l10n.settingsSync, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: pendingMutations.when(
              loading: () => const ListTile(
                leading: CircularProgressIndicator(),
                title: Text('...'),
              ),
              error: (e, _) => ListTile(
                leading: const Icon(Icons.sync_problem),
                title: const Text('Impossible de lire la file'),
                subtitle: Text(e.toString()),
              ),
              data: (count) => ListTile(
                leading: const Icon(Icons.sync),
                title: Text(l10n.settingsQueueTitle(count)),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    ref.invalidate(connectivityStatusProvider);
                    ref.invalidate(pendingMutationsProvider);
                  },
                  icon: const Icon(Icons.refresh),
                  label: Text(l10n.refresh),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    try {
                      await ref.read(syncManagerProvider).forceSync();
                      ref.invalidate(pendingMutationsProvider);
                      messenger.showSnackBar(
                        SnackBar(content: Text(l10n.syncStarted)),
                      );
                    } catch (e) {
                      messenger.showSnackBar(
                        SnackBar(content: Text(e.toString())),
                      );
                    }
                  },
                  icon: const Icon(Icons.cloud_sync),
                  label: Text(l10n.syncNow),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(l10n.settingsTheme, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                RadioListTile<ThemeMode>(
                  value: ThemeMode.system,
                  groupValue: themeMode,
                  title: Text(l10n.themeSystem),
                  onChanged: (v) {
                    if (v == null) return;
                    ref.read(themeModeProvider.notifier).setMode(v);
                  },
                ),
                RadioListTile<ThemeMode>(
                  value: ThemeMode.light,
                  groupValue: themeMode,
                  title: Text(l10n.themeLight),
                  onChanged: (v) {
                    if (v == null) return;
                    ref.read(themeModeProvider.notifier).setMode(v);
                  },
                ),
                RadioListTile<ThemeMode>(
                  value: ThemeMode.dark,
                  groupValue: themeMode,
                  title: Text(l10n.themeDark),
                  onChanged: (v) {
                    if (v == null) return;
                    ref.read(themeModeProvider.notifier).setMode(v);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
