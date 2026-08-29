import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/shared/widgets/app_widgets.dart';
import '../../../../../core/l10n/generated/app_localizations.dart';
import '../../domain/entities/hospital.dart';

class HospitalCard extends StatelessWidget {
  final Hospital h;
  const HospitalCard({super.key, required this.h});

  Future<void> _call(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _maps() async {
    final uri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1'
        '&destination=${h.lat},${h.lng}'
        '&destination_place_id=${h.placeId}'
        '&travelmode=driving');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: AppRadius.radiusMd,
                ),
                child: const Icon(Icons.local_hospital_outlined,
                    color: AppColors.success, size: 28),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(h.name, style: AppTextStyles.titleLarge),
                    Text(h.address,
                        style: AppTextStyles.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withOpacity(0.1),
                      borderRadius: AppRadius.radiusSm,
                    ),
                    child: Text(
                      l10n.km(h.distKm.toStringAsFixed(1)),
                      style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.primaryBlue, fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    h.isOpen ? l10n.openNow : l10n.closed,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: h.isOpen ? AppColors.success : AppColors.criticalRed,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),

          if (h.rating != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Row(children: [
              const Icon(Icons.star_rounded, color: AppColors.warning, size: 16),
              const SizedBox(width: AppSpacing.xs),
              Text(h.rating!.toStringAsFixed(1),
                  style: AppTextStyles.labelMedium.copyWith(color: AppColors.warning)),
            ]),
          ],

          const SizedBox(height: AppSpacing.md),
          const Divider(),
          const SizedBox(height: AppSpacing.md),

          Row(children: [
            Expanded(
              child: AppButton(
                label: l10n.call,
                isPrimary: false,
                onPressed: () => _call(h.phone.isNotEmpty ? h.phone : '123'),
                icon: Icons.phone_rounded,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: AppButton(
                label: l10n.directions,
                onPressed: _maps,
                icon: Icons.navigation_rounded,
              ),
            ),
          ]),
        ],
      ),
    );
  }
}
