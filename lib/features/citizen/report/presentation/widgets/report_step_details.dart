import 'package:flutter/material.dart';

import '../../../../../core/l10n/generated/app_localizations.dart';
import '../../../../../core/shared/widgets/app_widgets.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_text_styles.dart';

class ReportStepDetails extends StatelessWidget {
  final String? consciousness;
  final String? injuryLocation;
  final String? painLevel;
  final ValueChanged<String?> onConsciousness;
  final ValueChanged<String?> onInjury;
  final ValueChanged<String?> onPain;
  final VoidCallback onNext;

  const ReportStepDetails({
    super.key,
    this.consciousness,
    this.injuryLocation,
    this.painLevel,
    required this.onConsciousness,
    required this.onInjury,
    required this.onPain,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final consciousnessOpts = [l10n.conscious, l10n.semiconscious, l10n.unconscious];
    final injuryOpts = [
      l10n.head,
      l10n.neck,
      l10n.chest,
      l10n.abdomen,
      l10n.arm,
      l10n.leg,
      l10n.backBody,
      l10n.multiple,
      l10n.unspecified,
    ];
    final painOpts = [l10n.mild, l10n.moderate, l10n.severe, l10n.unbearable];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.injuryDetailsTitle, style: AppTextStyles.headlineLarge),
          const SizedBox(height: AppSpacing.xs),
          Text(l10n.injuryDetailsSubtitle, style: AppTextStyles.bodySmall),
          const SizedBox(height: AppSpacing.xl),

          _buildChipGroup(context, '${l10n.consciousnessLevel} *', consciousnessOpts, consciousness,
              onConsciousness, AppColors.criticalRed),
          const SizedBox(height: AppSpacing.lg),

          _buildChipGroup(context, l10n.injuryLocation, injuryOpts, injuryLocation, onInjury,
              AppColors.primaryBlue),
          const SizedBox(height: AppSpacing.lg),

          _buildChipGroup(context, l10n.painLevel, painOpts, painLevel, onPain, AppColors.warning),
          const SizedBox(height: AppSpacing.xxl),

          AppButton(
            label: l10n.nextAddPhoto,
            onPressed: onNext,
            icon: Icons.arrow_forward_ios_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildChipGroup(
    BuildContext context,
    String title,
    List<String> opts,
    String? selected,
    ValueChanged<String?> onChange,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.titleLarge),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: opts.map((o) {
            final sel = selected == o;
            return ChoiceChip(
              label: Text(o),
              selected: sel,
              onSelected: (val) => onChange(val ? o : null),
              selectedColor: color.withOpacity(0.2),
              labelStyle: AppTextStyles.bodyMedium.copyWith(
                color: sel ? color : AppColors.textPrimary,
                fontWeight: sel ? FontWeight.w700 : FontWeight.w400,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.radiusXl,
                side: BorderSide(color: sel ? color : AppColors.border),
              ),
              showCheckmark: false,
            );
          }).toList(),
        ),
      ],
    );
  }
}
