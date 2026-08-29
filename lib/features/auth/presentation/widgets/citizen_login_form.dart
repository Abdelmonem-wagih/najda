import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/l10n/generated/app_localizations.dart';

class CitizenLoginForm extends StatelessWidget {
  final TextEditingController phoneController;
  
  const CitizenLoginForm({
    super.key,
    required this.phoneController,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.phoneNumber, style: AppTextStyles.labelLarge),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: phoneController,
          keyboardType: TextInputType.phone,
          textDirection: TextDirection.ltr,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[+\d]'))
          ],
          decoration: InputDecoration(
            hintText: l10n.phoneHint,
            prefixIcon: const Icon(Icons.phone_outlined, size: 20),
          ),
          validator: (v) {
            if (v == null || v.isEmpty) return l10n.fieldRequired;
            if (!v.startsWith('+')) return l10n.phoneStartsWithPlus;
            if (v.replaceAll(RegExp(r'\D'), '').length < 10)
              return l10n.phoneTooShort;
            return null;
          },
        ),
      ],
    );
  }
}
