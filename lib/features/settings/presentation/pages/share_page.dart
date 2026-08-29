import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/shared/widgets/app_widgets.dart';
import '../../../../core/l10n/l10n_extension.dart';
import '../widgets/settings_scaffold.dart';

class SharePage extends StatelessWidget {
  const SharePage({super.key});

  static const String _appLink = 'najda.app/download';

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(const ClipboardData(text: _appLink));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.linkCopied),
        backgroundColor: AppColors.primaryBlue,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _share(BuildContext context, String message) {
    Share.share('$message $_appLink');
  }

  void _launchSms(BuildContext context) async {
    final uri = Uri.parse('sms:?body=${context.l10n.smsMessage} $_appLink');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return SettingsScaffold(
      title: l10n.shareApp,
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.lg),
            AppCard(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.appLink,
                          style: AppTextStyles.bodySmall,
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          _appLink,
                          style: TextStyle(
                            color: AppColors.primaryBlue,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => _copyToClipboard(context),
                    icon: const Icon(Icons.copy_rounded, color: AppColors.primaryBlue),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              l10n.shareTitle,
              style: AppTextStyles.headlineMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _buildShareTile(
                    title: 'واتساب',
                    icon: Icons.chat_outlined,
                    color: Colors.green,
                    onTap: () => _share(context, l10n.shareMessage),
                  ),
                  _buildDivider(),
                  _buildShareTile(
                    title: l10n.copyLink,
                    icon: Icons.link_rounded,
                    color: AppColors.primaryBlue,
                    onTap: () => _copyToClipboard(context),
                  ),
                  _buildDivider(),
                  _buildShareTile(
                    title: 'رسالة نصية',
                    icon: Icons.sms_outlined,
                    color: Colors.orange,
                    onTap: () => _launchSms(context),
                  ),
                  _buildDivider(),
                  _buildShareTile(
                    title: l10n.otherWays,
                    icon: Icons.more_horiz_rounded,
                    color: AppColors.textSecondary,
                    onTap: () => _share(context, l10n.shareMessage),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareTile({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: AppTextStyles.bodyLarge,
      ),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, indent: 56, color: AppColors.border);
  }
}

