import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/enums.dart';

class StatutBadge extends StatelessWidget {
  final StatutLapin statut;

  const StatutBadge({super.key, required this.statut});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getColor(),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        statut.label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getColor() {
    switch (statut) {
      case StatutLapin.repos:
        return AppColors.statutRepos;
      case StatutLapin.enGestation:
        return AppColors.statutGestation;
      case StatutLapin.lactation:
        return AppColors.statutLactation;
      case StatutLapin.malade:
        return AppColors.statutMalade;
      case StatutLapin.disponibleSaillie:
        return AppColors.statutDisponible;
      case StatutLapin.engraissement:
        return AppColors.statutEngraissement;
      default:
        return AppColors.greyMedium;
    }
  }
}

class SexeIcon extends StatelessWidget {
  final SexeLapin sexe;
  final double size;

  const SexeIcon({
    super.key,
    required this.sexe,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    final isMale = sexe == SexeLapin.male;
    return Icon(
      isMale ? Icons.male : Icons.female,
      color: isMale ? AppColors.maleColor : AppColors.femelleColor,
      size: size,
    );
  }
}
