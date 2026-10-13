import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/design.dart';
import '../../../core/route/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/shared/widgets/app_widgets.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/utils/phone_utils.dart';
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

    // 1. WhatsApp & Call — fires only AFTER the report write already
    // succeeded (we're reacting to SOSSuccess), and is never awaited by the
    // confirmation dialog below, so a blocked/failed call or message can
    // never delay or hide the fact that the report itself went through.
    final contactRaw = user.emergencyContact;
    if (contactRaw.isNotEmpty) {
      unawaited(_sendWhatsAppAndCall(
        phone: contactRaw,
        patientName: user.fullName,
        shortId: state.shortId,
        lat: state.latitude,
        lng: state.longitude,
        address: state.address,
      ));
    }

    // 2. Show confirmation
    if (mounted) {
      _showSOSConfirm(
        shortId: state.shortId,
        docId: state.reportId,
        lat: state.latitude,
        lng: state.longitude,
      );
    }
  }

  Future<void> _sendWhatsAppAndCall({
    required String phone,
    required String patientName,
    required String shortId,
    double? lat,
    double? lng,
    required String address,
  }) async {
    final cleanPhone = normalizeEgyptianPhone(phone);
    if (cleanPhone == null) {
      debugPrint('[SOS] emergency contact "$phone" is not a valid Egyptian number — skipping WhatsApp/call');
      _showNonBlockingNotice('تعذر الوصول لجهة اتصال الطوارئ — الرقم المسجل غير صحيح');
      return;
    }

    final mapsLink = (lat != null && lng != null)
        ? 'https://maps.google.com/?q=$lat,$lng'
        : null;
    final msg = Uri.encodeComponent(
      '🚨 *تنبيه طوارئ — نجدة*\n\n'
      '$patientName يحتاج مساعدة طارئة!\n\n'
      '📍 *الموقع:* ${address.isNotEmpty ? address : 'غير محدد'}\n'
      '${mapsLink != null ? '🗺️ *خريطة:* $mapsLink\n' : ''}'
      '🆔 *رقم البلاغ:* $shortId\n'
      '🕐 *الوقت:* ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}\n\n'
      '✅ تم إرسال الإسعاف تلقائياً.',
    );

    // Send WhatsApp
    final waUri =
        Uri.parse('https://wa.me/${cleanPhone.replaceAll('+', '')}?text=$msg');
    bool whatsAppSent = false;
    try {
      if (await canLaunchUrl(waUri)) {
        whatsAppSent = await launchUrl(waUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('[SOS] WhatsApp launch failed: $e');
    }
    if (!whatsAppSent) {
      debugPrint('[SOS] WhatsApp not available for $cleanPhone');
    }

    // Wait 3 seconds then call
    await Future.delayed(const Duration(seconds: 3));
    await _callEmergencyContact(cleanPhone);
  }

  /// Android: places the call directly (no dialer confirmation step) via
  /// flutter_phone_direct_caller, after requesting the runtime CALL_PHONE
  /// permission (declared in the manifest but previously never actually
  /// requested or used anywhere in the app). Falls back to opening the
  /// dialer (url_launcher tel:) if the permission is denied, or on iOS,
  /// where no app is allowed to silently place a call — the user still has
  /// to tap Call themselves there.
  Future<void> _callEmergencyContact(String e164Phone) async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final status = await Permission.phone.request();
      if (status.isGranted) {
        try {
          final placed = await FlutterPhoneDirectCaller.callNumber(e164Phone);
          if (placed == true) return;
        } catch (e) {
          debugPrint('[SOS] Direct call failed: $e');
        }
      }
    }

    // iOS, or Android permission denied, or the direct call failed.
    try {
      final callUri = Uri.parse('tel:$e164Phone');
      if (await canLaunchUrl(callUri)) {
        await launchUrl(callUri, mode: LaunchMode.externalApplication);
        return;
      }
    } catch (e) {
      debugPrint('[SOS] Dialer launch failed: $e');
    }

    _showNonBlockingNotice('تعذر الاتصال بجهة اتصال الطوارئ تلقائياً — يرجى الاتصال بهم يدوياً');
  }

  void _showNonBlockingNotice(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: NC.label(13, color: Colors.white)),
      backgroundColor: NC.warning,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  void _showSOSConfirm({
    required String shortId,
    required String docId,
    double? lat,
    double? lng,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: NC.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                  gradient: NC.successGrad, shape: BoxShape.circle),
              child:
                  const Icon(Icons.check_rounded, color: Colors.white, size: 38),
            ),
            const SizedBox(height: 20),
            Text('تم إرسال بلاغ الطوارئ!',
                style: NC.display(18), textAlign: TextAlign.center),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: NC.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: NC.primary.withOpacity(0.3)),
              ),
              child: Text(shortId,
                  style:
                      NC.label(16, color: NC.primary, weight: FontWeight.w800)),
            ),
            const SizedBox(height: 10),
            Text(
              lat != null && lng != null
                  ? 'الإسعاف في الطريق إليك.\nتم إرسال رسالة واتساب لجهة اتصال الطوارئ.'
                  : 'تم استلام بلاغك ولكن تعذر تحديد موقعك بدقة.\nسيتواصل معك فريق الطوارئ، وتم إرسال رسالة واتساب لجهة اتصال الطوارئ.',
              style: NC.body(13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (lat != null && lng != null)
              GradientButton(
                label: 'تتبع الإسعاف على الخريطة',
                icon: Icons.my_location_rounded,
                gradient: NC.primaryGrad,
                height: 50,
                onTap: () {
                  Navigator.pop(context); // close dialog
                  Navigator.pushNamed(
                    context,
                    AppRoutes.trackIncident,
                    arguments: {
                      'reportId': docId,
                      'reportType': 'critical',
                      'displayId': shortId,
                      'patientLat': lat,
                      'patientLng': lng,
                    },
                  );
                },
              ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('حسناً', style: NC.label(14, color: NC.textMid)),
            ),
          ]),
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
    // user.fullName is a non-nullable getter (always resolves to at least
    // ''), so the previous `?? ''` here was dead code, not a real bug.
    final name = user.fullName;

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
