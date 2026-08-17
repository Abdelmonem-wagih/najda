import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/shared/widgets/app_widgets.dart';

class EmergencyNumbersPage extends StatelessWidget {
  const EmergencyNumbersPage({super.key});

  static const _numbers = [
    _EmergencyEntry(
      label: 'الإسعاف',
      number: '123',
      icon: Icons.local_hospital_rounded,
      color: AppColors.criticalRed,
      subtitle: 'للحوادث والإصابات والتبليغ عن حالات طبية طارئة',
      isPrimary: true,
    ),
    _EmergencyEntry(
      label: 'الشرطة',
      number: '122',
      icon: Icons.shield_rounded,
      color: AppColors.primaryBlue,
      subtitle: 'للجرائم والبلاغات الأمنية والمرور',
    ),
    _EmergencyEntry(
      label: 'المطافي',
      number: '180',
      icon: Icons.local_fire_department_rounded,
      color: Colors.orange,
      subtitle: 'للحرائق وحوادث الطرق والإنقاذ',
    ),
    _EmergencyEntry(
      label: 'النجدة',
      number: '125',
      icon: Icons.security_rounded,
      color: Colors.teal,
      subtitle: 'للكوارث الطبيعية والإنقاذ المدني',
    ),
    _EmergencyEntry(
      label: 'الإسعاف الطائر',
      number: '123',
      icon: Icons.airplanemode_active_rounded,
      color: AppColors.accentBlue,
      subtitle: 'للحالات الحرجة في المناطق البعيدة',
    ),
    _EmergencyEntry(
      label: 'نجدة الطفل',
      number: '16000',
      icon: Icons.child_care_rounded,
      color: Colors.purple,
      subtitle: 'لحماية الطفل من العنف والإهمال',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        title: const Text('أرقام الطوارئ'),
      ),
      body: CustomScrollView(
        slivers: [
          // Primary SOS Card
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: _SosHeroCard(entry: _numbers[0]),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Text('أرقام الطوارئ الأخرى', style: AppTextStyles.headlineMedium),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) => _NumberCard(entry: _numbers[i + 1]),
                childCount: _numbers.length - 1,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: AppSpacing.md,
                crossAxisSpacing: AppSpacing.md,
                childAspectRatio: 0.9,
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: AppCard(
                color: AppColors.primaryBlue.withOpacity(0.05),
                border: BorderSide(color: AppColors.primaryBlue.withOpacity(0.1)),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppColors.primaryBlue),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        'اضغط على أي رقم للاتصال المباشر، أو اضغط مطولاً لنسخ الرقم.',
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.primaryBlue),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
        ],
      ),
    );
  }
}

class _SosHeroCard extends StatelessWidget {
  final _EmergencyEntry entry;
  const _SosHeroCard({required this.entry});

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
                      Text(entry.label, style: AppTextStyles.displaySmall.copyWith(color: Colors.white)),
                      Text(entry.subtitle, style: AppTextStyles.bodySmall.copyWith(color: Colors.white.withOpacity(0.9))),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        entry.number,
                        style: AppTextStyles.displayMedium.copyWith(color: Colors.white, letterSpacing: 4),
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

class _NumberCard extends StatelessWidget {
  final _EmergencyEntry entry;
  const _NumberCard({required this.entry});

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

class _EmergencyEntry {
  final String label;
  final String number;
  final IconData icon;
  final Color color;
  final String subtitle;
  final bool isPrimary;

  const _EmergencyEntry({
    required this.label,
    required this.number,
    required this.icon,
    required this.color,
    required this.subtitle,
    this.isPrimary = false,
  });
}
