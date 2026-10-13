import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/design.dart';
import '../../../../../core/shared/widgets/app_widgets.dart';
import '../../../../../core/l10n/generated/app_localizations.dart';
import '../../domain/entities/first_aid_item.dart';

class FirstAidDetailPage extends StatelessWidget {
  final FirstAidItem item;
  const FirstAidDetailPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: AppColors.navy,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(item.title,
                  style: AppTextStyles.headlineMedium.copyWith(color: AppColors.white)),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: item.heroImage,
                    httpHeaders: const {
                      'User-Agent': 'Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36',
                      'Referer': 'https://commons.wikimedia.org/',
                    },
                    fit: BoxFit.cover,
                    placeholder: (_, __) => const ColoredBox(
                      color: AppColors.navy,
                      child: Center(child: CircularProgressIndicator(color: AppColors.white)),
                    ),
                    errorWidget: (_, __, ___) => const ColoredBox(
                      color: AppColors.navy,
                      child: Center(
                        child: Icon(Icons.image_not_supported_outlined, color: AppColors.white, size: 40),
                      ),
                    ),
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black54],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                AppCard(
                  color: AppColors.warning.withOpacity(0.05),
                  border: BorderSide(color: AppColors.warning.withOpacity(0.2)),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: AppColors.warning),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          item.urgencyLevel == 'critical'
                              ? l10n.emergencyInstruction
                              : l10n.standardInstruction,
                          style: AppTextStyles.bodyMedium
                              .copyWith(color: AppColors.warning, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(l10n.firstAidSteps, style: AppTextStyles.headlineLarge),
                const SizedBox(height: AppSpacing.md),
                ...item.steps.map((step) => _StepItem(step: step)),
                const SizedBox(height: AppSpacing.xl),
                GlassCard(
                  borderColor: NC.primary.withOpacity(0.2),
                  child: Text(
                    l10n.firstAidDisclaimer,
                    style: NC.body(12, color: NC.primary),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 32),
                  child: Text(
                    l10n.imageCopyright,
                    style: NC.body(10, color: NC.textLow),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepItem extends StatelessWidget {
  final FirstAidStep step;
  const _StepItem({required this.step});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: AppCard(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (step.imageUrl != null)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
                child: CachedNetworkImage(
                  imageUrl: step.imageUrl!,
                  httpHeaders: const {
                    'User-Agent': 'Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36',
                    'Referer': 'https://commons.wikimedia.org/',
                  },
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    height: 200,
                    color: AppColors.background,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    height: 200,
                    color: AppColors.background,
                    child: const Center(
                      child: Icon(Icons.image_not_supported_outlined, color: AppColors.textSecondary, size: 32),
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryBlue,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${step.number}',
                        style: AppTextStyles.labelLarge.copyWith(color: AppColors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      step.instruction,
                      style: AppTextStyles.bodyLarge,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
