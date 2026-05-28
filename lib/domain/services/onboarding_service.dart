import 'package:shared_preferences/shared_preferences.dart';

class OnboardingService {
  static const _kOnboardingDone = 'onboarding_done';

  Future<bool> isDone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kOnboardingDone) ?? false;
  }

  Future<void> setDone(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kOnboardingDone, value);
  }
}

