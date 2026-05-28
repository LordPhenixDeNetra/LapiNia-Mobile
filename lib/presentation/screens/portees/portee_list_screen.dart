import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/models/portee.dart';
import '../../providers/portee_provider.dart';

class PorteeListScreen extends ConsumerWidget {
  const PorteeListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final portees = ref.watch(porteesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mes Portées'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/saillie/new'),
        child: const Icon(Icons.add),
      ),
      body: portees.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.child_friendly, size: 64, color: AppColors.greyLight),
                    const SizedBox(height: 16),
                    Text(
                      'Aucune portée',
                      style: AppTypography.headline3.copyWith(color: AppColors.greyMedium),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.read(porteesProvider.notifier).refresh(),
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              itemBuilder: (context, i) {
                final portee = items[i];
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

