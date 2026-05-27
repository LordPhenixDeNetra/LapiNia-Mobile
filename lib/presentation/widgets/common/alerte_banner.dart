import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';

class AlerteBanner extends StatelessWidget {
  final String message;
  final int priorite;
  final VoidCallback? onDismiss;
  final VoidCallback? onAction;

  const AlerteBanner({
    super.key,
    required this.message,
    required this.priorite,
    this.onDismiss,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getColor();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 2),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: AppTypography.body2,
            ),
          ),
          if (onAction != null)
            IconButton(
              icon: Icon(Icons.check_circle_outline, color: color),
              onPressed: onAction,
            ),
          if (onDismiss != null)
            IconButton(
              icon: const Icon(Icons.close, color: AppColors.greyMedium),
              onPressed: onDismiss,
            ),
        ],
      ),
    );
  }

  Color _getColor() {
    switch (priorite) {
      case 1:
        return AppColors.danger;
      case 2:
        return AppColors.alert;
      default:
        return AppColors.warning;
    }
  }
}
