import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/shared/widgets/app_widgets.dart';
import '../../../../core/l10n/l10n_extension.dart';
import '../cubit/settings_cubit.dart';
import '../cubit/settings_state.dart';
import '../widgets/settings_scaffold.dart';

class LanguagePage extends StatelessWidget {
  const LanguagePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return SettingsScaffold(
      title: l10n.language,
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, state) {
            final currentLocale = state.locale.languageCode;
            
            return Column(
              children: [
                _buildLanguageItem(
                  context,
                  title: l10n.arabic,
                  flag: '🇪🇬',
                  isSelected: currentLocale == 'ar',
                  onTap: () => context.read<SettingsCubit>().updateLocale(const Locale('ar')),
                ),
                const SizedBox(height: AppSpacing.md),
                _buildLanguageItem(
                  context,
                  title: l10n.english,
                  flag: '🇬🇧',
                  isSelected: currentLocale == 'en',
                  onTap: () => context.read<SettingsCubit>().updateLocale(const Locale('en')),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildLanguageItem(
    BuildContext context, {
    required String title,
    required String flag,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return AppCard(
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Text(
              flag,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.titleMedium,
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.primaryBlue,
              ),
          ],
        ),
      ),
    );
  }
}

