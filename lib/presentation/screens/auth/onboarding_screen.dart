import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingQuestion> _questions = [
    OnboardingQuestion(
      title: 'Combien de lapins avez-vous ?',
      options: ['Moins de 10', '10 à 50', '50 à 200', 'Plus de 200'],
      icon: Icons.pets,
    ),
    OnboardingQuestion(
      title: 'Quel est votre objectif principal ?',
      options: ['Vente lapereaux', 'Viande familiale', 'Reproducteurs', 'Loisir'],
      icon: Icons.flag,
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

  Map<String, dynamic> _answers = {};

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onOptionSelected(String questionKey, String value) {
    setState(() {
      _answers[questionKey] = value;
    });
  }

  void _nextPage() {
    if (_currentPage < _questions.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      context.go('/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _currentPage > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
                onPressed: () {
                  _pageController.previousPage(
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
              value: (_currentPage + 1) / _questions.length,
              backgroundColor: AppColors.greyLight,
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _questions.length,
                itemBuilder: (context, index) {
                  return _buildQuestionPage(_questions[index]);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: ElevatedButton(
                onPressed: _answers.length > _currentPage ? _nextPage : null,
                child: Text(
                  _currentPage == _questions.length - 1
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

  Widget _buildQuestionPage(OnboardingQuestion question) {
    final questionKey = question.title;
    final selectedValue = _answers[questionKey];

    return Padding(
      padding: const EdgeInsets.all(24.0),
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
            final isSelected = selectedValue == option;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () => _onOptionSelected(questionKey, option),
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
    );
  }
}

class OnboardingQuestion {
  final String title;
  final List<String> options;
  final IconData icon;

  OnboardingQuestion({
    required this.title,
    required this.options,
    required this.icon,
  });
}
