import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/shared/widgets/app_widgets.dart';
import '../../../../../core/l10n/generated/app_localizations.dart';
import '../../../../../core/constants/firestore_contract.dart';
import '../../../../../core/route/app_routes.dart';
// Hides the dead/legacy IncidentStatus enum defined in incident_model.dart
// (reported/ai_assigning/en_route/resolved/... — never actually written
// anywhere) so this file's canonical IncidentStatus (from
// firestore_contract.dart) isn't ambiguous.
import '../../../report/data/models/incident_model.dart' hide IncidentStatus;
import 'history_details_sheet.dart';

class HistoryCard extends StatelessWidget {
  final IncidentModel report;
  const HistoryCard({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isEmergency = report.type == 'sos' || report.type == 'emergency';
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
                      // report.reportedAt is a non-nullable Timestamp, so
                      // ts can never actually be null (confirmed benign —
                      // not the logic bug flagged by flutter analyze).
                      DateFormat('dd MMM yyyy – HH:mm', 'ar').format(ts),
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
              AppStatusBadge(status: status),
            ],
          ),
          if (![IncidentStatus.completed, IncidentStatus.cancelled, IncidentStatus.duplicate].contains(status)) ...[
            const SizedBox(height: AppSpacing.md),
            GestureDetector(
              onTap: () => Navigator.pushNamed(
                context,
                AppRoutes.trackIncident,
                arguments: {
                  'reportId': report.id,
                  // Must match TrackingPage's incidentKindFor() check — this
                  // used to send 'emergency_report'/'report', neither of
                  // which is ever 'critical', so tracking a past SOS from
                  // History always queried the wrong collection and the
                  // tracking screen hung forever on "جارٍ تحديد الموقع...".
                  'reportType': report.type == 'sos' ? 'critical' : 'incident',
                  'displayId': report.id.length > 6 ? report.id.substring(0, 6) : report.id,
                  'patientLat': report.location.latitude,
                  'patientLng': report.location.longitude,
                },
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.1),
                  borderRadius: AppRadius.radiusMd,
                  border: Border.all(color: AppColors.primaryBlue.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.my_location_rounded,
                        color: AppColors.primaryBlue, size: 16),
                    const SizedBox(width: AppSpacing.xs),
                    Text('تتبع الإسعاف',
                        style: AppTextStyles.labelLarge
                            .copyWith(color: AppColors.primaryBlue)),
                  ],
                ),
              ),
            ),
          ],

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
