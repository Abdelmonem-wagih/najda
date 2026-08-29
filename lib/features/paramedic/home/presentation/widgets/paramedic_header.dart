import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/shared/widgets/app_widgets.dart';
import '../../../../../core/l10n/generated/app_localizations.dart';
import '../../../../auth/domain/entities/app_user.dart';

class ParamedicHeader extends StatelessWidget {
  final AppUser user;
  final Function(bool) onAvailabilityChanged;

  const ParamedicHeader({
    super.key,
    required this.user,
    required this.onAvailabilityChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: const BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(AppRadius.xl)),
      ),
      child: AppCard(
        color: AppColors.white.withOpacity(0.1),
        border: BorderSide.none,
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: user.isAvailable ? AppColors.success : AppColors.textMuted,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.availability,
                      style: AppTextStyles.titleMedium.copyWith(color: AppColors.white)),
                  Text(
                    user.isAvailable ? l10n.availableForReports : l10n.notAvailable,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.white.withOpacity(0.7)),
                  ),
                ],
              ),
            ),
            Switch(
              value: user.isAvailable,
              onChanged: onAvailabilityChanged,
              activeColor: AppColors.success,
            ),
          ],
        ),
      ),
    );
  }
}
