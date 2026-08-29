import 'package:flutter/material.dart';
import '../../../../../core/l10n/generated/app_localizations.dart';
import '../../../../../core/shared/widgets/app_widgets.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/accident_type.dart';

class ReportStepType extends StatelessWidget {
  final AccidentType? selected;
  final ValueChanged<AccidentType> onSelect;

  const ReportStepType({super.key, this.selected, required this.onSelect});

  String _getAccidentLabel(BuildContext context, AccidentType type) {
    final l10n = AppLocalizations.of(context)!;
    switch (type) {
      case AccidentType.carAccident:
        return l10n.accidentCarAccident;
      case AccidentType.pedestrianHit:
        return l10n.accidentPedestrianHit;
      case AccidentType.fallFromHeight:
        return l10n.accidentFallFromHeight;
      case AccidentType.fall:
        return l10n.accidentFall;
      case AccidentType.electricShock:
        return l10n.accidentElectricShock;
      case AccidentType.fireBurn:
        return l10n.accidentFireBurn;
      case AccidentType.suffocation:
        return l10n.accidentSuffocation;
      case AccidentType.drowning:
        return l10n.accidentDrowning;
      case AccidentType.workInjury:
        return l10n.accidentWorkInjury;
      case AccidentType.poisoning:
        return l10n.accidentPoisoning;
      case AccidentType.assault:
        return l10n.accidentAssault;
      case AccidentType.sportInjury:
        return l10n.accidentSportInjury;
      case AccidentType.gunshot:
        return l10n.accidentGunshot;
      case AccidentType.stabbing:
        return l10n.accidentStabbing;
      case AccidentType.medicalEmergency:
        return l10n.accidentMedicalEmergency;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.selectAccidentType, style: AppTextStyles.headlineLarge),
              const SizedBox(height: AppSpacing.xs),
              Text(l10n.accidentTypeSubtitle,
                  style: AppTextStyles.bodySmall),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: AppSpacing.md,
              crossAxisSpacing: AppSpacing.md,
              childAspectRatio: 0.9,
            ),
            itemCount: AccidentType.values.length,
            itemBuilder: (ctx, i) {
              final t = AccidentType.values[i];
              final sel = selected == t;
              return AppCard(
                onTap: () => onSelect(t),
                padding: EdgeInsets.zero,
                color: sel ? AppColors.primaryBlue : AppColors.surface,
                border: BorderSide(color: sel ? AppColors.primaryBlue : AppColors.border),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(t.icon,
                        color: sel ? AppColors.white : AppColors.primaryBlue,
                        size: 28),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      _getAccidentLabel(context, t),
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: sel ? AppColors.white : AppColors.textPrimary,
                        fontSize: 10,
                        fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
