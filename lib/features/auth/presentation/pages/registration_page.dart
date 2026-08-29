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
import '../widgets/registration_form_fields.dart';

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
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;

    if (widget.uid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(l10n.identityError),
        backgroundColor: AppColors.criticalRed,
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
    final l10n = AppLocalizations.of(context)!;
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          Navigator.pushNamedAndRemoveUntil(
              context, AppRoutes.citizenHome, (r) => false);
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.message),
            backgroundColor: AppColors.criticalRed,
            behavior: SnackBarBehavior.floating,
          ));
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.navy,
          automaticallyImplyLeading: false,
          title: Text(l10n.createAccountButton),
        ),
        body: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            final loading = state is AuthLoading;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Phone indicator
                    AppCard(
                      color: AppColors.primaryBlue.withOpacity(0.05),
                      border: BorderSide(color: AppColors.primaryBlue.withOpacity(0.1)),
                      child: Row(children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue.withOpacity(0.1),
                            borderRadius: AppRadius.radiusMd,
                          ),
                          child: const Icon(Icons.verified_outlined,
                              color: AppColors.primaryBlue, size: 20),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l10n.verifiedNumber,
                                style: AppTextStyles.bodySmall),
                            Text(widget.phoneNumber,
                                style: AppTextStyles.labelLarge.copyWith(color: AppColors.primaryBlue)),
                          ],
                        ),
                      ]),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    SectionHeader(title: l10n.personalInfo, icon: Icons.person_outline),
                    const SizedBox(height: AppSpacing.md),

                    RegistrationFormField(
                      label: l10n.fullNameLabel,
                      controller: _nameCtrl,
                      icon: Icons.badge_outlined,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? l10n.fieldRequired : null,
                    ),
                    const SizedBox(height: AppSpacing.md),

                    RegistrationFormField(
                      label: l10n.nationalIdLabel,
                      controller: _nationalIdCtrl,
                      icon: Icons.credit_card_outlined,
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? l10n.fieldRequired : null,
                    ),
                    const SizedBox(height: AppSpacing.md),

                    RegistrationFormField(
                      label: l10n.emergencyContactLabel,
                      controller: _emergencyCtrl,
                      icon: Icons.contact_phone_outlined,
                      hint: '+20 1XX XXXX XXXX',
                      keyboardType: TextInputType.phone,
                      optional: true,
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Password field
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Text(l10n.passwordLabel, style: AppTextStyles.labelLarge),
                          const SizedBox(width: AppSpacing.xs),
                          Text(l10n.optional, style: AppTextStyles.bodySmall),
                        ]),
                        const SizedBox(height: AppSpacing.sm),
                        TextFormField(
                          controller: _passwordCtrl,
                          obscureText: _obscure,
                          decoration: InputDecoration(
                            hintText: l10n.passwordHint,
                            prefixIcon: const Icon(Icons.lock_outline, size: 20),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscure
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                size: 18,
                              ),
                              onPressed: () =>
                                  setState(() => _obscure = !_obscure),
                            ),
                          ),
                          validator: (v) {
                            if (v != null && v.isNotEmpty && v.length < 6) {
                              return l10n.passwordLengthError;
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    SectionHeader(title: l10n.medicalInfo, icon: Icons.medical_information_outlined),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      l10n.medicalInfoSubtitle,
                      style: AppTextStyles.bodySmall,
                    ),
                    const SizedBox(height: AppSpacing.md),

                    RegistrationFormField(
                      label: l10n.chronicDiseasesLabel,
                      controller: _chronicCtrl,
                      icon: Icons.health_and_safety_outlined,
                      hint: l10n.chronicDiseasesHint,
                      optional: true,
                    ),
                    const SizedBox(height: AppSpacing.md),

                    RegistrationFormField(
                      label: l10n.allergiesLabel,
                      controller: _allergiesCtrl,
                      icon: Icons.warning_amber_outlined,
                      hint: l10n.allergiesHint,
                      optional: true,
                    ),
                    const SizedBox(height: AppSpacing.md),

                    RegistrationFormField(
                      label: l10n.medicationsLabel,
                      controller: _medsCtrl,
                      icon: Icons.medication_outlined,
                      hint: l10n.medicationsHint,
                      optional: true,
                    ),

                    const SizedBox(height: AppSpacing.xxl),

                    AppButton(
                      label: l10n.createAccountButton,
                      isLoading: loading,
                      onPressed: _submit,
                      icon: Icons.check_rounded,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
