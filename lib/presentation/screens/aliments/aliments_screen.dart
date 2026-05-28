import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';

class AlimentsScreen extends StatelessWidget {
  const AlimentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Aliments'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Module Aliments à venir.',
            style: AppTypography.body1.copyWith(color: AppColors.textDark),
          ),
        ),
      ),
    );
  }
}

