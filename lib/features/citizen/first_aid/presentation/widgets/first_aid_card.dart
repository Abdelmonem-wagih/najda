import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/shared/widgets/app_widgets.dart';
import '../../../../../core/l10n/generated/app_localizations.dart';
import '../../domain/entities/first_aid_item.dart';
import '../pages/first_aid_detail_page.dart';

class FirstAidCard extends StatelessWidget {
  final FirstAidItem item;
  const FirstAidCard({super.key, required this.item});

  Color _urgencyColor(String level) {
    switch (level) {
      case 'critical': return AppColors.criticalRed;
      case 'high': return AppColors.warning;
      default: return AppColors.success;
    }
  }

  String _urgencyLabel(BuildContext context, String level) {
    final l10n = AppLocalizations.of(context)!;
    switch (level) {
      case 'critical': return l10n.criticalUrgency;
      case 'high': return l10n.highUrgency;
      default: return l10n.normalUrgency;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _urgencyColor(item.urgencyLevel);
    return AppCard(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => FirstAidDetailPage(item: item)),
      ),
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
            child: CachedNetworkImage(
              imageUrl: item.heroImage,
              httpHeaders: const {
                'User-Agent': 'Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36',
                'Referer': 'https://commons.wikimedia.org/',
              },
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                height: 160,
                color: AppColors.background,
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (_, __, ___) => Container(
                height: 160,
                color: AppColors.background,
                child: const Icon(Icons.medical_services_outlined, size: 48, color: AppColors.textMuted),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.title, style: AppTextStyles.titleLarge),
                      Text(item.subtitle, style: AppTextStyles.bodySmall),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: AppRadius.radiusXl,
                    border: Border.all(color: color.withOpacity(0.3)),
                  ),
                  child: Text(
                    _urgencyLabel(context, item.urgencyLevel),
                    style: AppTextStyles.labelMedium.copyWith(color: color, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
