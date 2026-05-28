import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:lapinia_mobile/l10n/app_localizations.dart';

import '../../../core/models/onboarding_profile.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/models/race.dart';
import '../../providers/core_providers.dart';
import '../../providers/bootstrap_provider.dart';
import '../../providers/lapin_provider.dart';
import '../../widgets/common/loading_widget.dart';

class OnboardingScreen extends HookConsumerWidget {
  const OnboardingScreen({super.key});

  static const _kStepCount = 5;
  static const _kCountries = <String>[
    'Sénégal',
    'Mali',
    'Côte d\'Ivoire',
    'Autre',
  ];
  static const _kRabbitRanges = <String>['LT_10', '10_50', '50_200', 'GT_200'];
  static const _kGoals = <String>['SELL_KITS', 'MEAT', 'BREEDERS', 'HOBBY'];
  static const _kExperience = <String>['BEGINNER', 'INTERMEDIATE', 'EXPERT'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    final pageController = usePageController();
    final currentPage = useState(0);

    final rabbitsCountRange = useState<String?>(null);
    final goals = useState<List<String>>(<String>[]);
    final country = useState<String>(_kCountries.first);
    final cityController = useTextEditingController();
    final selectedRaceIds = useState<Set<String>>(<String>{});
    final experienceLevel = useState<String?>(null);

    final racesAsync = ref.watch(racesProvider);

    Future<void> nextPage() async {
      if (currentPage.value < _kStepCount - 1) {
        await pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        return;
      }

      final profileService = ref.read(onboardingProfileServiceProvider);
      await profileService.saveProfile(
        OnboardingProfile(
          rabbitsCountRange: rabbitsCountRange.value!,
          goals: goals.value,
          country: country.value,
          city: cityController.text.trim(),
          raceIds: selectedRaceIds.value.toList(),
          experienceLevel: experienceLevel.value!,
        ),
      );
      await ref.read(onboardingDoneProvider.notifier).setDone(true);
      if (!context.mounted) return;
      context.go('/onboarding-advice');
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: currentPage.value > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
              )
            : null,
      ),
      body: SafeArea(
        child: Column(
          children: [
            LinearProgressIndicator(
              value: (currentPage.value + 1) / _kStepCount,
              backgroundColor: colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation(colorScheme.primary),
            ),
            Expanded(
              child: PageView.builder(
                controller: pageController,
                onPageChanged: (index) {
                  currentPage.value = index;
                },
                itemCount: _kStepCount,
                itemBuilder: (context, index) {
                  switch (index) {
                    case 0:
                      return _OnboardingChoiceStep(
                        icon: Icons.pets,
                        title: l10n.onboardingRabbitsCountTitle,
                        options: _kRabbitRanges,
                        labelOf: (id) {
                          switch (id) {
                            case 'LT_10':
                              return l10n.onboardingRabbitsCountLt10;
                            case '10_50':
                              return l10n.onboardingRabbitsCount10to50;
                            case '50_200':
                              return l10n.onboardingRabbitsCount50to200;
                            default:
                              return l10n.onboardingRabbitsCountGt200;
                          }
                        },
                        selectedValue: rabbitsCountRange.value,
                        onSelected: (v) => rabbitsCountRange.value = v,
                      );
                    case 1:
                      return _OnboardingChoiceStep(
                        icon: Icons.flag,
                        title: l10n.onboardingGoalsTitle,
                        options: _kGoals,
                        labelOf: (id) {
                          switch (id) {
                            case 'SELL_KITS':
                              return l10n.onboardingGoalSellKits;
                            case 'MEAT':
                              return l10n.onboardingGoalMeat;
                            case 'BREEDERS':
                              return l10n.onboardingGoalBreeders;
                            default:
                              return l10n.onboardingGoalHobby;
                          }
                        },
                        multiSelect: true,
                        selectedValues: goals.value.toSet(),
                        onSelectedMulti: (set) => goals.value = set.toList(),
                      );
                    case 2:
                      return _OnboardingRegionStep(
                        country: country.value,
                        countries: _kCountries,
                        onCountryChanged: (v) {
                          if (v == null) return;
                          country.value = v;
                        },
                        cityController: cityController,
                        title: l10n.onboardingRegionTitle,
                        countryLabel: l10n.onboardingCountryLabel,
                        cityLabel: l10n.onboardingCityLabel,
                        cityHint: l10n.onboardingCityHint,
                      );
                    case 3:
                      return _OnboardingRacesStep(
                        title: l10n.onboardingRacesTitle,
                        races: racesAsync,
                        selectedRaceIds: selectedRaceIds.value,
                        onChanged: (set) => selectedRaceIds.value = set,
                        onRetry: () => ref.invalidate(racesProvider),
                        allowSkipText: l10n.onboardingRacesSkip,
                      );
                    default:
                      return _OnboardingChoiceStep(
                        icon: Icons.school,
                        title: l10n.onboardingExperienceTitle,
                        options: _kExperience,
                        labelOf: (id) {
                          switch (id) {
                            case 'BEGINNER':
                              return l10n.onboardingExperienceBeginner;
                            case 'INTERMEDIATE':
                              return l10n.onboardingExperienceIntermediate;
                            default:
                              return l10n.onboardingExperienceExpert;
                          }
                        },
                        selectedValue: experienceLevel.value,
                        onSelected: (v) => experienceLevel.value = v,
                      );
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: ElevatedButton(
                onPressed: _canGoNext(
                  currentPage: currentPage.value,
                  rabbitsCountRange: rabbitsCountRange.value,
                  goals: goals.value,
                  country: country.value,
                  experienceLevel: experienceLevel.value,
                  racesAsync: racesAsync,
                )
                    ? () => nextPage()
                    : null,
                child: Text(
                  currentPage.value == _kStepCount - 1
                      ? l10n.onboardingStart
                      : l10n.onboardingNext,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _canGoNext({
    required int currentPage,
    required String? rabbitsCountRange,
    required List<String> goals,
    required String country,
    required String? experienceLevel,
    required AsyncValue<List<Race>> racesAsync,
  }) {
    switch (currentPage) {
      case 0:
        return rabbitsCountRange != null && rabbitsCountRange.trim().isNotEmpty;
      case 1:
        return goals.isNotEmpty;
      case 2:
        return country.trim().isNotEmpty;
      case 3:
        return racesAsync.hasValue || racesAsync.hasError;
      case 4:
        return experienceLevel != null && experienceLevel.trim().isNotEmpty;
      default:
        return false;
    }
  }
}

class _OnboardingChoiceStep extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<String> options;
  final String Function(String id) labelOf;
  final bool multiSelect;
  final String? selectedValue;
  final void Function(String v)? onSelected;
  final Set<String>? selectedValues;
  final void Function(Set<String>)? onSelectedMulti;

  const _OnboardingChoiceStep({
    required this.icon,
    required this.title,
    required this.options,
    required this.labelOf,
    this.multiSelect = false,
    this.selectedValue,
    this.onSelected,
    this.selectedValues,
    this.onSelectedMulti,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Icon(icon, size: 48, color: colorScheme.primary),
                const SizedBox(height: 24),
                Text(title, style: AppTypography.headline2),
                const SizedBox(height: 32),
                ...options.map((option) {
                  final isSelected = multiSelect
                      ? (selectedValues?.contains(option) ?? false)
                      : selectedValue == option;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: () {
                        if (!multiSelect) {
                          onSelected?.call(option);
                          return;
                        }
                        final next = {...?selectedValues};
                        if (next.contains(option)) {
                          next.remove(option);
                        } else {
                          next.add(option);
                        }
                        onSelectedMulti?.call(next);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? colorScheme.primary
                              : colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? colorScheme.primary
                                : colorScheme.outlineVariant,
                            width: 2,
                          ),
                        ),
                        child: Text(
                          labelOf(option),
                          style: AppTypography.body1.copyWith(
                            color: isSelected
                                ? colorScheme.onPrimary
                                : colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _OnboardingRegionStep extends StatelessWidget {
  final String title;
  final String countryLabel;
  final String cityLabel;
  final String cityHint;
  final String country;
  final List<String> countries;
  final ValueChanged<String?> onCountryChanged;
  final TextEditingController cityController;

  const _OnboardingRegionStep({
    required this.title,
    required this.countryLabel,
    required this.cityLabel,
    required this.cityHint,
    required this.country,
    required this.countries,
    required this.onCountryChanged,
    required this.cityController,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Icon(Icons.location_on, size: 48, color: colorScheme.primary),
                const SizedBox(height: 24),
                Text(title, style: AppTypography.headline2),
                const SizedBox(height: 24),
                DropdownButtonFormField<String>(
                  key: ValueKey(country),
                  initialValue: country,
                  decoration: InputDecoration(
                    labelText: countryLabel,
                    prefixIcon: const Icon(Icons.public),
                  ),
                  items: countries
                      .map(
                        (c) => DropdownMenuItem(
                          value: c,
                          child: Text(c),
                        ),
                      )
                      .toList(),
                  onChanged: onCountryChanged,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: cityController,
                  decoration: InputDecoration(
                    labelText: cityLabel,
                    hintText: cityHint,
                    prefixIcon: const Icon(Icons.location_city),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _OnboardingRacesStep extends StatelessWidget {
  final String title;
  final AsyncValue<List<Race>> races;
  final Set<String> selectedRaceIds;
  final ValueChanged<Set<String>> onChanged;
  final VoidCallback onRetry;
  final String allowSkipText;

  const _OnboardingRacesStep({
    required this.title,
    required this.races,
    required this.selectedRaceIds,
    required this.onChanged,
    required this.onRetry,
    required this.allowSkipText,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Icon(Icons.category, size: 48, color: colorScheme.primary),
                const SizedBox(height: 24),
                Text(title, style: AppTypography.headline2),
                const SizedBox(height: 16),
                races.when(
                  loading: () => const LoadingWidget(),
                  error: (e, _) => Column(
                    children: [
                      ErrorDisplayWidget(message: e.toString(), onRetry: onRetry),
                      const SizedBox(height: 12),
                      Text(
                        allowSkipText,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  data: (items) {
                    if (items.isEmpty) {
                      return EmptyStateWidget(
                        icon: Icons.category_outlined,
                        title: title,
                        subtitle: allowSkipText,
                      );
                    }

                    return Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: items.map((race) {
                        final selected = selectedRaceIds.contains(race.id);
                        return FilterChip(
                          label: Text(race.nom),
                          selected: selected,
                          onSelected: (v) {
                            final next = {...selectedRaceIds};
                            if (v) {
                              next.add(race.id);
                            } else {
                              next.remove(race.id);
                            }
                            onChanged(next);
                          },
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
