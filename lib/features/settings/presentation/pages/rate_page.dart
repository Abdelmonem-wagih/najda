import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/shared/widgets/app_widgets.dart';
import '../../../../core/l10n/l10n_extension.dart';
import '../widgets/settings_scaffold.dart';

class RatePage extends StatefulWidget {
  const RatePage({super.key});

  @override
  State<RatePage> createState() => _RatePageState();
}

class _RatePageState extends State<RatePage> {
  int _rating = 0;

  String _getRatingLabel(BuildContext context) {
    switch (_rating) {
      case 1: return 'سيء';
      case 2: return 'مقبول';
      case 3: return 'جيد';
      case 4: return 'جيد جداً';
      case 5: return 'ممتاز';
      default: return 'ما هو تقييمك؟';
    }
  }

  void _submit() async {
    const url = 'https://play.google.com/store/apps/details?id=eg.najda.app'; 
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return SettingsScaffold(
      title: l10n.rateApp,
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.stars_rounded,
              color: AppColors.primaryBlue,
              size: 80,
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              l10n.rateTitle,
              style: AppTextStyles.displaySmall,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.rateSubtitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.xxl),
            
            Text(
              _getRatingLabel(context),
              style: AppTextStyles.headlineMedium.copyWith(color: AppColors.primaryBlue),
            ),
            const SizedBox(height: AppSpacing.lg),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final starIndex = index + 1;
                return IconButton(
                  onPressed: () => setState(() => _rating = starIndex),
                  icon: Icon(
                    starIndex <= _rating ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: starIndex <= _rating ? Colors.amber : AppColors.textMuted,
                    size: 40,
                  ),
                );
              }),
            ),
            
            const Spacer(),
            AppButton(
              label: l10n.rateSubmit,
              onPressed: _rating > 0 ? _submit : null,
            ),
          ],
        ),
      ),
    );
  }
}

