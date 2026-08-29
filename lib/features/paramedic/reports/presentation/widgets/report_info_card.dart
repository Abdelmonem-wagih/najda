import 'package:flutter/material.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/shared/widgets/app_widgets.dart';
import '../../../../../core/l10n/generated/app_localizations.dart';
import '../../../../citizen/report/data/models/incident_model.dart';

class ReportInfoCard extends StatelessWidget {
  final IncidentModel report;

  const ReportInfoCard({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(l10n.statusLabel, style: AppTextStyles.titleMedium),
              const SizedBox(width: AppSpacing.sm),
              AppStatusBadge(status: report.status),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const Divider(),
          const SizedBox(height: AppSpacing.md),
          _buildInfoRow(l10n.fullNameLabel, report.reporterMedicalProfile?['patientName'] ?? 'Anonymous'),
          if ((report.reporterPhone ?? '').isNotEmpty) _buildInfoRow(l10n.phoneNumber, report.reporterPhone!),
          if ((report.location.address ?? '').isNotEmpty) _buildInfoRow(l10n.patientLocation, report.location.address!),
          _buildInfoRow(l10n.accidentTypeLabel, report.type),
        ],
      ),
    );

  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 100, child: Text(label, style: AppTextStyles.bodySmall)),
          Expanded(child: Text(value, style: AppTextStyles.bodyMedium)),
        ],
      ),
    );
  }
}
