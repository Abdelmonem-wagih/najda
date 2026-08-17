import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/route/app_routes.dart';
import '../../../../core/theme/design.dart';
import '../cubit/auth_cubit.dart';

class RegistrationPage extends StatefulWidget {
  final String uid;
  final String phoneNumber;

  const RegistrationPage({
    super.key,
    required this.uid,
    required this.phoneNumber,
  });

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _nationalIdCtrl = TextEditingController();
  final _emergencyCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _chronicCtrl = TextEditingController();
  final _allergiesCtrl = TextEditingController();
  final _medsCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    for (final c in [
      _nameCtrl, _nationalIdCtrl, _emergencyCtrl,
      _passwordCtrl, _chronicCtrl, _allergiesCtrl, _medsCtrl,
    ]) { c.dispose(); }
    super.dispose();
  }

  List<String> _split(String t) =>
      t.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    // Guard: uid must not be empty (should never happen after OTP fix)
    if (widget.uid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('خطأ في التحقق من الهوية. أعد المحاولة.',
            style: TextStyle(fontFamily: NC.font, color: Colors.white)),
        backgroundColor: NC.critical,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }

    context.read<AuthCubit>().completeRegistration(
      uid: widget.uid,
      phone: widget.phoneNumber,
      fullName: _nameCtrl.text.trim(),
      nationalId: _nationalIdCtrl.text.trim(),
      password: _passwordCtrl.text.trim().isEmpty ? null : _passwordCtrl.text.trim(),
      emergencyContact: _emergencyCtrl.text.trim().isEmpty ? null : _emergencyCtrl.text.trim(),
      chronicDiseases: _split(_chronicCtrl.text),
      allergies: _split(_allergiesCtrl.text),
      currentMedications: _split(_medsCtrl.text),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          Navigator.pushNamedAndRemoveUntil(
              context, AppRoutes.citizenHome, (r) => false);
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.message,
                style: TextStyle(fontFamily: NC.font, color: Colors.white)),
            backgroundColor: NC.critical,
            behavior: SnackBarBehavior.floating,
          ));
        }
      },
      child: Scaffold(
        backgroundColor: NC.base,
        appBar: AppBar(
          backgroundColor: NC.surface,
          automaticallyImplyLeading: false,
          title: Text('إنشاء حسابك', style: NC.display(16)),
        ),
        body: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            final loading = state is AuthLoading;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Phone indicator (read-only)
                    GlassCard(
                      child: Row(children: [
                        Container(
                          padding: const EdgeInsets.all(9),
                          decoration: BoxDecoration(
                            color: NC.primary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.verified_outlined,
                              color: NC.primary, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('رقم تم التحقق منه',
                                style: NC.body(11, color: NC.textMid)),
                            Text(widget.phoneNumber,
                                style: NC.label(14, color: NC.primary)),
                          ],
                        ),
                      ]),
                    ),
                    const SizedBox(height: 24),

                    _Section('البيانات الشخصية', Icons.person_outline_rounded),
                    const SizedBox(height: 12),

                    _Field('الاسم الكامل *', _nameCtrl,
                        icon: Icons.badge_outlined,
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'مطلوب' : null),
                    const SizedBox(height: 14),

                    _Field('الرقم القومي *', _nationalIdCtrl,
                        icon: Icons.credit_card_outlined,
                        keyboardType: TextInputType.number,
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'مطلوب' : null),
                    const SizedBox(height: 14),

                    _Field('رقم جهة الاتصال الطارئة', _emergencyCtrl,
                        icon: Icons.contact_phone_outlined,
                        hint: '+20 1XX XXXX XXXX',
                        keyboardType: TextInputType.phone,
                        optional: true),
                    const SizedBox(height: 14),

                    // Password field
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Text('كلمة مرور للحساب',
                              style: NC.label(13, color: NC.textMid)),
                          const SizedBox(width: 6),
                          Text('(اختياري)',
                              style: NC.body(11, color: NC.textLow)),
                        ]),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _passwordCtrl,
                          obscureText: _obscure,
                          style: NC.inputText(),
                          decoration: InputDecoration(
                            hintText: 'أدخل كلمة مرور لحماية حسابك',
                            prefixIcon: const Icon(Icons.lock_outline,
                                color: NC.primary, size: 20),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscure
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: NC.textLow, size: 18,
                              ),
                              onPressed: () =>
                                  setState(() => _obscure = !_obscure),
                            ),
                          ),
                          validator: (v) {
                            if (v != null && v.isNotEmpty && v.length < 6) {
                              return 'كلمة المرور 6 أحرف على الأقل';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    _Section('البيانات الطبية', Icons.medical_information_outlined),
                    const SizedBox(height: 4),
                    Text(
                      'تُرسل لطاقم الإسعاف عند البلاغات',
                      style: NC.body(12, color: NC.textLow),
                    ),
                    const SizedBox(height: 12),

                    _Field('أمراض مزمنة', _chronicCtrl,
                        icon: Icons.health_and_safety_outlined,
                        hint: 'سكري، ضغط، قلب... (افصل بفاصلة)',
                        optional: true),
                    const SizedBox(height: 14),

                    _Field('حساسية من أدوية أو مواد', _allergiesCtrl,
                        icon: Icons.warning_amber_outlined,
                        hint: 'بنسيلين، فول سوداني...',
                        optional: true),
                    const SizedBox(height: 14),

                    _Field('أدوية حالية', _medsCtrl,
                        icon: Icons.medication_outlined,
                        hint: 'ميتفورمين، أسبرين...',
                        optional: true),

                    const SizedBox(height: 32),

                    GradientButton(
                      label: 'إنشاء الحساب',
                      gradient: NC.primaryGrad,
                      icon: Icons.check_rounded,
                      loading: loading,
                      onTap: _submit,
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _Section(String label, IconData icon) {
    return Row(children: [
      Icon(icon, color: NC.primary, size: 18),
      const SizedBox(width: 8),
      Text(label, style: NC.display(14)),
      const SizedBox(width: 12),
      const Expanded(child: Divider(color: Color(0xFF1E3A52))),
    ]);
  }

  Widget _Field(
    String label,
    TextEditingController ctrl, {
    IconData? icon,
    String? hint,
    TextInputType? keyboardType,
    bool optional = false,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Text(label, style: NC.label(13, color: NC.textMid)),
          if (optional) ...[
            const SizedBox(width: 6),
            Text('(اختياري)', style: NC.body(11, color: NC.textLow)),
          ],
        ]),
        const SizedBox(height: 8),
        TextFormField(
          controller: ctrl,
          keyboardType: keyboardType,
          style: NC.inputText(),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: icon != null
                ? Icon(icon, color: NC.primary, size: 20)
                : null,
          ),
          validator: validator,
        ),
      ],
    );
  }
}
