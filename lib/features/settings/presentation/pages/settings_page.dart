import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/route/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/shared/widgets/app_widgets.dart';
import '../../../../core/l10n/l10n_extension.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    final user = (authState is AuthAuthenticated) ? authState.user : null;
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        elevation: 0,
        centerTitle: true,
        title: Text(
          l10n.settings,
          style: AppTextStyles.headlineMedium.copyWith(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.lg),
            if (user != null) _buildProfileCard(context, user),
            const SizedBox(height: AppSpacing.xl),
            
            _buildSectionTitle(l10n.settingsPreferences),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _buildSettingsRow(
                    context,
                    title: l10n.language,
                    icon: Icons.language_rounded,
                    iconColor: AppColors.primaryBlue,
                    route: AppRoutes.settingsLanguage,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            _buildSectionTitle(l10n.settingsSupportInfo),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _buildSettingsRow(
                    context,
                    title: l10n.helpSupport,
                    icon: Icons.support_agent_rounded,
                    iconColor: Colors.amber,
                    route: AppRoutes.settingsHelp,
                  ),
                  _buildDivider(),
                  _buildSettingsRow(
                    context,
                    title: l10n.privacyPolicy,
                    icon: Icons.privacy_tip_outlined,
                    iconColor: Colors.green,
                    route: AppRoutes.settingsPrivacy,
                  ),
                  _buildDivider(),
                  _buildSettingsRow(
                    context,
                    title: l10n.termsOfService,
                    icon: Icons.description_outlined,
                    iconColor: Colors.blue,
                    route: AppRoutes.settingsTerms,
                  ),
                  _buildDivider(),
                  _buildSettingsRow(
                    context,
                    title: l10n.aboutUs,
                    icon: Icons.info_outline_rounded,
                    iconColor: AppColors.primaryBlue,
                    route: AppRoutes.settingsAbout,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            _buildSectionTitle(l10n.settingsShareFeedback),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _buildSettingsRow(
                    context,
                    title: l10n.rateApp,
                    icon: Icons.star_outline_rounded,
                    iconColor: Colors.orange,
                    route: AppRoutes.settingsRate,
                  ),
                  _buildDivider(),
                  _buildSettingsRow(
                    context,
                    title: l10n.shareApp,
                    icon: Icons.share_outlined,
                    iconColor: AppColors.primaryBlue,
                    route: AppRoutes.settingsShare,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            _buildSectionTitle(l10n.settingsAccount),
            AppCard(
              padding: EdgeInsets.zero,
              child: _buildSettingsRow(
                context,
                title: l10n.logoutAction,
                icon: Icons.logout_rounded,
                iconColor: AppColors.criticalRed,
                textColor: AppColors.criticalRed,
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(
                        context, AppRoutes.login, (route) => false);
                  }
                },
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, UserModel user) {
    final initials = user.firstName?.isNotEmpty == true
        ? user.firstName![0].toUpperCase()
        : user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : '?';

    return AppCard(
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
            child: Text(
              initials,
              style: const TextStyle(
                color: AppColors.primaryBlue,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName.isNotEmpty ? user.fullName : context.l10n.defaultUserName,
                  style: AppTextStyles.titleLarge,
                ),
                Text(
                  user.phoneNumber ?? '',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primaryBlue.withOpacity(0.2)),
            ),
            child: Text(
              user.role == AppConstants.roleAmbulances ? context.l10n.roleAmbulances : context.l10n.roleCitizen,
              style: AppTextStyles.labelMedium.copyWith(color: AppColors.primaryBlue, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(right: 4, bottom: 8),
      child: Text(
        title,
        style: AppTextStyles.labelLarge.copyWith(color: AppColors.textSecondary),
      ),
    );
  }

  Widget _buildSettingsRow(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color iconColor,
    String? route,
    VoidCallback? onTap,
    Color? textColor,
  }) {
    return ListTile(
      onTap: onTap ?? () => Navigator.pushNamed(context, route!),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyLarge.copyWith(color: textColor ?? AppColors.textPrimary),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: AppColors.textMuted,
        size: 20,
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      indent: 56,
      color: AppColors.border,
    );
  }
}


