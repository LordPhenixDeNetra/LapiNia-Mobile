import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lapinia_mobile/l10n/app_localizations.dart';

import '../../../core/models/race.dart';
import '../../../core/models/race_recommendation.dart';
import '../../../domain/services/race_recommendation_service.dart';
import '../../providers/core_providers.dart';
import '../../providers/lapin_provider.dart';
import '../../widgets/common/connectivity_banner.dart';
import '../../widgets/common/loading_widget.dart';

class RaceRecommendationScreen extends HookConsumerWidget {
  const RaceRecommendationScreen({super.key});

  static const _resourceOptions = <String>[
    'granulés',
    'foin',
    'luzerne',
    'moringa',
    'vaccination',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    final countryController = useTextEditingController();
    final cityController = useTextEditingController();
    final goal = useState<RaceRecommendationGoal>(RaceRecommendationGoal.meat);
    final resources = useState<Set<String>>(<String>{});

    final isSubmitting = useState(false);
    final result = useState<RaceRecommendationResult?>(null);

    useEffect(() {
      Future<void>(() async {
        final profile = await ref.read(onboardingProfileServiceProvider).getProfile();
        if (profile == null) return;
        if (countryController.text.trim().isEmpty) {
          countryController.text = profile.country;
        }
        if (cityController.text.trim().isEmpty) {
          cityController.text = profile.city;
        }
      });
      return null;
    }, const []);

    final racesAsync = ref.watch(racesProvider);
    final racesById = <String, Race>{
      for (final r in racesAsync.asData?.value ?? const <Race>[]) r.id: r,
    };

    Future<void> submit() async {
      final country = countryController.text.trim();
      if (country.isEmpty) return;

      isSubmitting.value = true;
      result.value = null;

      try {
        final service = ref.read(raceRecommendationServiceProvider);
        final res = await service.recommend(
          RaceRecommendationRequest(
            country: country,
            city: cityController.text.trim().isEmpty ? null : cityController.text.trim(),
            goal: goal.value,
            resources: resources.value.toList(),
          ),
        );
        result.value = res;
      } on RaceRecommendationNotConfiguredException {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.racesAiNotConfigured)),
        );
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      } finally {
        isSubmitting.value = false;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.racesRecommendTitle),
      ),
      body: Column(
        children: [
          const ConnectivityBanner(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(l10n.racesRecommendFormTitle,
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 12),
                        TextField(
                          controller: countryController,
                          decoration: InputDecoration(
                            labelText: l10n.racesCountryLabel,
                            prefixIcon: const Icon(Icons.flag_outlined),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: cityController,
                          decoration: InputDecoration(
                            labelText: l10n.racesCityLabel,
                            prefixIcon: const Icon(Icons.location_city_outlined),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l10n.racesGoalLabel,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: [
                            ChoiceChip(
                              label: Text(l10n.racesGoalMeat),
                              selected: goal.value == RaceRecommendationGoal.meat,
                              onSelected: (_) => goal.value = RaceRecommendationGoal.meat,
                            ),
                            ChoiceChip(
                              label: Text(l10n.racesGoalBreeding),
                              selected: goal.value == RaceRecommendationGoal.breeding,
                              onSelected: (_) => goal.value = RaceRecommendationGoal.breeding,
                            ),
                            ChoiceChip(
                              label: Text(l10n.racesGoalHeatResilience),
                              selected: goal.value == RaceRecommendationGoal.heatResilience,
                              onSelected: (_) =>
                                  goal.value = RaceRecommendationGoal.heatResilience,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l10n.racesResourcesLabel,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final r in _resourceOptions)
                              FilterChip(
                                label: Text(r),
                                selected: resources.value.contains(r),
                                onSelected: (v) {
                                  final next = {...resources.value};
                                  if (v) {
                                    next.add(r);
                                  } else {
                                    next.remove(r);
                                  }
                                  resources.value = next;
                                },
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: isSubmitting.value ? null : submit,
                          child: isSubmitting.value
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Text(l10n.racesRecommendCta),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (result.value != null)
                  _ResultSection(
                    result: result.value!,
                    racesById: racesById,
                  ),
                if (result.value == null && !isSubmitting.value)
                  EmptyStateWidget(
                    icon: Icons.auto_awesome_outlined,
                    title: l10n.racesRecommendEmptyTitle,
                    subtitle: l10n.racesRecommendEmptySubtitle,
                  ),
                if (isSubmitting.value) const LoadingWidget(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultSection extends StatelessWidget {
  final RaceRecommendationResult result;
  final Map<String, Race> racesById;

  const _ResultSection({
    required this.result,
    required this.racesById,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final items = result.items;
    if (items.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.auto_awesome_outlined,
        title: l10n.racesRecommendNoResultTitle,
        subtitle: l10n.racesRecommendNoResultSubtitle,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.racesRecommendResultTitle,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Card(
              child: ListTile(
                title: Text(item.raceName.isNotEmpty ? item.raceName : item.raceId),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (item.reasons.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(l10n.racesRecommendReasonsLabel),
                      const SizedBox(height: 4),
                      for (final r in item.reasons.take(3)) Text('• $r'),
                    ],
                    if (item.warnings.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(l10n.racesRecommendWarningsLabel),
                      const SizedBox(height: 4),
                      for (final w in item.warnings.take(3)) Text('• $w'),
                    ],
                  ],
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  final race = racesById[item.raceId];
                  if (race == null) return;
                  context.push('/race/${race.id}');
                },
              ),
            ),
          ),
      ],
    );
  }
}
