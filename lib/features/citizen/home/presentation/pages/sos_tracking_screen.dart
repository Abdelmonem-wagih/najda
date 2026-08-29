import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/shared/widgets/app_widgets.dart';
import '../../../../../core/l10n/generated/app_localizations.dart';
import '../../../report/data/models/incident_model.dart';

class SosTrackingScreen extends StatelessWidget {
  final String reportId;
  const SosTrackingScreen({super.key, required this.reportId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.criticalRed,
        title: Text(l10n.sosSentTitle),
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection(AppConstants.incidentsCollection)
            .doc(reportId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return AppEmptyState(icon: Icons.error, title: l10n.error, subtitle: snapshot.error.toString());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const AppLoader();
          }

          final incident = IncidentModel.fromFirestore(snapshot.data!);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _StatusCard(incident: incident),
                const SizedBox(height: AppSpacing.lg),
                if (incident.assignment?.ambulanceId != null)
                  _AmbulanceCard(incident: incident),
                const SizedBox(height: AppSpacing.lg),
                if (incident.assignedHospital?.name != null)
                  _HospitalCard(incident: incident),
                const SizedBox(height: AppSpacing.xl),
                AppButton(
                  label: l10n.ok,
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final IncidentModel incident;
  const _StatusCard({required this.incident});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AppCard(
      child: Column(
        children: [
          const Icon(Icons.emergency_rounded, size: 48, color: AppColors.criticalRed),
          const SizedBox(height: AppSpacing.md),
          Text(l10n.sosSentSubtitle, style: AppTextStyles.titleLarge, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(l10n.statusLabel, style: AppTextStyles.bodyMedium),
              const SizedBox(width: AppSpacing.sm),
              AppStatusBadge(status: incident.status),
            ],
          ),
        ],
      ),
    );
  }
}

class _AmbulanceCard extends StatelessWidget {
  final IncidentModel incident;
  const _AmbulanceCard({required this.incident});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AppCard(
      color: AppColors.primaryBlue.withOpacity(0.05),
      border: BorderSide(color: AppColors.primaryBlue.withOpacity(0.2)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.emergency_rounded, color: AppColors.primaryBlue),
              const SizedBox(width: AppSpacing.sm),
              Text(l10n.ambulanceAssigned, style: AppTextStyles.titleMedium),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            '${l10n.paramedicName}: ${incident.assignment?.paramedicName ?? "..."}',
            style: AppTextStyles.bodyMedium,
          ),
          Text(
            '${l10n.plateNumberLabel}: ${incident.assignment?.ambulancePlate ?? "..."}',
            style: AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          const LinearProgressIndicator(
            backgroundColor: AppColors.border,
            valueColor: AlwaysStoppedAnimation(AppColors.primaryBlue),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text('Ambulance is en route to your location', style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }
}


class _HospitalCard extends StatelessWidget {
  final IncidentModel incident;
  const _HospitalCard({required this.incident});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: AppColors.success.withOpacity(0.05),
      border: BorderSide(color: AppColors.success.withOpacity(0.2)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.local_hospital_rounded, color: AppColors.success),
              const SizedBox(width: AppSpacing.sm),
              Text('Assigned Hospital', style: AppTextStyles.titleMedium),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            incident.assignedHospital?.name ?? '',
            style: AppTextStyles.titleLarge,
          ),
          Text(
            incident.assignedHospital?.address ?? '',
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }
}
