import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/shared/widgets/app_widgets.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import 'presentation/widgets/emergency_widgets.dart';

class EmergencyNumbersPage extends StatelessWidget {
  const EmergencyNumbersPage({super.key});

  List<EmergencyEntry> _getNumbers(AppLocalizations l10n) => [
        EmergencyEntry(
          label: l10n.ambulance,
          number: '123',
          icon: Icons.local_hospital_rounded,
          color: AppColors.criticalRed,
          subtitle: l10n.ambulanceSubtitle,
          isPrimary: true,
        ),
        EmergencyEntry(
          label: l10n.police,
          number: '122',
          icon: Icons.shield_rounded,
          color: AppColors.primaryBlue,
          subtitle: l10n.policeSubtitle,
        ),
        EmergencyEntry(
          label: l10n.fire,
          number: '180',
          icon: Icons.local_fire_department_rounded,
          color: Colors.orange,
          subtitle: l10n.fireSubtitle,
        ),
        EmergencyEntry(
          label: l10n.rescue,
          number: '125',
          icon: Icons.security_rounded,
          color: Colors.teal,
          subtitle: l10n.rescueSubtitle,
        ),
        EmergencyEntry(
          label: l10n.airAmbulance,
          number: '123',
          icon: Icons.airplanemode_active_rounded,
          color: AppColors.accentBlue,
          subtitle: l10n.airAmbulanceSubtitle,
        ),
        EmergencyEntry(
          label: l10n.childRescue,
          number: '16000',
          icon: Icons.child_care_rounded,
          color: Colors.purple,
          subtitle: l10n.childRescueSubtitle,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final numbers = _getNumbers(l10n);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        title: Text(l10n.emergency),
      ),
      body: CustomScrollView(
        slivers: [
          // Primary SOS Card
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: SosHeroCard(entry: numbers[0]),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Text(l10n.otherEmergencyNumbers, style: AppTextStyles.headlineMedium),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) => NumberCard(entry: numbers[i + 1]),
                childCount: numbers.length - 1,
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
                        l10n.emergencyNumbersTip,
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
