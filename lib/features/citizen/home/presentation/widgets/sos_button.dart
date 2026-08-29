import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/l10n/generated/app_localizations.dart';

class SOSButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isLoading;
  final Animation<double> scaleAnimation;

  const SOSButton({
    super.key,
    required this.onTap,
    required this.isLoading,
    required this.scaleAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: ScaleTransition(
        scale: scaleAnimation,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
          decoration: BoxDecoration(
            gradient: AppColors.criticalGradient,
            borderRadius: AppRadius.radiusXl,
            boxShadow: [
              BoxShadow(
                color: AppColors.criticalRed.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: isLoading
              ? const Center(child: CircularProgressIndicator(color: Colors.white))
              : Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.emergency_outlined,
                          color: Colors.white, size: 40),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      l10n.sosButtonTitle,
                      style: AppTextStyles.displaySmall.copyWith(color: AppColors.white),
                    ),
                    Text(
                      l10n.sosButtonSubtitle,
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.white.withOpacity(0.9)),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
