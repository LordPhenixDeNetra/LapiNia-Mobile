import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(75),
                ),
                child: const Icon(
                  Icons.pets,
                  size: 80,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'lapiNia',
                style: AppTypography.headline1.copyWith(
                  color: AppColors.primary,
                  fontSize: 36,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Votre assistant intelligent\nd\'élevage cunicole',
                textAlign: TextAlign.center,
                style: AppTypography.body1.copyWith(
                  color: AppColors.textDark.withValues(alpha: 0.7),
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () => context.push('/login'),
                child: const Text('Commencer'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.push('/login'),
                child: Text(
                  'J\'ai déjà un compte',
                  style: AppTypography.body2.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.alert.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.wifi_off,
                      color: AppColors.alert,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Fonctionne hors-ligne',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.alert,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
