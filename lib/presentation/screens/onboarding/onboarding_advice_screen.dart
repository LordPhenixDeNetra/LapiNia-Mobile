import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lapinia_mobile/l10n/app_localizations.dart';

import '../../../core/models/onboarding_profile.dart';
import '../../providers/core_providers.dart';
import '../../widgets/common/loading_widget.dart';

class OnboardingAdviceScreen extends HookConsumerWidget {
  const OnboardingAdviceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final reload = useState(0);
    final future = useMemoized(() => _loadAdvice(ref, l10n), [reload.value]);
    final snapshot = useFuture(future);

    final error = snapshot.error;
    if (snapshot.connectionState != ConnectionState.done) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.onboardingAdviceTitle),
        ),
        body: const LoadingWidget(),
      );
    }
    if (error != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.onboardingAdviceTitle),
        ),
        body: ErrorDisplayWidget(
          message: error.toString(),
          onRetry: () => reload.value++,
        ),
      );
    }

    final text = snapshot.data ?? l10n.onboardingAdviceFallbackGeneric;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.onboardingAdviceTitle),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.onboardingAdviceSubtitle,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          text,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => context.go('/dashboard'),
                child: Text(l10n.onboardingAdviceContinue),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<String> _loadAdvice(WidgetRef ref, AppLocalizations l10n) async {
  final profileService = ref.read(onboardingProfileServiceProvider);
  final profile = await profileService.getProfile();

  final supabase = ref.read(supabaseClientProvider);
  try {
    final res = await supabase.functions.invoke(
      'daily-advice',
      body: profile?.toJson() ?? const <String, dynamic>{},
    );
    final data = res.data;
    if (data is String && data.trim().isNotEmpty) return data;
    if (data is Map) {
      final message = data['advice'] ?? data['message'] ?? data['content'];
      if (message is String && message.trim().isNotEmpty) return message;
    }
  } catch (_) {}

  return _fallbackAdvice(l10n, profile);
}

String _fallbackAdvice(AppLocalizations l10n, OnboardingProfile? profile) {
  if (profile == null) return l10n.onboardingAdviceFallbackGeneric;

  final goals = profile.goals.toSet();
  if (goals.contains('SELL_KITS')) {
    return l10n.onboardingAdviceFallbackSell;
  }
  if (goals.contains('MEAT')) {
    return l10n.onboardingAdviceFallbackMeat;
  }
  if (goals.contains('BREEDERS')) {
    return l10n.onboardingAdviceFallbackBreeders;
  }
  return l10n.onboardingAdviceFallbackGeneric;
}
