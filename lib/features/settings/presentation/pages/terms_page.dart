import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/shared/widgets/app_widgets.dart';
import '../../../../core/l10n/l10n_extension.dart';
import '../widgets/settings_scaffold.dart';

class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return SettingsScaffold(
      title: l10n.termsOfService,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              l10n.termsAcceptance,
              l10n.termsAcceptanceDesc,
            ),
            _buildSection(
              l10n.termsServiceUsage,
              l10n.termsServiceUsageDesc,
            ),
            _buildSection(
              l10n.termsLiability,
              l10n.termsLiabilityDesc,
            ),
            _buildSection(
              l10n.termsTermination,
              l10n.termsTerminationDesc,
            ),
            const SizedBox(height: AppSpacing.xl),
            Center(
              child: Text(
                l10n.lastUpdated('يناير 2025'),
                style: AppTextStyles.bodySmall,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.headlineMedium.copyWith(color: AppColors.primaryBlue),
          ),
          const SizedBox(height: 12),
          AppCard(
            child: Text(
              content.replaceAll('\\n', '\n'),
              style: AppTextStyles.bodyMedium.copyWith(height: 1.8),
            ),
          ),
        ],
      ),
    );
  }
}

