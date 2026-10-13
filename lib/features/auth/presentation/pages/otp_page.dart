import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/route/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/shared/widgets/app_widgets.dart';
import '../../../../core/l10n/generated/app_localizations.dart';
import '../cubit/auth_cubit.dart';
import '../widgets/otp_input_field.dart';

class OtpPage extends StatefulWidget {
  final String verificationId;
  const OtpPage({super.key, required this.verificationId});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final List<TextEditingController> _ctrls =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _nodes = List.generate(6, (_) => FocusNode());

  int _secondsLeft = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _nodes[0].requestFocus();
    });
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsLeft = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_secondsLeft == 0) {
        _timer?.cancel();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  @override
  void dispose() {
    for (final c in _ctrls) c.dispose();
    for (final n in _nodes) n.dispose();
    _timer?.cancel();
    super.dispose();
  }

  String get _otp => _ctrls.map((c) => c.text).join();

  void _verify() {
    if (_otp.length < 6) return;
    context.read<AuthCubit>().verifyOtp(_otp, widget.verificationId);
  }

  void _onChanged(String val, int index) {
    if (val.isNotEmpty && index < 5) {
      _nodes[index + 1].requestFocus();
    } else if (val.isEmpty && index > 0) {
      _nodes[index - 1].requestFocus();
    }
    if (_otp.length == 6) _verify();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final phone = (context.watch<AuthCubit>().state is OtpSent)
        ? (context.watch<AuthCubit>().state as OtpSent).phoneNumber
        : '';

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            state.user.isCitizen
                ? AppRoutes.citizenHome
                : AppRoutes.ambulanceHome,
            (r) => false,
          );
        } else if (state is AuthNeedsRegistration) {
          Navigator.pushReplacementNamed(context, AppRoutes.registration,
              arguments: {'uid': state.uid, 'phoneNumber': state.phone});
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.criticalRed,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusMd),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.navy,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(l10n.otpTitle),
        ),
        body: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            final isLoading = state is AuthLoading;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: AppSpacing.xl),
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withOpacity(0.1),
                      borderRadius: AppRadius.radiusXl,
                    ),
                    child: const Icon(Icons.sms_outlined,
                        color: AppColors.primaryBlue, size: 36),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    l10n.otpCode,
                    style: AppTextStyles.displaySmall,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    phone.isNotEmpty ? l10n.otpSubtitle(phone) : '',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // OTP inputs
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      6,
                      (i) => OtpInputField(
                        controller: _ctrls[i],
                        focusNode: _nodes[i],
                        onChanged: (v) => _onChanged(v, i),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // Verify button
                  AppButton(
                    label: l10n.verifyOtp,
                    onPressed: isLoading ? null : _verify,
                    isLoading: isLoading,
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Resend
                  if (_secondsLeft > 0)
                    Text(
                      l10n.resendAfter(_secondsLeft),
                      style: AppTextStyles.bodySmall,
                    )
                  else
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(l10n.resendOtp),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
