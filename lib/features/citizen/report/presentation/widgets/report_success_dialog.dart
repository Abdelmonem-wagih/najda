import 'package:flutter/material.dart';

import '../../../../../core/l10n/generated/app_localizations.dart';
import '../../../../../core/shared/widgets/app_widgets.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_text_styles.dart';

class ReportSuccessDialog extends StatelessWidget {
  const ReportSuccessDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusXl),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 72,
          height: 72,
          decoration: const BoxDecoration(
            color: AppColors.success,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_rounded, color: Colors.white, size: 38),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(l10n.reportSentSuccess, style: AppTextStyles.headlineLarge),
        const SizedBox(height: AppSpacing.sm),
        Text(l10n.ambulanceOnWay, style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
        const SizedBox(height: AppSpacing.lg),
        AppButton(
          label: l10n.backToHome,
          onPressed: () {
            Navigator.pop(context);
            Navigator.pop(context);
          },
        ),
      ]),
    );
  }
}
