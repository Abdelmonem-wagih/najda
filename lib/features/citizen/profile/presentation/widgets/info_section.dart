import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/shared/widgets/app_widgets.dart';

class InfoSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<(String, String)> rows;

  const InfoSection({
    super.key,
    required this.title,
    required this.icon,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: AppSpacing.xs, bottom: AppSpacing.sm),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primaryBlue, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Text(title, style: AppTextStyles.titleLarge),
            ],
          ),
        ),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: rows.asMap().entries.map((entry) {
              final isLast = entry.key == rows.length - 1;
              final r = entry.value;
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 120,
                          child: Text(r.$1,
                              style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textSecondary)),
                        ),
                        Expanded(
                          child: Text(r.$2, style: AppTextStyles.labelLarge),
                        ),
                      ],
                    ),
                  ),
                  if (!isLast) const Divider(),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
