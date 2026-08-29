import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/shared/widgets/app_widgets.dart';

class EmergencyEntry {
  final String label;
  final String number;
  final IconData icon;
  final Color color;
  final String subtitle;
  final bool isPrimary;

  const EmergencyEntry({
    required this.label,
    required this.number,
    required this.icon,
    required this.color,
    required this.subtitle,
    this.isPrimary = false,
  });
}

class SosHeroCard extends StatelessWidget {
  final EmergencyEntry entry;
  const SosHeroCard({super.key, required this.entry});

  Future<void> _call() async {
    final uri = Uri.parse('tel:${entry.number}');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: _call,
      color: entry.color,
      border: BorderSide.none,
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(entry.icon, size: 120, color: Colors.white.withOpacity(0.1)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(entry.icon, color: Colors.white, size: 40),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(entry.label,
                          style: AppTextStyles.displaySmall.copyWith(color: Colors.white)),
                      Text(entry.subtitle,
                          style: AppTextStyles.bodySmall
                              .copyWith(color: Colors.white.withOpacity(0.9))),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        entry.number,
                        style: AppTextStyles.displayMedium
                            .copyWith(color: Colors.white, letterSpacing: 4),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.call_rounded, color: Colors.white, size: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class NumberCard extends StatelessWidget {
  final EmergencyEntry entry;
  const NumberCard({super.key, required this.entry});

  Future<void> _call() async {
    final uri = Uri.parse('tel:${entry.number}');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: _call,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: entry.color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(entry.icon, color: entry.color, size: 28),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(entry.label, style: AppTextStyles.titleLarge),
          Text(
            entry.number,
            style: AppTextStyles.headlineLarge.copyWith(color: entry.color, letterSpacing: 2),
          ),
        ],
      ),
    );
  }
}
