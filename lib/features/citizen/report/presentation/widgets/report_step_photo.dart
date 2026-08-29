import 'dart:io';
import 'package:flutter/material.dart';

import '../../../../../core/l10n/generated/app_localizations.dart';
import '../../../../../core/shared/widgets/app_widgets.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_text_styles.dart';

class ReportStepPhoto extends StatelessWidget {
  final File? image;
  final bool loading;
  final VoidCallback onPickImage;
  final VoidCallback onRemove;
  final VoidCallback onSubmit;

  const ReportStepPhoto({
    super.key,
    this.image,
    required this.loading,
    required this.onPickImage,
    required this.onRemove,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.addPhoto, style: AppTextStyles.headlineLarge),
          const SizedBox(height: AppSpacing.xs),
          Text(l10n.addPhotoSubtitle, style: AppTextStyles.bodySmall),
          const SizedBox(height: AppSpacing.xl),

          Expanded(
            child: AppCard(
              onTap: image == null ? onPickImage : null,
              padding: EdgeInsets.zero,
              child: image == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt_outlined,
                              color: AppColors.primaryBlue, size: 48),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(l10n.tapToCapture,
                            style: AppTextStyles.labelLarge.copyWith(color: AppColors.primaryBlue)),
                      ],
                    )
                  : Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: AppRadius.radiusLg,
                          child: Image.file(image!, fit: BoxFit.cover),
                        ),
                        Positioned(
                          top: AppSpacing.sm,
                          left: AppSpacing.sm,
                          child: IconButton.filled(
                            onPressed: onRemove,
                            icon: const Icon(Icons.close, size: 20),
                            style: IconButton.styleFrom(backgroundColor: AppColors.criticalRed),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          AppButton(
            label: l10n.sendReport,
            isLoading: loading,
            onPressed: onSubmit,
            icon: Icons.send_rounded,
          ),
          const SizedBox(height: AppSpacing.md),
          TextButton(
            onPressed: loading ? null : onSubmit,
            child: Text(l10n.sendWithoutPhoto),
          ),
        ],
      ),
    );
  }
}
