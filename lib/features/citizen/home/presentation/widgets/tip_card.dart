import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/shared/widgets/app_widgets.dart';

class TipCard extends StatelessWidget {
  final String tip;

  const TipCard({super.key, required this.tip});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: AppColors.primaryBlue.withOpacity(0.05),
      border: BorderSide(color: AppColors.primaryBlue.withOpacity(0.1)),
      child: Row(
        children: [
          const Icon(Icons.lightbulb_outline,
              color: AppColors.primaryBlue, size: 24),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              tip,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.primaryBlue),
            ),
          ),
        ],
      ),
    );
  }
}
