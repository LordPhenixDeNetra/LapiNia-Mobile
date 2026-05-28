import 'package:flutter/material.dart';
import 'package:lapinia_mobile/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../providers/bootstrap_provider.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bootstrap = ref.watch(bootstrapProvider);
    final l10n = AppLocalizations.of(context)!;

    ref.listen(bootstrapProvider, (previous, next) {
      next.whenData((dest) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) return;
          switch (dest) {
            case BootstrapDestination.welcome:
              context.go('/welcome');
              break;
            case BootstrapDestination.onboarding:
              context.go('/onboarding');
              break;
            case BootstrapDestination.dashboard:
              context.go('/dashboard');
              break;
          }
        });
      });
    });

    final hasError = bootstrap.hasError;
    final errorText = hasError ? bootstrap.error.toString() : null;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(60),
              ),
              child: const Icon(Icons.pets, size: 64, color: Colors.white),
            ),
            const SizedBox(height: 24),
            Text(
              'lapiNia',
              style: AppTypography.headline1.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            if (!hasError)
              const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 3),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    Text(
                      l10n.startupErrorTitle,
                      style: AppTypography.headline3,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      errorText ?? l10n.errorUnknown,
                      style: AppTypography.body2.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.7),
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 6,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.invalidate(bootstrapProvider),
                      child: Text(l10n.retry),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: () => context.go('/welcome'),
                      child: Text(l10n.goToLogin),
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
