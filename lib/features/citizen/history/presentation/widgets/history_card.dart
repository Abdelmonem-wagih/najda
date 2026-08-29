import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/shared/widgets/app_widgets.dart';
import '../../../../../core/l10n/generated/app_localizations.dart';
import '../../../report/data/models/incident_model.dart';
import 'history_details_sheet.dart';

class HistoryCard extends StatelessWidget {
  final IncidentModel report;
  const HistoryCard({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isEmergency = report.type == 'sos';
    final status = report.status;
    final ts = report.reportedAt.toDate();
    final type = report.accidentType ?? '';

    return AppCard(
      onTap: () => _showDetails(context, report),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: isEmergency
                      ? AppColors.criticalRed.withOpacity(0.1)
                      : AppColors.primaryBlue.withOpacity(0.1),
                  borderRadius: AppRadius.radiusMd,
                ),
                child: Icon(
                  isEmergency
                      ? Icons.emergency_outlined
                      : Icons.medical_services_outlined,
                  color: isEmergency ? AppColors.criticalRed : AppColors.primaryBlue,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEmergency ? l10n.emergency_report : _typeLabel(context, type),
                      style: AppTextStyles.titleLarge,
                    ),
                    Text(
                      ts != null
                          ? DateFormat('dd MMM yyyy – HH:mm', 'ar').format(ts)
                          : '—',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
              AppStatusBadge(status: status),
            ],
          ),

          if (report.address.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            const Divider(),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                const Icon(Icons.location_on_outlined,
                    size: 16, color: AppColors.textMuted),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    report.address,
                    style: AppTextStyles.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
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

  void _showDetails(BuildContext context, IncidentModel r) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => HistoryDetailsSheet(report: r),
    );
  }
}
