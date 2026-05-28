import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../providers/settings_providers.dart';
import '../../providers/theme_provider.dart';
import '../../providers/core_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivity = ref.watch(connectivityStatusProvider);
    final pendingMutations = ref.watch(pendingMutationsProvider);
    final themeMode = ref.watch(themeModeProvider).asData?.value ?? ThemeMode.system;

    return Scaffold(
      appBar: AppBar(title: const Text('Réglages')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Connexion', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: connectivity.when(
              loading: () => const ListTile(
                leading: CircularProgressIndicator(),
                title: Text('Vérification...'),
              ),
              error: (e, _) => ListTile(
                leading: const Icon(Icons.wifi_off),
                title: const Text('Statut inconnu'),
                subtitle: Text(e.toString()),
              ),
              data: (isOnline) => ListTile(
                leading: Icon(isOnline ? Icons.wifi : Icons.wifi_off),
                title: Text(isOnline ? 'En ligne' : 'Hors ligne'),
                subtitle: Text(
                  isOnline
                      ? 'Les données peuvent être synchronisées.'
                      : 'Les actions seront mises en attente.',
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Synchronisation', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: pendingMutations.when(
              loading: () => const ListTile(
                leading: CircularProgressIndicator(),
                title: Text('Mutations en attente...'),
              ),
              error: (e, _) => ListTile(
                leading: const Icon(Icons.sync_problem),
                title: const Text('Impossible de lire la file'),
                subtitle: Text(e.toString()),
              ),
              data: (count) => ListTile(
                leading: const Icon(Icons.sync),
                title: Text('$count action(s) en attente'),
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
                  label: const Text('Rafraîchir'),
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
                        const SnackBar(content: Text('Synchronisation lancée')),
                      );
                    } catch (e) {
                      messenger.showSnackBar(
                        SnackBar(content: Text(e.toString())),
                      );
                    }
                  },
                  icon: const Icon(Icons.cloud_sync),
                  label: const Text('Synchroniser'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Thème', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                RadioListTile<ThemeMode>(
                  value: ThemeMode.system,
                  groupValue: themeMode,
                  title: const Text('Système'),
                  onChanged: (v) {
                    if (v == null) return;
                    ref.read(themeModeProvider.notifier).setMode(v);
                  },
                ),
                RadioListTile<ThemeMode>(
                  value: ThemeMode.light,
                  groupValue: themeMode,
                  title: const Text('Clair'),
                  onChanged: (v) {
                    if (v == null) return;
                    ref.read(themeModeProvider.notifier).setMode(v);
                  },
                ),
                RadioListTile<ThemeMode>(
                  value: ThemeMode.dark,
                  groupValue: themeMode,
                  title: const Text('Sombre'),
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

