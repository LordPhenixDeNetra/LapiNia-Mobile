import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'core_providers.dart';

class ThemeModeController extends AsyncNotifier<ThemeMode> {
  @override
  Future<ThemeMode> build() async {
    final service = ref.read(themeServiceProvider);
    return service.getThemeMode();
  }

  Future<void> setMode(ThemeMode mode) async {
    final service = ref.read(themeServiceProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await service.setThemeMode(mode);
      return mode;
    });
  }
}

final themeModeProvider =
    AsyncNotifierProvider<ThemeModeController, ThemeMode>(ThemeModeController.new);
