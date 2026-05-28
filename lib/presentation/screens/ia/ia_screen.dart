import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';

class IAScreen extends StatelessWidget {
  const IAScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('IA'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Module IA à venir.',
            style: AppTypography.body1.copyWith(color: AppColors.textDark),
          ),
        ),
      ),
    );
  }
}

