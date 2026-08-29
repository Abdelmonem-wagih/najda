import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/shared/widgets/app_widgets.dart';
import '../../../../../core/l10n/l10n_extension.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../auth/presentation/cubit/auth_cubit.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _emergencyCtrl;
  late TextEditingController _chronicCtrl;
  late TextEditingController _allergiesCtrl;
  late TextEditingController _medsCtrl;
  late TextEditingController _infoCtrl;

  @override
  void initState() {
    super.initState();
    final user = (context.read<AuthCubit>().state as AuthAuthenticated).user;
    _nameCtrl = TextEditingController(text: user.fullName);
    _emergencyCtrl = TextEditingController(text: user.emergencyContact);
    _chronicCtrl = TextEditingController(text: user.chronicDiseases.join(', '));
    _allergiesCtrl = TextEditingController(text: user.allergies.join(', '));
    _medsCtrl = TextEditingController(text: user.currentMedications.join(', '));
    _infoCtrl = TextEditingController(text: user.additionalInfo);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emergencyCtrl.dispose();
    _chronicCtrl.dispose();
    _allergiesCtrl.dispose();
    _medsCtrl.dispose();
    _infoCtrl.dispose();
    super.dispose();
  }

  List<String> _split(String t) =>
      t.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final user = (context.read<AuthCubit>().state as AuthAuthenticated).user;

    context.read<AuthCubit>().updateProfile(
          uid: user.id,
          fullName: _nameCtrl.text.trim(),
          emergencyContact: _emergencyCtrl.text.trim(),
          chronicDiseases: _split(_chronicCtrl.text),
          allergies: _split(_allergiesCtrl.text),
          currentMedications: _split(_medsCtrl.text),
          additionalInfo: _infoCtrl.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.profileUpdated),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pop(context);
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.profileUpdateError),
              backgroundColor: AppColors.criticalRed,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.navy,
          elevation: 0,
          centerTitle: true,
          title: Text(l10n.editProfile, style: const TextStyle(color: Colors.white)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            final isLoading = state is AuthLoading;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildSectionHeader(l10n.personalData, Icons.person_outline),
                    const SizedBox(height: AppSpacing.md),
                    AppCard(
                      child: Column(
                        children: [
                          _buildField(l10n.fullNameLabel, _nameCtrl, icon: Icons.badge_outlined),
                          const SizedBox(height: AppSpacing.md),
                          _buildField(l10n.emergencyContactLabel, _emergencyCtrl,
                              icon: Icons.contact_phone_outlined, keyboardType: TextInputType.phone),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: AppSpacing.xl),
                    _buildSectionHeader(l10n.medicalData, Icons.medical_information_outlined),
                    const SizedBox(height: AppSpacing.md),
                    AppCard(
                      child: Column(
                        children: [
                          _buildField(l10n.chronicDiseasesLabel, _chronicCtrl,
                              icon: Icons.health_and_safety_outlined, hint: l10n.chronicDiseasesHint),
                          const SizedBox(height: AppSpacing.md),
                          _buildField(l10n.allergiesLabel, _allergiesCtrl,
                              icon: Icons.warning_amber_outlined, hint: l10n.allergiesHint),
                          const SizedBox(height: AppSpacing.md),
                          _buildField(l10n.medicationsLabel, _medsCtrl,
                              icon: Icons.medication_outlined, hint: l10n.medicationsHint),
                          const SizedBox(height: AppSpacing.md),
                          _buildField(l10n.additionalNotes, _infoCtrl,
                              icon: Icons.info_outline, hint: l10n.additionalNotesHint),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xxl),
                    AppButton(
                      label: l10n.saveChanges,
                      isLoading: isLoading,
                      onPressed: _submit,
                      icon: Icons.check_rounded,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppButton(
                      label: l10n.cancel,
                      isPrimary: false,
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(right: 4, bottom: 8),
      child: Row(children: [
        Icon(icon, color: AppColors.primaryBlue, size: 18),
        const SizedBox(width: AppSpacing.sm),
        Text(title, style: AppTextStyles.titleMedium.copyWith(color: AppColors.textSecondary)),
      ]),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl,
      {IconData? icon, String? hint, TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelLarge),
        const SizedBox(height: AppSpacing.xs),
        TextFormField(
          controller: ctrl,
          keyboardType: keyboardType,
          style: AppTextStyles.bodyLarge,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: icon != null ? Icon(icon, size: 20, color: AppColors.primaryBlue) : null,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          validator: (v) => (v == null || v.trim().isEmpty) && label.contains('*') ? context.l10n.fieldRequired : null,
        ),
      ],
    );
  }
}

