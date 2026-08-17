import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/route/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/shared/widgets/app_widgets.dart';
import '../../auth/presentation/cubit/auth_cubit.dart';

class CitizenHomePage extends StatefulWidget {
  const CitizenHomePage({super.key});

  @override
  State<CitizenHomePage> createState() => _CitizenHomePageState();
}

class _CitizenHomePageState extends State<CitizenHomePage>
    with TickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulse;
  bool _sosLoading = false;

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

  Future<void> _triggerSOS() async {
    setState(() => _sosLoading = true);
    HapticFeedback.heavyImpact();

    try {
      final user = (context.read<AuthCubit>().state as AuthAuthenticated).user;

      final perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) await Geolocator.requestPermission();
      final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      final docRef = await FirebaseFirestore.instance
          .collection('emergency_reports')
          .add({
        'patientUid': user.id,
        'patientName': user.fullName ?? '',
        'nationalId': user.nationalId ?? '',
        'phoneNumber': user.phone ?? '',
        'emergencyContactNumber': user.emergencyContact ?? '',
        'latitude': pos.latitude,
        'longitude': pos.longitude,
        'address': '',
        'chronicDiseases': user.chronicDiseases,
        'allergies': user.allergies,
        'currentMedications': user.currentMedications,
        'additionalInfo': user.additionalInfo ?? '',
        'status': 'pending',
        'medicalReportSubmitted': false,
        'createdAt': FieldValue.serverTimestamp(),
        'timestamp': FieldValue.serverTimestamp(),
      });

      if ((user.emergencyContact ?? '').isNotEmpty) {
        final msg = Uri.encodeComponent(
          '🚨 *تنبيه طوارئ نجدة*\n\n'
          '${user.fullName ?? ''} أرسل بلاغ طوارئ!\n'
          '📍 الموقع: https://maps.google.com/?q=${pos.latitude},${pos.longitude}\n'
          '🏥 رقم البلاغ: ${docRef.id.substring(0, 6).toUpperCase()}\n'
          '⏰ الوقت: ${TimeOfDay.now().format(context)}\n\n'
          'تم إرسال الإسعاف تلقائياً.',
        );
        final wa = Uri.parse('https://wa.me/${user.emergencyContact}?text=$msg');
        if (await canLaunchUrl(wa)) await launchUrl(wa, mode: LaunchMode.externalApplication);
      }

      if (mounted) {
        _showSOSConfirm(docRef.id.substring(0, 6).toUpperCase());
      }
    } catch (e) {
      if (mounted) {
        _showError('فشل إرسال البلاغ: $e');
      }
    } finally {
      if (mounted) setState(() => _sosLoading = false);
    }
  }

  void _showSOSConfirm(String code) {
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
            Text('تم إرسال بلاغ الطوارئ!',
                style: AppTextStyles.headlineLarge, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.sm),
            Text('رقم البلاغ: R-$code',
                style: AppTextStyles.labelLarge.copyWith(color: AppColors.primaryBlue)),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'الإسعاف في الطريق إليك. ابقَ في مكانك وحافظ على هدوئك.',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: 'حسناً',
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
    final user = (context.watch<AuthCubit>().state as AuthAuthenticated).user;
    final name = user.fullName?.split(' ').first ?? 'مرحباً';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── App Bar / Header ─────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            backgroundColor: AppColors.navy,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.navyGradient,
                ),
                padding: const EdgeInsets.fromLTRB(20, 60, 20, 16),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'مرحباً، $name 👋',
                          style: AppTextStyles.headlineLarge.copyWith(color: AppColors.white),
                        ),
                        Text(
                          'كيف يمكننا مساعدتك اليوم؟',
                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.white.withOpacity(0.8)),
                        ),
                      ],
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(
                          context, AppRoutes.citizenProfile),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.white.withOpacity(0.3)),
                        ),
                        child: Center(
                          child: Text(
                            name.isNotEmpty ? name[0] : 'م',
                            style: AppTextStyles.headlineMedium.copyWith(color: AppColors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── SOS Section ─────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GestureDetector(
                    onTap: _sosLoading ? null : _triggerSOS,
                    child: ScaleTransition(
                      scale: _pulse,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                        decoration: BoxDecoration(
                          gradient: AppColors.criticalGradient,
                          borderRadius: AppRadius.radiusXl,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.criticalRed.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: _sosLoading
                            ? const Center(child: CircularProgressIndicator(color: Colors.white))
                            : Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(AppSpacing.md),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.emergency_outlined,
                                        color: Colors.white, size: 40),
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  Text(
                                    'طلب نجدة فورية',
                                    style: AppTextStyles.displaySmall.copyWith(color: AppColors.white),
                                  ),
                                  Text(
                                    'يُرسل موقعك وبياناتك الطبية فوراً',
                                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.white.withOpacity(0.9)),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // ── Quick Actions ─────────────────────────────────
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
                              Text('إبلاغ عن حادث', style: AppTextStyles.titleLarge),
                              Text('شاهدت حادثاً؟ أبلغ عنه لمساعدة الآخرين',
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

          // ── Services Grid ─────────────────────────────────
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
                _buildServiceCard(
                  context,
                  icon: Icons.medical_services_outlined,
                  label: 'إسعافات أولية',
                  color: AppColors.primaryBlue,
                  onTap: () => Navigator.pushNamed(
                      context, AppRoutes.citizenFirstAid),
                ),
                _buildServiceCard(
                  context,
                  icon: Icons.local_hospital_outlined,
                  label: 'مستشفيات',
                  color: AppColors.success,
                  onTap: () => Navigator.pushNamed(
                      context, AppRoutes.citizenHospitals),
                ),
                _buildServiceCard(
                  context,
                  icon: Icons.phone_outlined,
                  label: 'أرقام الطوارئ',
                  color: AppColors.warning,
                  onTap: () => Navigator.pushNamed(
                      context, AppRoutes.citizenEmergency),
                ),
                _buildServiceCard(
                  context,
                  icon: Icons.history_outlined,
                  label: 'سجل البلاغات',
                  color: AppColors.accentBlue,
                  onTap: () => Navigator.pushNamed(
                      context, AppRoutes.citizenHistory),
                ),
              ]),
            ),
          ),

          // ── Tip Card ────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: AppCard(
                color: AppColors.primaryBlue.withOpacity(0.05),
                border: BorderSide(color: AppColors.primaryBlue.withOpacity(0.1)),
                child: Row(
                  children: [
                    const Icon(Icons.lightbulb_outline,
                        color: AppColors.primaryBlue, size: 24),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        'حافظ على تحديث بياناتك الطبية لضمان حصولك على أفضل رعاية في حالات الطوارئ.',
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.primaryBlue),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
        ],
      ),
    );
  }

  Widget _buildServiceCard(BuildContext context,
      {required IconData icon,
      required String label,
      required Color color,
      required VoidCallback onTap}) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xs),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: AppRadius.radiusSm,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const Spacer(),
          Text(label, style: AppTextStyles.titleMedium),
        ],
      ),
    );
  }
}
