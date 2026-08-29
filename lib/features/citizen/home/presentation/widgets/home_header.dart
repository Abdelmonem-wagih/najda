import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/route/app_routes.dart';
import '../../../../../core/l10n/generated/app_localizations.dart';

class HomeHeader extends StatelessWidget {
  final String name;

  const HomeHeader({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final displayName = name.isNotEmpty ? name.split(' ').first : '';

    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      backgroundColor: AppColors.navy,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.navyGradient,
          ),
          padding: const EdgeInsets.fromLTRB(20, 60, 20, 16),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    l10n.greeting(displayName),
                    style: AppTextStyles.headlineLarge.copyWith(color: AppColors.white),
                  ),
                  Text(
                    l10n.homeSubtitle,
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.white.withOpacity(0.8)),
                  ),
                ],
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.pushNamed(
                    context, AppRoutes.citizenProfile),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.white.withOpacity(0.3)),
                  ),
                  child: Center(
                    child: Text(
                      displayName.isNotEmpty ? displayName[0] : 'م',
                      style: AppTextStyles.headlineMedium.copyWith(color: AppColors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
