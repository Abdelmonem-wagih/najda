import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/route/app_routes.dart';
import '../../../core/theme/design.dart';
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
    _pulse = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  // ── SOS one-tap emergency ────────────────────────────────────────
  Future<void> _triggerSOS() async {
    setState(() => _sosLoading = true);
    HapticFeedback.heavyImpact();

    try {
      final user = (context.read<AuthCubit>().state as AuthAuthenticated).user;

      final perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) await Geolocator.requestPermission();
      final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      // Send emergency report with full medical profile
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

      // Send WhatsApp to emergency contact
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
      builder: (_) => Dialog(
        backgroundColor: NC.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  gradient: NC.successGrad,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded,
                    color: Colors.white, size: 38),
              ),
              const SizedBox(height: 20),
              Text('تم إرسال بلاغ الطوارئ!',
                  style: NC.display(18), textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text('رقم البلاغ: R-$code',
                  style: NC.label(14, color: NC.primary)),
              const SizedBox(height: 6),
              Text(
                'الإسعاف في الطريق إليك. ابقَ في مكانك وحافظ على هدوئك.',
                style: NC.body(13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              GradientButton(
                label: 'حسناً',
                gradient: NC.primaryGrad,
                height: 48,
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: NC.body(13, color: Colors.white)),
      backgroundColor: NC.critical,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final user = (context.watch<AuthCubit>().state as AuthAuthenticated).user;
    final name = user.fullName?.split(' ').first ?? 'مرحباً';

    return Scaffold(
      backgroundColor: NC.base,
      body: Stack(
        children: [
          // ── Background radial glow ───────────────────────────────
          Positioned(
            top: -80,
            right: -60,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    NC.critical.withOpacity(0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            left: -80,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    NC.primary.withOpacity(0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: CustomScrollView(
              slivers: [
                // ── Header ─────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('مرحباً، $name 👋',
                                style: NC.display(22)),
                            const SizedBox(height: 3),
                            Text('كيف يمكننا مساعدتك اليوم؟',
                                style: NC.body(13)),
                          ],
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(
                              context, AppRoutes.citizenProfile),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              gradient: NC.primaryGrad,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                name.isNotEmpty ? name[0] : 'م',
                                style: NC.display(18, color: NC.base),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── SOS BUTTON ─────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                    child: GestureDetector(
                      onTap: _sosLoading ? null : _triggerSOS,
                      child: ScaleTransition(
                        scale: _pulse,
                        child: Container(
                          height: 180,
                          decoration: BoxDecoration(
                            gradient: NC.criticalGrad,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: NC.critical.withOpacity(0.5),
                                blurRadius: 36,
                                spreadRadius: 2,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              // Grid pattern overlay
                              Positioned.fill(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(28),
                                  child: CustomPaint(painter: _GridPainter()),
                                ),
                              ),
                              Center(
                                child: _sosLoading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 3)
                                    : Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: 64,
                                            height: 64,
                                            decoration: BoxDecoration(
                                              color: Colors.white
                                                  .withOpacity(0.2),
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                  color: Colors.white
                                                      .withOpacity(0.4),
                                                  width: 2),
                                            ),
                                            child: const Icon(
                                                Icons.emergency_outlined,
                                                color: Colors.white,
                                                size: 32),
                                          ),
                                          const SizedBox(height: 14),
                                          Text('اضغط للطوارئ',
                                              style: NC.display(24,
                                                  color: Colors.white)),
                                          const SizedBox(height: 4),
                                          Text(
                                            'يُرسل موقعك + بياناتك الطبية فوراً',
                                            style: NC.body(12,
                                                color: Colors.white
                                                    .withOpacity(0.8)),
                                          ),
                                        ],
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // ── Report incident (third party) ──────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: GlassCard(
                      onTap: () => Navigator.pushNamed(
                          context, AppRoutes.citizenReport),
                      child: Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              gradient: NC.primaryGrad,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.assignment_outlined,
                                color: NC.base, size: 26),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('إبلاغ عن حادث',
                                    style: NC.label(15)),
                                const SizedBox(height: 3),
                                Text(
                                  'شاهدت حادثاً؟ أبلغ عنه لشخص آخر',
                                  style: NC.body(12),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right,
                              color: NC.textLow),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Quick Services ─────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                    child: SectionHeader('الخدمات'),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.15,
                    ),
                    delegate: SliverChildListDelegate([
                      _QuickCard(
                        icon: Icons.medical_services_outlined,
                        label: 'إسعافات أولية',
                        sublabel: 'دليل بالصور',
                        color: NC.primary,
                        onTap: () => Navigator.pushNamed(
                            context, AppRoutes.citizenFirstAid),
                      ),
                      _QuickCard(
                        icon: Icons.local_hospital_outlined,
                        label: 'مستشفيات قريبة',
                        sublabel: 'خريطة وأرقام',
                        color: NC.success,
                        onTap: () => Navigator.pushNamed(
                            context, AppRoutes.citizenHospitals),
                      ),
                      _QuickCard(
                        icon: Icons.phone_outlined,
                        label: 'أرقام الطوارئ',
                        sublabel: 'اتصال مباشر',
                        color: NC.warning,
                        onTap: () => Navigator.pushNamed(
                            context, AppRoutes.citizenEmergency),
                      ),
                      _QuickCard(
                        icon: Icons.history_outlined,
                        label: 'سجل البلاغات',
                        sublabel: 'بلاغاتك السابقة',
                        color: const Color(0xFFBB86FC),
                        onTap: () => Navigator.pushNamed(
                            context, AppRoutes.citizenHistory),
                      ),
                    ]),
                  ),
                ),

                // ── Health tips ────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
                    child: GlassCard(
                      borderColor: NC.primary.withOpacity(0.3),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: NC.primary.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.lightbulb_outline,
                                color: NC.primary, size: 20),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              'زر بروفايلك وأضف بياناتك الطبية لتسريع استجابة الطوارئ',
                              style: NC.body(12, color: NC.textMid),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Quick service card ────────────────────────────────────────────
class _QuickCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sublabel;
  final Color color;
  final VoidCallback onTap;

  const _QuickCard({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: NC.cardGrad,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.25)),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const Spacer(),
            Text(label, style: NC.label(14)),
            const SizedBox(height: 2),
            Text(sublabel, style: NC.body(11)),
          ],
        ),
      ),
    );
  }
}

// ─── Grid background painter ───────────────────────────────────────
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1;
    const step = 24.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
