import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/route/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/shared/widgets/app_widgets.dart';
import '../cubit/auth_cubit.dart';

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
                          child: _EcgIcon(size: 40)),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'نجدة',
                    style: AppTextStyles.displaySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'استجابة الطوارئ الفورية',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // ── Role Selector ─────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: AppRadius.radiusLg,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        _RoleTab(
                          icon: Icons.person_outline,
                          label: 'مواطن',
                          selected: _roleIndex == 0,
                          onTap: () => _switchRole(0),
                        ),
                        _RoleTab(
                          icon: Icons.medical_services_outlined,
                          label: 'مسعف',
                          selected: _roleIndex == 1,
                          onTap: () => _switchRole(1),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // ── Fields ────────────────
                  FadeTransition(
                    opacity: _fade,
                    child: _roleIndex == 0
                        ? _CitizenFields(ctrl: _phoneCtrl)
                        : _ParamedicFields(
                            emailCtrl: _emailCtrl,
                            passCtrl: _passCtrl,
                            obscure: _obscure,
                            onToggle: () => setState(
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
                            ? 'إرسال رمز التحقق'
                            : 'تسجيل الدخول',
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
                      'لتسجيل حساب جديد: أدخل رقمك واضغط "إرسال رمز التحقق"',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodySmall,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('ليس لديك حساب؟', style: AppTextStyles.bodyMedium),
                        TextButton(
                          onPressed: () {
                            final phone = _phoneCtrl.text.trim();
                            if (phone.isEmpty ||
                                !phone.startsWith('+') ||
                                phone.length < 10) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                    'أدخل رقم هاتفك أولاً ثم اضغط "إرسال رمز التحقق"',
                                  ),
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
                          child: const Text('إنشاء حساب'),
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
                              'حسابات المسعفين يُنشئها مشرف النظام فقط',
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

class _CitizenFields extends StatelessWidget {
  final TextEditingController ctrl;
  const _CitizenFields({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('رقم الهاتف', style: AppTextStyles.labelLarge),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: ctrl,
          keyboardType: TextInputType.phone,
          textDirection: TextDirection.ltr,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[+\d]'))
          ],
          decoration: const InputDecoration(
            hintText: '+20 1XX XXXX XXXX',
            prefixIcon: Icon(Icons.phone_outlined, size: 20),
          ),
          validator: (v) {
            if (v == null || v.isEmpty) return 'مطلوب';
            if (!v.startsWith('+')) return 'يجب أن يبدأ بـ +';
            if (v.replaceAll(RegExp(r'\D'), '').length < 10)
              return 'رقم قصير جداً';
            return null;
          },
        ),
      ],
    );
  }
}

class _ParamedicFields extends StatelessWidget {
  final TextEditingController emailCtrl;
  final TextEditingController passCtrl;
  final bool obscure;
  final VoidCallback onToggle;

  const _ParamedicFields({
    required this.emailCtrl,
    required this.passCtrl,
    required this.obscure,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('البريد الإلكتروني', style: AppTextStyles.labelLarge),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: emailCtrl,
          keyboardType: TextInputType.emailAddress,
          textDirection: TextDirection.ltr,
          decoration: const InputDecoration(
            hintText: 'paramedic@najda.eg',
            prefixIcon: Icon(Icons.email_outlined, size: 20),
          ),
          validator: (v) {
            if (v == null || v.isEmpty) return 'مطلوب';
            if (!v.contains('@')) return 'بريد غير صحيح';
            return null;
          },
        ),
        const SizedBox(height: AppSpacing.md),
        Text('كلمة المرور', style: AppTextStyles.labelLarge),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: passCtrl,
          obscureText: obscure,
          decoration: InputDecoration(
            hintText: '••••••••',
            prefixIcon: const Icon(Icons.lock_outline, size: 20),
            suffixIcon: IconButton(
              icon: Icon(
                obscure
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 20,
              ),
              onPressed: onToggle,
            ),
          ),
          validator: (v) {
            if (v == null || v.isEmpty) return 'مطلوب';
            if (v.length < 6) return 'كلمة المرور قصيرة';
            return null;
          },
        ),
      ],
    );
  }
}

class _RoleTab extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _RoleTab({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? AppColors.primaryBlue : Colors.transparent,
            borderRadius: AppRadius.radiusMd,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: selected ? AppColors.white : AppColors.textSecondary,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                label,
                style: AppTextStyles.labelLarge.copyWith(
                  color: selected ? AppColors.white : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EcgIcon extends StatelessWidget {
  final double size;
  const _EcgIcon({required this.size});

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size(size, size), painter: _EcgPainter());
}

class _EcgPainter extends CustomPainter {
  @override
  void paint(Canvas c, Size s) {
    final p = Paint()
      ..color = AppColors.white
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    final mid = s.height * 0.5;
    final path = Path()
      ..moveTo(0, mid)
      ..lineTo(s.width * 0.2, mid)
      ..lineTo(s.width * 0.3, mid * 0.25)
      ..lineTo(s.width * 0.4, mid * 1.8)
      ..lineTo(s.width * 0.5, mid * 0.05)
      ..lineTo(s.width * 0.6, mid)
      ..lineTo(s.width, mid);
    c.drawPath(path, p);
  }

  @override
  bool shouldRepaint(_) => false;
}
