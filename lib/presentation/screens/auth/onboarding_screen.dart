import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../providers/bootstrap_provider.dart';

class OnboardingScreen extends HookConsumerWidget {
  const OnboardingScreen({super.key});

  static const List<OnboardingQuestion> _questions = [
    OnboardingQuestion(
      title: 'Combien de lapins avez-vous ?',
      options: ['Moins de 10', '10 à 50', '50 à 200', 'Plus de 200'],
      icon: Icons.pets,
    ),
    OnboardingQuestion(
      title: 'Quel est votre objectif principal ?',
      options: ['Vente lapereaux', 'Viande familiale', 'Reproducteurs', 'Loisir'],
      icon: Icons.flag,
      multiSelect: true,
    ),
    OnboardingQuestion(
      title: 'Votre région ?',
      options: ['Sénégal', 'Mali', 'Côte d\'Ivoire', 'Autre'],
      icon: Icons.location_on,
    ),
    OnboardingQuestion(
      title: 'Votre niveau d\'expérience ?',
      options: ['Débutant', 'Intermédiaire', 'Expert'],
      icon: Icons.school,
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageController = usePageController();
    final currentPage = useState(0);
    final answers = useState<Map<String, dynamic>>({});

    void onOptionSelected(String questionKey, String value) {
      final question = _questions.firstWhere((q) => q.title == questionKey);
      if (!question.multiSelect) {
        answers.value = {...answers.value, questionKey: value};
        return;
      }

      final existing = answers.value[questionKey];
      final selected = (existing is List<String>) ? List<String>.from(existing) : <String>[];
      if (selected.contains(value)) {
        selected.remove(value);
      } else {
        selected.add(value);
      }
      answers.value = {...answers.value, questionKey: selected};
    }

    Future<void> nextPage() async {
      if (currentPage.value < _questions.length - 1) {
        await pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        return;
      }

      await ref.read(onboardingDoneProvider.notifier).setDone(true);
      if (!context.mounted) return;
      context.go('/dashboard');
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: currentPage.value > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
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
              value: (currentPage.value + 1) / _questions.length,
              backgroundColor: AppColors.greyLight,
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            ),
            Expanded(
              child: PageView.builder(
                controller: pageController,
                onPageChanged: (index) {
                  currentPage.value = index;
                },
                itemCount: _questions.length,
                itemBuilder: (context, index) {
                  return _buildQuestionPage(
                    _questions[index],
                    answers: answers.value,
                    onOptionSelected: onOptionSelected,
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: ElevatedButton(
                onPressed: _canGoNext(
                  currentPage: currentPage.value,
                  answers: answers.value,
                )
                    ? () => nextPage()
                    : null,
                child: Text(
                  currentPage.value == _questions.length - 1
                      ? 'Commencer'
                      : 'Suivant',
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
    required Map<String, dynamic> answers,
  }) {
    if (currentPage < 0 || currentPage >= _questions.length) return false;
    final q = _questions[currentPage];
    final v = answers[q.title];
    if (!q.multiSelect) return v is String && v.trim().isNotEmpty;
    if (v is List<String>) return v.isNotEmpty;
    return false;
  }

  Widget _buildQuestionPage(
    OnboardingQuestion question, {
    required Map<String, dynamic> answers,
    required void Function(String questionKey, String value) onOptionSelected,
  }) {
    final questionKey = question.title;
    final selectedValue = answers[questionKey];
    final selectedList =
        (question.multiSelect && selectedValue is List<String>) ? selectedValue : const <String>[];

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
                Icon(
                  question.icon,
                  size: 48,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 24),
                Text(
                  question.title,
                  style: AppTypography.headline2.copyWith(
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 32),
                ...question.options.map((option) {
                  final isSelected = question.multiSelect
                      ? selectedList.contains(option)
                      : selectedValue == option;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: () => onOptionSelected(questionKey, option),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : AppColors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : AppColors.greyLight,
                            width: 2,
                          ),
                        ),
                        child: Text(
                          option,
                          style: AppTypography.body1.copyWith(
                            color: isSelected ? AppColors.white : AppColors.textDark,
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

class OnboardingQuestion {
  final String title;
  final List<String> options;
  final IconData icon;
  final bool multiSelect;

  const OnboardingQuestion({
    required this.title,
    required this.options,
    required this.icon,
    this.multiSelect = false,
  });
}
