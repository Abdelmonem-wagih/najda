import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/l10n/generated/app_localizations.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const SectionHeader({
    super.key,
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, color: AppColors.primaryBlue, size: 20),
      const SizedBox(width: AppSpacing.sm),
      Text(title, style: AppTextStyles.headlineMedium),
      const SizedBox(width: AppSpacing.md),
      const Expanded(child: Divider()),
    ]);
  }
}

class RegistrationFormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData? icon;
  final String? hint;
  final TextInputType? keyboardType;
  final bool optional;
  final String? Function(String?)? validator;

  const RegistrationFormField({
    super.key,
    required this.label,
    required this.controller,
    this.icon,
    this.hint,
    this.keyboardType,
    this.optional = false,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Text(label, style: AppTextStyles.labelLarge),
          if (optional) ...[
            const SizedBox(width: AppSpacing.xs),
            Text(l10n.optional, style: AppTextStyles.bodySmall),
          ],
        ]),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: icon != null ? Icon(icon, size: 20) : null,
          ),
          validator: validator,
        ),
      ],
    );
  }
}
