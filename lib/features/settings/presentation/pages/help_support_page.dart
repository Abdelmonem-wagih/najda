import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/shared/widgets/app_widgets.dart';
import '../../../../core/l10n/l10n_extension.dart';
import '../widgets/settings_scaffold.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return SettingsScaffold(
      title: l10n.helpSupport,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(l10n.contactUs),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _buildContactTile(
                    title: l10n.chatWithSupport,
                    subtitle: l10n.available247,
                    icon: Icons.chat_bubble_outline_rounded,
                    color: AppColors.primaryBlue,
                    onTap: () => _launch('https://t.me/najda_support'), 
                  ),
                  _buildDivider(),
                  _buildContactTile(
                    title: l10n.emergencyLine,
                    subtitle: '123',
                    icon: Icons.phone_in_talk_rounded,
                    color: AppColors.criticalRed,
                    onTap: () => _launch('tel:123'),
                  ),
                  _buildDivider(),
                  _buildContactTile(
                    title: l10n.email,
                    subtitle: 'support@najda.eg',
                    icon: Icons.alternate_email_rounded,
                    color: Colors.blueAccent,
                    onTap: () => _launch('mailto:support@najda.eg'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            
            _buildSectionTitle(l10n.faqs),
            _buildFaqItem(
              l10n.faq1Q,
              l10n.faq1A,
            ),
            _buildFaqItem(
              l10n.faq2Q,
              l10n.faq2A,
            ),
            _buildFaqItem(
              l10n.faq3Q,
              l10n.faq3A,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(right: 4, bottom: 12),
      child: Text(
        title,
        style: AppTextStyles.headlineMedium,
      ),
    );
  }

  Widget _buildContactTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(
        title,
        style: AppTextStyles.titleMedium,
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.bodySmall,
      ),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textMuted, size: 14),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question,
              style: AppTextStyles.titleMedium.copyWith(color: AppColors.primaryBlue),
            ),
            const SizedBox(height: 8),
            Text(
              answer,
              style: AppTextStyles.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, indent: 56, color: AppColors.border);
  }
}

