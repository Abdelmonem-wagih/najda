import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/shared/widgets/app_widgets.dart';
import '../../../../core/l10n/generated/app_localizations.dart';
import '../../auth/presentation/cubit/auth_cubit.dart';
import 'presentation/cubit/report_details_cubit.dart';
import 'presentation/cubit/report_details_state.dart';
import 'presentation/widgets/medical_form.dart';
import 'presentation/widgets/report_info_card.dart';
import 'data/repositories/report_details_repository_impl.dart';
import 'data/datasources/report_details_remote_datasource.dart';

class ReportDetailsPage extends StatelessWidget {
  final String reportId;
  final String reportType;

  const ReportDetailsPage({
    super.key,
    required this.reportId,
    required this.reportType,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ReportDetailsCubit(
        repository: ReportDetailsRepositoryImpl(
          remoteDataSource: ReportDetailsRemoteDataSourceImpl(),
        ),
      )..loadReport(reportId, reportType),
      child: _ReportDetailsView(reportId: reportId, reportType: reportType),
    );
  }
}

class _ReportDetailsView extends StatefulWidget {
  final String reportId;
  final String reportType;

  const _ReportDetailsView({required this.reportId, required this.reportType});

  @override
  State<_ReportDetailsView> createState() => _ReportDetailsViewState();
}

class _ReportDetailsViewState extends State<_ReportDetailsView> {
  final _medAnswers = <String, String>{};
  final _notesCtrl = TextEditingController();
  GoogleMapController? _mapCtrl;

  @override
  void dispose() {
    _notesCtrl.dispose();
    _mapCtrl?.dispose();
    super.dispose();
  }

  void _openNavigation(double lat, double lng) async {
    final url = Uri.parse('google.navigation:q=$lat,$lng&mode=d');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      await launchUrl(
          Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<ReportDetailsCubit, ReportDetailsState>(
      builder: (context, state) {
        if (state is ReportDetailsLoading) {
          return Scaffold(body: AppLoader(message: l10n.loadingDetails));
        }
        if (state is ReportDetailsError) {
          return Scaffold(body: AppEmptyState(icon: Icons.error, title: l10n.error, subtitle: state.message));
        }
        if (state is ReportDetailsLoaded) {
          final report = state.report;
          final user = (context.read<AuthCubit>().state as AuthAuthenticated).user;

          if (state.showMedicalForm) {
            return Scaffold(
              appBar: AppBar(
                backgroundColor: AppColors.navy,
                title: Text(l10n.reportDetails),
              ),
              body: MedicalForm(
                answers: _medAnswers,
                notesCtrl: _notesCtrl,
                submitting: state.isSubmitting,
                onSubmit: () => context.read<ReportDetailsCubit>().submitMedicalReport(
                      reportId: widget.reportId,
                      reportType: widget.reportType,
                      paramedic: user,
                      answers: _medAnswers,
                      notes: _notesCtrl.text.trim(),
                    ),
                onCancel: () => context.read<ReportDetailsCubit>().toggleMedicalForm(false),
              ),
            );
          }

          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: AppColors.navy,
              title: Text(l10n.reportDetails),
              actions: [
                if (report.phoneNumber.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.phone),
                    onPressed: () => launchUrl(Uri.parse('tel:${report.phoneNumber}')),
                  ),
              ],
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: 250,
                    child: GoogleMap(
                      initialCameraPosition:
                          CameraPosition(target: LatLng(report.location.latitude, report.location.longitude), zoom: 15),
                      markers: {
                        Marker(
                            markerId: const MarkerId('patient'),
                            position: LatLng(report.location.latitude, report.location.longitude)),

                        if (state.myPosition != null)
                          Marker(
                            markerId: const MarkerId('me'),
                            position: LatLng(state.myPosition!.latitude, state.myPosition!.longitude),
                            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
                          ),
                      },
                      onMapCreated: (c) => _mapCtrl = c,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ReportInfoCard(report: report),
                        const SizedBox(height: AppSpacing.lg),
                        _buildActionButtons(context, state),
                        const SizedBox(height: AppSpacing.xl),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildActionButtons(BuildContext context, ReportDetailsLoaded state) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<ReportDetailsCubit>();
    final report = state.report;
    final status = report.status;
    final paramedicId = (context.read<AuthCubit>().state as AuthAuthenticated).user.id;

    return Column(
      children: [
        AppButton(
            label: l10n.navigationToLocation,
            onPressed: () => _openNavigation(report.location.latitude, report.location.longitude),
            icon: Icons.navigation_rounded),
        const SizedBox(height: AppSpacing.md),
        
        if (status == AppConstants.statusAssigned)
          AppButton(
            label: l10n.acceptReport,
            onPressed: () => cubit.updateStatus(
                widget.reportId, widget.reportType, paramedicId, AppConstants.statusEnRoute),
            isLoading: state.isSubmitting,
            icon: Icons.check_circle_rounded,
          ),
          
        if (status == AppConstants.statusEnRoute)
          AppButton(
            label: l10n.confirmArrival,
            onPressed: () => cubit.updateStatus(
                widget.reportId, widget.reportType, paramedicId, AppConstants.statusArrived),
            isLoading: state.isSubmitting,
            icon: Icons.home_work_rounded,
          ),
          
        if (status == AppConstants.statusArrived)
          AppButton(
            label: l10n.fillMedicalReport,
            onPressed: () => cubit.toggleMedicalForm(true),
            icon: Icons.assignment_rounded,
          ),
          
        if (status == AppConstants.statusResolved)
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: AppRadius.radiusMd,
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: AppColors.success),
                const SizedBox(width: AppSpacing.sm),
                Text(l10n.missionCompleted, style: AppTextStyles.titleMedium.copyWith(color: AppColors.success)),
              ],
            ),
          ),
      ],
    );
  }

}
