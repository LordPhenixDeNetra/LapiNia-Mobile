import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lapinia_mobile/l10n/app_localizations.dart';

import '../../../core/constants/app_typography.dart';
import '../../providers/core_providers.dart';

class PreMiseBasChecklistCard extends HookConsumerWidget {
  final String porteeId;

  const PreMiseBasChecklistCard({super.key, required this.porteeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final supabase = ref.read(supabaseClientProvider);
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return const SizedBox.shrink();

    final service = ref.read(preMiseBasChecklistServiceProvider);
    final initialFuture = useMemoized(
      () => service.getChecklist(userId: userId, porteeId: porteeId),
      [userId, porteeId],
    );
    final initial = useFuture(initialFuture);
    final mapState = useState<Map<String, bool>?>(null);

    useEffect(() {
      final value = initial.data;
      if (value != null) {
        mapState.value = value;
      }
      return null;
    }, [initial.data]);

    final items = mapState.value;
    if (items == null) {
      return const SizedBox.shrink();
    }

    String labelForKey(String key) {
      switch (key) {
        case 'cage_maternite':
          return l10n.checklistCageMaternite;
        case 'nid':
          return l10n.checklistNid;
        case 'temperature':
          return l10n.checklistTemperature;
        case 'aliments':
          return l10n.checklistAliments;
        case 'isolement':
          return l10n.checklistIsolement;
      }
      return key;
    }

    Future<void> toggle(String key, bool checked) async {
      await service.setChecked(
        userId: userId,
        porteeId: porteeId,
        itemKey: key,
        checked: checked,
      );
      mapState.value = {...items, key: checked};
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.preMiseBasChecklistTitle, style: AppTypography.subtitle1),
            const SizedBox(height: 8),
            for (final entry in items.entries)
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: entry.value,
                onChanged: (v) {
                  if (v == null) return;
                  unawaited(toggle(entry.key, v));
                },
                title: Text(labelForKey(entry.key), style: AppTypography.body1),
              ),
          ],
        ),
      ),
    );
  }
}
