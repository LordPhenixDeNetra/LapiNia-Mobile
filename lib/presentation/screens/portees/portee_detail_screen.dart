import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/models/portee.dart';
import '../../providers/portee_provider.dart';

class PorteeDetailScreen extends HookConsumerWidget {
  final String porteeId;

  const PorteeDetailScreen({super.key, required this.porteeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final porteeAsync = ref.watch(porteeDetailProvider(porteeId));
    final isSaving = useState(false);

    Future<void> recordSevrage(Portee portee) async {
      isSaving.value = true;
      try {
        await ref.read(porteesProvider.notifier).recordSevrage(
              porteeId: portee.id,
              mereId: portee.mereId,
            );
        ref.invalidate(porteeDetailProvider(porteeId));
      } finally {
        isSaving.value = false;
      }
    }

    return porteeAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Portée')),
        body: Center(child: Text(e.toString())),
      ),
      data: (portee) {
        final mere = portee.mere?.nom ?? 'Mère';
        final pere = portee.pere?.nom ?? 'Père';
        final date = portee.dateSaillie;
        final dateText = '${date.day}/${date.month}/${date.year}';

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Détails portée'),
            actions: [
              IconButton(
                icon: const Icon(Icons.list),
                onPressed: () => context.go('/portees'),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Infos', style: AppTypography.subtitle1),
                      const SizedBox(height: 12),
                      _row('Mère', mere),
                      _row('Père', pere),
                      _row('Statut', portee.statut.label),
                      _row('Saillie', dateText),
                      if (portee.dateMiseBasPrevue != null)
                        _row(
                          'Mise bas prévue',
                          '${portee.dateMiseBasPrevue!.day}/${portee.dateMiseBasPrevue!.month}/${portee.dateMiseBasPrevue!.year}',
                        ),
                      _row('Vivants', portee.nbVivants.toString()),
                      _row('Morts', portee.nbMorts.toString()),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: isSaving.value ? null : () => recordSevrage(portee),
                child: const Text('Marquer sevrage'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: AppTypography.body2.copyWith(color: AppColors.greyMedium),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: AppTypography.body2.copyWith(color: AppColors.textDark),
            ),
          ),
        ],
      ),
    );
  }
}

