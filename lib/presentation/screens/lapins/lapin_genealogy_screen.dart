import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lapinia_mobile/l10n/app_localizations.dart';

import '../../../core/constants/app_typography.dart';
import '../../../core/constants/enums.dart';
import '../../../core/models/genealogy_tree.dart';
import '../../providers/fertility_providers.dart';
import '../../widgets/common/connectivity_banner.dart';
import '../../widgets/common/loading_widget.dart';

class LapinGenealogyScreen extends ConsumerWidget {
  final String lapinId;

  const LapinGenealogyScreen({super.key, required this.lapinId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final asyncTree = ref.watch(genealogyProvider(lapinId));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.genealogyTitle),
      ),
      body: Column(
        children: [
          const ConnectivityBanner(),
          Expanded(
            child: asyncTree.when(
              loading: () => const LoadingWidget(),
              error: (e, _) => ErrorDisplayWidget(
                message: e.toString(),
                onRetry: () => ref.invalidate(genealogyProvider(lapinId)),
              ),
              data: (tree) {
                final center = _personFor(tree, tree.centerId);
                final parents = tree.parentsOf(tree.centerId);
                final pere = parents.pereId != null ? _personFor(tree, parents.pereId!) : null;
                final mere = parents.mereId != null ? _personFor(tree, parents.mereId!) : null;

                final gpPere = parents.pereId != null ? tree.parentsOf(parents.pereId!) : null;
                final gpMere = parents.mereId != null ? tree.parentsOf(parents.mereId!) : null;

                final gpPerePere =
                    gpPere?.pereId != null ? _personFor(tree, gpPere!.pereId!) : null;
                final gpPereMere =
                    gpPere?.mereId != null ? _personFor(tree, gpPere!.mereId!) : null;
                final gpMerePere =
                    gpMere?.pereId != null ? _personFor(tree, gpMere!.pereId!) : null;
                final gpMereMere =
                    gpMere?.mereId != null ? _personFor(tree, gpMere!.mereId!) : null;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(l10n.genealogyGeneration3, style: AppTypography.subtitle1),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _NodeCard(
                            person: gpPerePere,
                            unknownLabel: l10n.genealogyUnknown,
                            onTap: gpPerePere == null ? null : () => context.push('/lapin/${gpPerePere.id}'),
                          ),
                          _NodeCard(
                            person: gpPereMere,
                            unknownLabel: l10n.genealogyUnknown,
                            onTap: gpPereMere == null ? null : () => context.push('/lapin/${gpPereMere.id}'),
                          ),
                          _NodeCard(
                            person: gpMerePere,
                            unknownLabel: l10n.genealogyUnknown,
                            onTap: gpMerePere == null ? null : () => context.push('/lapin/${gpMerePere.id}'),
                          ),
                          _NodeCard(
                            person: gpMereMere,
                            unknownLabel: l10n.genealogyUnknown,
                            onTap: gpMereMere == null ? null : () => context.push('/lapin/${gpMereMere.id}'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(l10n.genealogyGeneration2, style: AppTypography.subtitle1),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _NodeCard(
                            person: pere,
                            unknownLabel: l10n.genealogyUnknown,
                            onTap: pere == null ? null : () => context.push('/lapin/${pere.id}'),
                          ),
                          _NodeCard(
                            person: mere,
                            unknownLabel: l10n.genealogyUnknown,
                            onTap: mere == null ? null : () => context.push('/lapin/${mere.id}'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(l10n.genealogyGeneration1, style: AppTypography.subtitle1),
                      const SizedBox(height: 8),
                      Center(
                        child: SizedBox(
                          width: 240,
                          child: _NodeCard(
                            person: center,
                            unknownLabel: l10n.genealogyUnknown,
                            onTap: () => context.push('/lapin/${center.id}'),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  GenealogyPerson _personFor(GenealogyTree tree, String id) {
    return tree.personOf(id) ?? GenealogyPerson(id: id, nom: '—', sexe: null, raceNom: null);
  }
}

class _NodeCard extends StatelessWidget {
  final GenealogyPerson? person;
  final String unknownLabel;
  final VoidCallback? onTap;

  const _NodeCard({
    required this.person,
    required this.unknownLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final displayedName = person?.nom ?? unknownLabel;
    final race = person?.raceNom;
    final sexe = person?.sexe;

    final icon = sexe == SexeLapin.male
        ? Icons.male
        : (sexe == SexeLapin.femelle ? Icons.female : Icons.pets);

    final enabled = person != null && onTap != null;

    return SizedBox(
      width: 170,
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: enabled ? onTap : null,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: colorScheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayedName,
                        style: AppTypography.subtitle2,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (race != null && race.trim().isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          race,
                          style: AppTypography.caption.copyWith(color: colorScheme.onSurfaceVariant),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

