import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/shared/widgets/app_widgets.dart';
import '../../../../../core/l10n/generated/app_localizations.dart';
import '../../../../citizen/report/data/models/incident_model.dart';

class AmbulanceReportCard extends StatelessWidget {
  final IncidentModel report;
  final VoidCallback onTap;

  const AmbulanceReportCard({
    super.key,
    required this.report,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isEmergency = report.incidentType == 'emergency';
    final status = report.status;
    final patientName = report.patientName.isNotEmpty ? report.patientName : l10n.error; // Fallback?
    final address = report.address;

    return AppCard(
      onTap: onTap,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: (isEmergency ? AppColors.criticalRed : AppColors.primaryBlue)
                      .withOpacity(0.1),
                  borderRadius: AppRadius.radiusMd,
                ),
                child: Icon(
                  isEmergency ? Icons.emergency_rounded : Icons.assignment_rounded,
                  color: isEmergency ? AppColors.criticalRed : AppColors.primaryBlue,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(patientName, style: AppTextStyles.titleLarge),
                    Text(address.isEmpty ? l10n.locationNotSpecified : address,
                        style: AppTextStyles.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              AppStatusBadge(status: status),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const Divider(),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                  child: AppButton(
                      label: l10n.details,
                      isPrimary: false,
                      onPressed: onTap,
                      icon: Icons.info_outline)),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppButton(
                  label: l10n.navigation,
                  onPressed: () => _navigate(report.location.latitude, report.location.longitude),
                  icon: Icons.navigation_rounded,
                ),
              ),

            ],
          ),
        ],
      ),
    );
  }

  Future<void> _navigate(double lat, double lng) async {
    final url = Uri.parse('google.navigation:q=$lat,$lng&mode=d');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      await launchUrl(
          Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng'));
    }
  }
}
