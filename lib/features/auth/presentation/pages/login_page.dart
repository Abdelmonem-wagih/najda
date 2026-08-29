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
import '../widgets/ecg_icon.dart';
import '../widgets/role_selector.dart';
import '../widgets/citizen_login_form.dart';
import '../widgets/paramedic_login_form.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  int _roleIndex = 0; // 0=citizen, 1=paramedic
  late AnimationController _fadeCtrl;
  late Animation<double> _fade;

  // Citizen fields
  final _phoneCtrl = TextEditingController(text: '+20');

  // Paramedic fields
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 350));
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _switchRole(int idx) {
    if (idx == _roleIndex) return;
    _fadeCtrl.forward(from: 0);
    setState(() => _roleIndex = idx);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_roleIndex == 0) {
      context.read<AuthCubit>().sendOtp(_phoneCtrl.text.trim());
    } else {
      context.read<AuthCubit>().signInWithEmail(
            _emailCtrl.text.trim(),
            _passCtrl.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocListener<AuthCubit, AuthState>(
      listener: (ctx, state) {
        if (state is OtpSent) {
          Navigator.pushNamed(ctx, AppRoutes.otp,
              arguments: state.verificationId);
        } else if (state is AuthAuthenticated) {
          Navigator.pushNamedAndRemoveUntil(
            ctx,
            state.user.isCitizen
                ? AppRoutes.citizenHome
                : AppRoutes.paramedicHome,
            (r) => false,
          );
        } else if (state is AuthNeedsRegistration) {
          Navigator.pushReplacementNamed(ctx, AppRoutes.registration,
              arguments: {
                'uid': state.uid,
                'phoneNumber': state.phone
              });
        } else if (state is AuthError) {
          ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
            content: Text(state.message),
            backgroundColor: AppColors.criticalRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: AppRadius.radiusMd),
          ));
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppSpacing.xxl),

                  // ── Header ─────────────────────────────────
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: AppRadius.radiusXl,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryBlue.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Center(
                          child: EcgIcon(size: 40)),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    l10n.appName,
                    style: AppTextStyles.displaySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    l10n.appTagline,
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // ── Role Selector ─────────────────────────────
                  RoleSelector(
                    roleIndex: _roleIndex,
                    onRoleChanged: _switchRole,
                    citizenLabel: l10n.loginAsCitizen,
                    paramedicLabel: l10n.loginAsParamedic,
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // ── Fields ────────────────
                  FadeTransition(
                    opacity: _fade,
                    child: _roleIndex == 0
                        ? CitizenLoginForm(phoneController: _phoneCtrl)
                        : ParamedicLoginForm(
                            emailController: _emailCtrl,
                            passwordController: _passCtrl,
                            obscurePassword: _obscure,
                            onTogglePassword: () => setState(
                                () => _obscure = !_obscure),
                          ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // ── Submit ────────────────────────────────
                  BlocBuilder<AuthCubit, AuthState>(
                    builder: (ctx, state) {
                      final loading = state is AuthLoading;
                      return AppButton(
                        label: _roleIndex == 0
                            ? l10n.sendOtp
                            : l10n.login,
                        isLoading: loading,
                        onPressed: _submit,
                        icon: _roleIndex == 0
                            ? Icons.send_outlined
                            : Icons.login_outlined,
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // ── Footer Links ──────────
                  if (_roleIndex == 0) ...[
                    Text(
                      l10n.sendOtpPrompt,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodySmall,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(l10n.newUserPrompt, style: AppTextStyles.bodyMedium),
                        TextButton(
                          onPressed: () {
                            final phone = _phoneCtrl.text.trim();
                            if (phone.isEmpty ||
                                !phone.startsWith('+') ||
                                phone.length < 10) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(l10n.enterPhoneFirst),
                                  backgroundColor: AppColors.warning,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: AppRadius.radiusMd),
                                ),
                              );
                              return;
                            }
                            context.read<AuthCubit>().sendOtp(phone);
                          },
                          child: Text(l10n.createAccount),
                        ),
                      ],
                    ),
                  ] else ...[
                    AppCard(
                      color: AppColors.primaryBlue.withOpacity(0.05),
                      border: BorderSide(color: AppColors.primaryBlue.withOpacity(0.1)),
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline,
                              color: AppColors.primaryBlue, size: 20),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              l10n.paramedicInfo,
                              style: AppTextStyles.bodySmall.copyWith(color: AppColors.primaryBlue),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
