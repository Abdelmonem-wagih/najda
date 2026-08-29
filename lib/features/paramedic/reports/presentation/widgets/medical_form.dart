import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/shared/widgets/app_widgets.dart';
import '../../../../../core/l10n/generated/app_localizations.dart';

class MedicalForm extends StatefulWidget {
  final Map<String, String> answers;
  final TextEditingController notesCtrl;
  final bool submitting;
  final VoidCallback onSubmit;
  final VoidCallback onCancel;

  const MedicalForm({
    super.key,
    required this.answers,
    required this.notesCtrl,
    required this.submitting,
    required this.onSubmit,
    required this.onCancel,
  });

  @override
  State<MedicalForm> createState() => _MedicalFormState();
}

class _MedicalFormState extends State<MedicalForm> {
  static const _questions = [
    ('consciousness_level', 'مستوى الوعي', ['واعٍ تماماً', 'يستجيب للصوت', 'يستجيب للألم', 'فاقد الوعي']),
    ('breathing', 'التنفس', ['طبيعي', 'سريع', 'بطيء', 'مكتوم', 'متوقف']),
    ('pulse', 'النبض', ['طبيعي', 'سريع', 'بطيء', 'غير منتظم', 'لا يوجد']),
    ('bleeding', 'النزيف', ['لا يوجد', 'خفيف', 'متوسط', 'شديد']),
    ('skin_color', 'لون الجلد', ['طبيعي', 'شاحب', 'مزرق', 'أحمر']),
    ('pupil_response', 'استجابة الحدقة', ['طبيعية', 'متوسعة', 'متقلصة', 'غير متساوية']),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.fieldMedicalReport, style: AppTextStyles.headlineLarge),
          const SizedBox(height: AppSpacing.md),
          ..._questions.map((q) {
            final (id, label, opts) = q;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: AppTextStyles.titleLarge),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.sm,
                      children: opts.map((opt) {
                        final sel = widget.answers[id] == opt;
                        return ChoiceChip(
                          label: Text(opt),
                          selected: sel,
                          onSelected: (val) => setState(() => widget.answers[id] = opt),
                          selectedColor: AppColors.primaryBlue.withOpacity(0.2),
                          labelStyle: AppTextStyles.bodyMedium.copyWith(
                            color: sel ? AppColors.primaryBlue : AppColors.textPrimary,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            );
          }),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.additionalNotes, style: AppTextStyles.titleLarge),
                const SizedBox(height: AppSpacing.sm),
                TextField(
                  controller: widget.notesCtrl,
                  maxLines: 3,
                  decoration: InputDecoration(hintText: l10n.additionalNotesHint),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          AppButton(
              label: l10n.submitReportAction,
              onPressed: widget.onSubmit,
              isLoading: widget.submitting),
          const SizedBox(height: AppSpacing.md),
          AppButton(label: l10n.cancel, isPrimary: false, onPressed: widget.onCancel),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}
