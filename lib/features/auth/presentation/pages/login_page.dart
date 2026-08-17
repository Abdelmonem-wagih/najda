import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/route/app_routes.dart';
import '../../../../core/theme/design.dart';
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
            content: Text(state.message,
                style: NC.body(13, color: Colors.white)),
            backgroundColor: NC.critical,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ));
        }
      },
      child: Scaffold(
        backgroundColor: NC.base,
        body: Stack(
          children: [
            // Background glows
            Positioned(
              top: -100,
              right: -80,
              child: _Glow(color: NC.primary, size: 300),
            ),
            Positioned(
              bottom: -80,
              left: -60,
              child: _Glow(color: NC.critical, size: 220),
            ),

            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 48),

                      // ── Logo ─────────────────────────────────
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: NC.primaryGrad,
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: NC.primary.withOpacity(0.4),
                              blurRadius: 28,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Center(
                            child: _EcgIcon(size: 44)),
                      ),
                      const SizedBox(height: 20),
                      Text('نجدة',
                          style: NC.display(36,
                              color: NC.textHigh)),
                      const SizedBox(height: 6),
                      Text('استجابة الطوارئ الفورية',
                          style: NC.body(14)),
                      const SizedBox(height: 40),

                      // ── Role Tabs ─────────────────────────────
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: NC.card,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: NC.cardBorder),
                        ),
                        child: Row(
                          children: [
                            _RoleTab(
                              icon: Icons.person_outline_rounded,
                              label: 'مواطن',
                              selected: _roleIndex == 0,
                              selectedColor: NC.primary,
                              onTap: () => _switchRole(0),
                            ),
                            _RoleTab(
                              icon:
                                  Icons.local_hospital_outlined,
                              label: 'مسعف',
                              selected: _roleIndex == 1,
                              selectedColor: NC.critical,
                              onTap: () => _switchRole(1),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // ── Form fields (animated) ────────────────
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
                      const SizedBox(height: 28),

                      // ── Submit ────────────────────────────────
                      BlocBuilder<AuthCubit, AuthState>(
                        builder: (ctx, state) {
                          final loading = state is AuthLoading;
                          return GradientButton(
                            label: _roleIndex == 0
                                ? 'إرسال رمز التحقق'
                                : 'تسجيل الدخول',
                            gradient: _roleIndex == 0
                                ? NC.primaryGrad
                                : NC.criticalGrad,
                            icon: _roleIndex == 0
                                ? Icons.send_outlined
                                : Icons.login_outlined,
                            loading: loading,
                            onTap: _submit,
                          );
                        },
                      ),
                      const SizedBox(height: 20),

                      // ── Register link (citizen only) ──────────
                      if (_roleIndex == 0) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            'لتسجيل حساب جديد: أدخل رقمك واضغط "إرسال رمز التحقق"',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: NC.font,
                              fontSize: 11,
                              color: NC.textLow,
                              height: 1.5,
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('ليس لديك حساب؟', style: NC.body(13)),
                            TextButton(
                              onPressed: () {
                                // Registration requires OTP first to get real uid.
                                // We send OTP → after verification → AuthNeedsRegistration → RegistrationPage.
                                final phone = _phoneCtrl.text.trim();
                                if (phone.isEmpty ||
                                    !phone.startsWith('+') ||
                                    phone.length < 10) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'أدخل رقم هاتفك أولاً ثم اضغط "إرسال رمز التحقق"',
                                        style: TextStyle(
                                            fontFamily: NC.font,
                                            color: Colors.white),
                                      ),
                                      backgroundColor: NC.warning,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                    ),
                                  );
                                  return;
                                }
                                // Send OTP — after verify, if user has no profile → RegistrationPage
                                context.read<AuthCubit>().sendOtp(phone);
                              },
                              child: Text(
                                'إنشاء حساب',
                                style: NC.label(13, color: NC.primary),
                              ),
                            ),
                          ],
                        ),
                      ],

                      // ── Paramedic note ────────────────────────
                      if (_roleIndex == 1) ...[
                        const SizedBox(height: 8),
                        GlassCard(
                          borderColor: NC.critical.withOpacity(0.3),
                          child: Row(children: [
                            const Icon(Icons.info_outline,
                                color: NC.critical, size: 16),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'حسابات المسعفين يُنشئها مشرف النظام فقط',
                                style: NC.body(12,
                                    color: NC.textMid),
                              ),
                            ),
                          ]),
                        ),
                      ],
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Citizen phone field ──────────────────────────────────────────
class _CitizenFields extends StatelessWidget {
  final TextEditingController ctrl;
  const _CitizenFields({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('رقم الهاتف', style: NC.label(13, color: NC.textMid)),
        const SizedBox(height: 8),
        TextFormField(
          controller: ctrl,
          keyboardType: TextInputType.phone,
          textDirection: TextDirection.ltr,
          style: NC.inputText(),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[+\d]'))
          ],
          decoration: const InputDecoration(
            hintText: '+20 1XX XXXX XXXX',
            prefixIcon: Icon(Icons.phone_outlined,
                color: NC.primary, size: 20),
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

// ─── Paramedic email+password fields ─────────────────────────────
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
        Text('البريد الإلكتروني',
            style: NC.label(13, color: NC.textMid)),
        const SizedBox(height: 8),
        TextFormField(
          controller: emailCtrl,
          keyboardType: TextInputType.emailAddress,
          textDirection: TextDirection.ltr,
          style: NC.inputText(),
          decoration: const InputDecoration(
            hintText: 'paramedic@najda.eg',
            prefixIcon: Icon(Icons.email_outlined,
                color: NC.primary, size: 20),
          ),
          validator: (v) {
            if (v == null || v.isEmpty) return 'مطلوب';
            if (!v.contains('@')) return 'بريد غير صحيح';
            return null;
          },
        ),
        const SizedBox(height: 16),
        Text('كلمة المرور',
            style: NC.label(13, color: NC.textMid)),
        const SizedBox(height: 8),
        TextFormField(
          controller: passCtrl,
          obscureText: obscure,
          style: NC.inputText(),
          decoration: InputDecoration(
            hintText: '••••••••',
            prefixIcon: const Icon(Icons.lock_outline,
                color: NC.primary, size: 20),
            suffixIcon: IconButton(
              icon: Icon(
                obscure
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: NC.textLow,
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

// ─── Role tab ─────────────────────────────────────────────────────
class _RoleTab extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final Color selectedColor;
  final VoidCallback onTap;

  const _RoleTab({
    required this.icon,
    required this.label,
    required this.selected,
    required this.selectedColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? selectedColor.withOpacity(0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: selected
                ? Border.all(color: selectedColor.withOpacity(0.5))
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  color: selected ? selectedColor : NC.textLow,
                  size: 18),
              const SizedBox(width: 7),
              Text(
                label,
                style: NC.label(14,
                    color: selected ? selectedColor : NC.textLow,
                    weight: selected
                        ? FontWeight.w700
                        : FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Background glow ──────────────────────────────────────────────
class _Glow extends StatelessWidget {
  final Color color;
  final double size;
  const _Glow({required this.color, required this.size});

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color.withOpacity(0.14), Colors.transparent],
          ),
        ),
      );
}

// ─── ECG icon ─────────────────────────────────────────────────────
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
      ..color = NC.base
      ..strokeWidth = 2.5
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
