import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/route/app_routes.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/shared/widgets/app_widgets.dart';
import '../../../../../core/l10n/l10n_extension.dart';
import '../../../../auth/presentation/cubit/auth_cubit.dart';
import '../widgets/profile_header.dart';

class CitizenProfilePage extends StatelessWidget {
  const CitizenProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = context.watch<AuthCubit>().state;
    if (state is! AuthAuthenticated) {
      return const Scaffold(body: AppLoader());
    }
    final user = state.user;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Column(
              children: [
                ProfileHeader(user: user),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildActionButtons(context),
                      const SizedBox(height: AppSpacing.lg),

                      _buildSectionTitle(l10n.personalData, Icons.person_outline),
                      AppCard(
                        padding: EdgeInsets.zero,
                        child: Column(
                          children: [
                            _buildInfoTile(l10n.fullNameLabel, user.fullName, Icons.badge_outlined),
                            _buildDivider(),
                            _buildInfoTile(l10n.phoneNumber, user.phone ?? l10n.noInfo, Icons.phone_android_rounded),
                            _buildDivider(),
                            _buildInfoTile(l10n.identityNumber, user.nationalId ?? l10n.noInfo, Icons.assignment_ind_outlined),
                            _buildDivider(),
                            _buildInfoTile(l10n.emergencyContactPerson, user.emergencyContact, Icons.contact_emergency_outlined),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      _buildSectionTitle(l10n.medicalData, Icons.medical_information_outlined),
                      AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildMedicalField(context, l10n.chronicDiseasesLabel, user.chronicDiseases, Colors.orange),
                            const SizedBox(height: AppSpacing.md),
                            _buildMedicalField(context, l10n.allergiesLabel, user.allergies, Colors.redAccent),
                            const SizedBox(height: AppSpacing.md),
                            _buildMedicalField(context, l10n.medicationsLabel, user.currentMedications, Colors.blueAccent),
                            if (user.additionalInfo?.isNotEmpty == true) ...[
                              const Divider(height: 32),
                              Text(l10n.additionalNotes, style: AppTextStyles.labelMedium),
                              const SizedBox(height: 4),
                              Text(user.additionalInfo!, style: AppTextStyles.bodyMedium),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxl),

                      AppButton(
                        label: l10n.logoutAction,
                        isPrimary: false,
                        onPressed: () => _confirmLogout(context),
                        icon: Icons.logout_rounded,
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 0,
      floating: true,
      pinned: true,
      backgroundColor: AppColors.navy,
      title: Text(context.l10n.profile, style: const TextStyle(color: Colors.white)),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.settings_outlined, color: Colors.white),
          onPressed: () => Navigator.pushNamed(context, AppRoutes.settings),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AppButton(
            label: context.l10n.editProfile,
            onPressed: () => Navigator.pushNamed(context, AppRoutes.editProfile),
            icon: Icons.edit_outlined,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm, right: AppSpacing.xs),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primaryBlue),
          const SizedBox(width: AppSpacing.xs),
          Text(title, style: AppTextStyles.titleMedium.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildInfoTile(String label, String value, IconData icon) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primaryBlue.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.primaryBlue, size: 20),
      ),
      title: Text(label, style: AppTextStyles.bodySmall),
      subtitle: Text(value, style: AppTextStyles.labelLarge),
    );
  }

  Widget _buildMedicalField(BuildContext context, String label, List<String> items, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelMedium),
        const SizedBox(height: AppSpacing.xs),
        if (items.isEmpty)
          Text(context.l10n.noInfo, style: AppTextStyles.bodySmall.copyWith(fontStyle: FontStyle.italic))
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items.map((item) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Text(
                item,
                style: AppTextStyles.bodySmall.copyWith(color: color, fontWeight: FontWeight.bold),
              ),
            )).toList(),
          ),
      ],
    );
  }


  Widget _buildDivider() => const Divider(height: 1, indent: 70, color: AppColors.border);

  void _confirmLogout(BuildContext context) {
    final l10n = context.l10n;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusXl),
        title: Text(l10n.logoutAction),
        content: Text(l10n.logoutConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.criticalRed,
              minimumSize: const Size(100, 45),
            ),
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthCubit>().signOut();
              Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (r) => false);
            },
            child: Text(l10n.logoutAction, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

