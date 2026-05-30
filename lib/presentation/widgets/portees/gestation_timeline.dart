import 'package:flutter/material.dart';
import 'package:lapinia_mobile/l10n/app_localizations.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';

class GestationTimeline extends StatelessWidget {
  final int elapsedDays;

  const GestationTimeline({super.key, required this.elapsedDays});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    const milestones = <int, String>{
      0: 'J0',
      7: 'J7',
      25: 'J25',
      28: 'J28',
      31: 'J31',
    };

    final clamped = elapsedDays.clamp(0, 31);
    final currentKey = milestones.keys.where((k) => k <= clamped).last;
    final milestoneDetails = <int, String>{
      7: l10n.gestationMilestoneJ7,
      25: l10n.gestationMilestoneJ25,
      28: l10n.gestationMilestoneJ28,
      31: l10n.gestationMilestoneJ31,
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.gestationTimelineTitle, style: AppTypography.subtitle1),
            const SizedBox(height: 12),
            Row(
              children: [
                for (final entry in milestones.entries) ...[
                  _Milestone(
                    label: entry.value,
                    active: clamped >= entry.key,
                    isCurrent: entry.key == currentKey,
                  ),
                  if (entry.key != 31)
                    Expanded(
                      child: Container(
                        height: 4,
                        color: clamped >= entry.key
                            ? AppColors.statutGestation
                            : Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                      ),
                    ),
                ],
              ],
            ),
            const SizedBox(height: 10),
            Text(
              l10n.gestationDayProgress(clamped),
              style: AppTypography.caption,
            ),
            const SizedBox(height: 10),
            for (final entry in milestoneDetails.entries)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'J${entry.key}',
                      style: AppTypography.caption.copyWith(
                        color: entry.key <= clamped
                            ? AppColors.statutGestation
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: AppTypography.caption.copyWith(
                          color: entry.key <= clamped
                              ? Theme.of(context).colorScheme.onSurface
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Milestone extends StatelessWidget {
  final String label;
  final bool active;
  final bool isCurrent;

  const _Milestone({
    required this.label,
    required this.active,
    required this.isCurrent,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.statutGestation : Theme.of(context).colorScheme.outline;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: isCurrent ? 16 : 12,
          height: isCurrent ? 16 : 12,
          decoration: BoxDecoration(
            color: active ? color : Colors.transparent,
            border: Border.all(color: color),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: AppTypography.caption),
      ],
    );
  }
}
