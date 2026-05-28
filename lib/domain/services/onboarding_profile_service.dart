import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../core/models/onboarding_profile.dart';

class OnboardingProfileService {
  static const _kProfileKey = 'onboarding_profile_json';

  Future<OnboardingProfile?> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kProfileKey);
    if (raw == null || raw.trim().isEmpty) return null;

    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) return null;
    return OnboardingProfile.fromJson(decoded);
  }

  Future<void> saveProfile(OnboardingProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kProfileKey, jsonEncode(profile.toJson()));
  }

  Future<void> clearProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kProfileKey);
  }
}

