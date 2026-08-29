import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/shared/widgets/app_widgets.dart';
import '../../../../core/l10n/l10n_extension.dart';
import '../widgets/settings_scaffold.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return SettingsScaffold(
      title: l10n.aboutUs,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.xl),
            _buildLogo(),
            const SizedBox(height: AppSpacing.lg),
            Text(
              l10n.appName,
              style: AppTextStyles.displaySmall,
            ),
            Text(
              l10n.aboutSubtitle,
              style: AppTextStyles.titleMedium.copyWith(color: AppColors.primaryBlue),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '${l10n.appVersion} 1.0.0',
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: AppSpacing.xxl),
            
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _buildInfoRow(l10n.appVersion, '1.0.0'),
                  _buildDivider(),
                  _buildInfoRow(l10n.reportDate, 'يناير 2025'), // Reuse key or add new
                  _buildDivider(),
                  _buildInfoRow(l10n.aboutInfrastructure, 'Firebase + Groq AI'),
                  _buildDivider(),
                  _buildInfoRow(l10n.aboutRegion, l10n.egypt),
                ],
              ),
            ),
            
            const SizedBox(height: AppSpacing.xl),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                l10n.aboutDescription,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(height: 1.6),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: AppColors.criticalRed.withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.criticalRed.withOpacity(0.5), width: 2),
      ),
      child: const Icon(
        Icons.medical_services_rounded,
        color: AppColors.criticalRed,
        size: 50,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyMedium,
          ),
          Text(
            value,
            style: AppTextStyles.titleMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, color: AppColors.border);
  }
}

