import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/l10n/generated/app_localizations.dart';
import '../../../report/data/models/incident_model.dart';

class HistoryDetailsSheet extends StatelessWidget {
  final IncidentModel report;
  const HistoryDetailsSheet({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.xl)),
      ),
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.xl),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(l10n.reportDetails,
                style: AppTextStyles.headlineMedium),
            const SizedBox(height: AppSpacing.lg),
            ..._rows(context, report).map((row) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 120,
                        child: Text(row.$1,
                            style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.textSecondary)),
                      ),
                      Expanded(
                        child: Text(row.$2,
                            style: AppTextStyles.bodyLarge),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  List<(String, String)> _rows(BuildContext context, IncidentModel r) {
    final l10n = AppLocalizations.of(context)!;
    final rows = <(String, String)>[];
    
    if (r.accidentType != null) {
      rows.add((l10n.reportType, _typeLabel(context, r.accidentType!)));
    }
    
    if (r.consciousnessLevel != null && r.consciousnessLevel!.isNotEmpty) {
      rows.add((l10n.consciousnessLevel, r.consciousnessLevel!));
    }
    
    if (r.injuryLocation != null && r.injuryLocation!.isNotEmpty) {
      rows.add((l10n.injuryLocation, r.injuryLocation!));
    }
    
    if (r.painLevel != null && r.painLevel!.isNotEmpty) {
      rows.add((l10n.painLevel, r.painLevel!));
    }
    
    rows.add((l10n.reportStatus, IncidentStatus.label(r.status)));
    
    if (r.address.isNotEmpty) {
      rows.add((l10n.patientLocation, r.address));
    }
    
    return rows;
  }

  String _typeLabel(BuildContext context, String key) {
    final l10n = AppLocalizations.of(context)!;
    switch (key) {
      case 'carAccident':      return l10n.accidentCarAccident;
      case 'pedestrianHit':    return l10n.accidentPedestrianHit;
      case 'fallFromHeight':   return l10n.accidentFallFromHeight;
      case 'fall':             return l10n.accidentFall;
      case 'electricShock':    return l10n.accidentElectricShock;
      case 'fireBurn':         return l10n.accidentFireBurn;
      case 'suffocation':      return l10n.accidentSuffocation;
      case 'drowning':         return l10n.accidentDrowning;
      case 'workInjury':       return l10n.accidentWorkInjury;
      case 'poisoning':        return l10n.accidentPoisoning;
      case 'assault':          return l10n.accidentAssault;
      case 'sportInjury':      return l10n.accidentSportInjury;
      case 'gunshot':          return l10n.accidentGunshot;
      case 'stabbing':         return l10n.accidentStabbing;
      case 'medicalEmergency': return l10n.accidentMedicalEmergency;
      default:                 return key;
    }
  }
}
