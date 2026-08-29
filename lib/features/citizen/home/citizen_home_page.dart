import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/route/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/shared/widgets/app_widgets.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../auth/presentation/cubit/auth_cubit.dart';
import 'presentation/cubit/sos_cubit.dart';
import 'presentation/widgets/home_header.dart';
import 'presentation/widgets/sos_button.dart';
import 'presentation/widgets/service_card.dart';
import 'presentation/widgets/tip_card.dart';

class CitizenHomePage extends StatefulWidget {
  const CitizenHomePage({super.key});

  @override
  State<CitizenHomePage> createState() => _CitizenHomePageState();
}

class _CitizenHomePageState extends State<CitizenHomePage>
    with TickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.98, end: 1.02).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _triggerSOS() {
    HapticFeedback.heavyImpact();
    final user = (context.read<AuthCubit>().state as AuthAuthenticated).user;
    context.read<SOSCubit>().triggerSOS(user);
  }

  Future<void> _handleSOSSuccess(SOSSuccess state) async {
    final user = (context.read<AuthCubit>().state as AuthAuthenticated).user;
    
    // 1. Immediate Emergency Call
    final emergencyPhone = user.emergencyContact;
    if (emergencyPhone.isNotEmpty) {
      final tel = Uri.parse('tel:$emergencyPhone');
      if (await canLaunchUrl(tel)) {
        await launchUrl(tel);
      }
    }

    // 2. Navigate to Tracking/Confirmation Screen
    // We pass the reportId to the tracking screen which will listen for status changes
    Navigator.pushNamed(
      context,
      AppRoutes.citizenTracking,
      arguments: state.reportId,
    );
  }


  void _showSOSConfirm(String code) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusXl),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded,
                  color: Colors.white, size: 38),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(l10n.sosSentTitle,
                style: AppTextStyles.headlineLarge, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.sm),
            Text(l10n.reportNumber(code),
                style: AppTextStyles.labelLarge.copyWith(color: AppColors.primaryBlue)),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.sosSentSubtitle,
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: l10n.ok,
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: AppColors.criticalRed,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusMd),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authState = context.watch<AuthCubit>().state as AuthAuthenticated;
    final user = authState.user;
    final name = user.fullName ?? '';

    return BlocListener<SOSCubit, SOSState>(
      listener: (context, state) {
        if (state is SOSSuccess) {
          _handleSOSSuccess(state);
        } else if (state is SOSError) {
          _showError(state.message);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: CustomScrollView(
          slivers: [
            HomeHeader(name: name),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    BlocBuilder<SOSCubit, SOSState>(
                      builder: (context, state) {
                        return SOSButton(
                          onTap: _triggerSOS,
                          isLoading: state is SOSLoading,
                          scaleAnimation: _pulse,
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    AppCard(
                      onTap: () => Navigator.pushNamed(
                          context, AppRoutes.citizenReport),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: AppColors.primaryBlue.withOpacity(0.1),
                              borderRadius: AppRadius.radiusMd,
                            ),
                            child: const Icon(Icons.assignment_outlined,
                                color: AppColors.primaryBlue, size: 24),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(l10n.reportIncidentTitle, style: AppTextStyles.titleLarge),
                                Text(l10n.reportIncidentSubtitle,
                                    style: AppTextStyles.bodySmall),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: AppColors.textMuted),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: AppSpacing.md,
                  crossAxisSpacing: AppSpacing.md,
                  childAspectRatio: 1.2,
                ),
                delegate: SliverChildListDelegate([
                  ServiceCard(
                    icon: Icons.medical_services_outlined,
                    label: l10n.firstAid,
                    color: AppColors.primaryBlue,
                    onTap: () => Navigator.pushNamed(
                        context, AppRoutes.citizenFirstAid),
                  ),
                  ServiceCard(
                    icon: Icons.local_hospital_outlined,
                    label: l10n.hospitals,
                    color: AppColors.success,
                    onTap: () => Navigator.pushNamed(
                        context, AppRoutes.citizenHospitals),
                  ),
                  ServiceCard(
                    icon: Icons.phone_outlined,
                    label: l10n.emergency,
                    color: AppColors.warning,
                    onTap: () => Navigator.pushNamed(
                        context, AppRoutes.citizenEmergency),
                  ),
                  ServiceCard(
                    icon: Icons.history_outlined,
                    label: l10n.history,
                    color: AppColors.accentBlue,
                    onTap: () => Navigator.pushNamed(
                        context, AppRoutes.citizenHistory),
                  ),
                ]),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: TipCard(tip: l10n.medicalTip),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
          ],
        ),
      ),
    );
  }
}
