import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/constants/enums.dart';
import '../../core/models/lapin.dart';

class LapinCard extends StatelessWidget {
  final Lapin lapin;
  final bool hasAlerte;
  final VoidCallback? onTap;

  const LapinCard({
    super.key,
    required this.lapin,
    this.hasAlerte = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isMale = lapin.sexe == SexeLapin.male;
    final photoUrl = lapin.photoUrl?.trim();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap ?? () => context.push('/lapin/${lapin.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              if (photoUrl != null && photoUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: CachedNetworkImage(
                    imageUrl: photoUrl,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: 60,
                      height: 60,
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withValues(alpha: 0.5),
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: isMale
                            ? AppColors.maleColor.withValues(alpha: 0.1)
                            : AppColors.femelleColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Icon(
                        isMale ? Icons.male : Icons.female,
                        color: isMale
                            ? AppColors.maleColor
                            : AppColors.femelleColor,
                        size: 32,
                      ),
                    ),
                  ),
                )
              else
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: isMale
                        ? AppColors.maleColor.withValues(alpha: 0.1)
                        : AppColors.femelleColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Icon(
                    isMale ? Icons.male : Icons.female,
                    color: isMale
                        ? AppColors.maleColor
                        : AppColors.femelleColor,
                    size: 32,
                  ),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            lapin.nom,
                            style: AppTypography.subtitle1,
                          ),
                        ),
                        if (hasAlerte)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.danger,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lapin.race?.nom ?? 'Race inconnue',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.greyMedium,
                      ),
                    ),
                    if (lapin.poidsActuelG != null)
                      Text(
                        '${(lapin.poidsActuelG! / 1000).toStringAsFixed(2)} kg',
                        style: AppTypography.body2,
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _getStatutColor(lapin.statut),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  lapin.statut.label,
                  style: AppTypography.caption.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right,
                color: AppColors.greyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatutColor(StatutLapin statut) {
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
