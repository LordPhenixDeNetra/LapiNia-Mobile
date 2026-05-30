import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'core_providers.dart';

enum BootstrapDestination { welcome, onboarding, dashboard }

class OnboardingDoneController extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    return ref.read(onboardingServiceProvider).isDone();
  }

  Future<void> setDone(bool value) async {
    state = AsyncValue.data(value);
    try {
      await ref.read(onboardingServiceProvider).setDone(value);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final onboardingDoneProvider =
    AsyncNotifierProvider<OnboardingDoneController, bool>(
  OnboardingDoneController.new,
);

final bootstrapProvider = FutureProvider<BootstrapDestination>((ref) async {
  await ref.read(localNotificationServiceProvider).initialize();

  final sessionService = ref.read(sessionServiceProvider);
  await sessionService.restore();

  final user = ref.read(supabaseClientProvider).auth.currentUser;
  if (user == null) {
    return BootstrapDestination.welcome;
  }

  final done = await ref.read(onboardingDoneProvider.future);
  if (!done) {
    return BootstrapDestination.onboarding;
  }

  return BootstrapDestination.dashboard;
});
