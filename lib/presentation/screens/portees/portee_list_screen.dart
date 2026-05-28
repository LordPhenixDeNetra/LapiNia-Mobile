import 'package:flutter/material.dart';
import 'package:lapinia_mobile/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/models/portee.dart';
import '../../providers/portee_provider.dart';
import '../../widgets/common/connectivity_banner.dart';
import '../../widgets/common/loading_widget.dart';

class PorteeListScreen extends ConsumerWidget {
  const PorteeListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final portees = ref.watch(porteesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.porteesTitle),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/saillie/new'),
        child: const Icon(Icons.add),
      ),
      body: portees.when(
        loading: () => const LoadingWidget(),
        error: (e, _) => ErrorDisplayWidget(
          message: e.toString(),
          onRetry: () => ref.read(porteesProvider.notifier).refresh(),
        ),
        data: (items) {
          if (items.isEmpty) {
            return Column(
              children: [
                const ConnectivityBanner(),
                Expanded(
                  child: EmptyStateWidget(
                    icon: Icons.child_friendly,
                    title: l10n.porteesEmpty,
                    subtitle: l10n.porteesEmptySubtitle,
                    buttonText: l10n.porteesEmptyAction,
                    onButtonPressed: () => context.push('/saillie/new'),
                  ),
                ),
              ],
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.read(porteesProvider.notifier).refresh(),
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: items.length + 1,
              itemBuilder: (context, i) {
                if (i == 0) return const ConnectivityBanner();
                final portee = items[i - 1];
                return _PorteeCard(portee: portee);
              },
            ),
          );
        },
      ),
    );
  }
}

class _PorteeCard extends StatelessWidget {
  final Portee portee;

  const _PorteeCard({required this.portee});

  @override
  Widget build(BuildContext context) {
    final mere = portee.mere?.nom ?? 'Mère';
    final statut = portee.statut.label;
    final date = portee.dateSaillie;
    final dateText = '${date.day}/${date.month}/${date.year}';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => context.push('/portee/${portee.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.statutGestation.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Icon(Icons.child_friendly, color: AppColors.statutGestation),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(mere, style: AppTypography.subtitle1),
                    const SizedBox(height: 4),
                    Text('Saillie: $dateText', style: AppTypography.caption),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statut,
                  style: AppTypography.caption.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
