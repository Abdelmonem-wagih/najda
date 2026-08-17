import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/route/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/shared/widgets/app_widgets.dart';
import '../../auth/presentation/cubit/auth_cubit.dart';

class CitizenProfilePage extends StatelessWidget {
  const CitizenProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AuthCubit>().state;
    if (state is! AuthAuthenticated) {
      return const Scaffold(body: AppLoader());
    }
    final user = state.user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        title: const Text('الملف الشخصي'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            // Profile Header
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryBlue.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  user.fullName?.isNotEmpty == true
                      ? user.fullName![0].toUpperCase()
                      : '?',
                  style: AppTextStyles.displayLarge.copyWith(color: AppColors.white),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(user.fullName ?? '', style: AppTextStyles.headlineLarge),
            Text(user.phone ?? '', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: AppSpacing.xl),

            // Info Sections
            _buildInfoSection(
              context,
              title: 'البيانات الشخصية',
              icon: Icons.person_outline,
              rows: [
                ('الاسم الكامل', user.fullName ?? '—'),
                ('رقم الهاتف', user.phone ?? '—'),
                ('الرقم القومي', user.nationalId ?? '—'),
                ('جهة اتصال الطوارئ', user.emergencyContact ?? '—'),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            _buildInfoSection(
              context,
              title: 'البيانات الطبية',
              icon: Icons.medical_information_outlined,
              rows: [
                ('الأمراض المزمنة', user.chronicDiseases.isEmpty ? 'لا يوجد' : user.chronicDiseases.join('، ')),
                ('الحساسية', user.allergies.isEmpty ? 'لا يوجد' : user.allergies.join('، ')),
                ('الأدوية الحالية', user.currentMedications.isEmpty ? 'لا يوجد' : user.currentMedications.join('، ')),
                if (user.additionalInfo?.isNotEmpty == true)
                  ('معلومات إضافية', user.additionalInfo!),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            // Logout Button
            AppButton(
              label: 'تسجيل الخروج',
              isPrimary: false,
              onPressed: () => _confirmLogout(context),
              icon: Icons.logout_rounded,
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context,
      {required String title, required IconData icon, required List<(String, String)> rows}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: AppSpacing.xs, bottom: AppSpacing.sm),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primaryBlue, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Text(title, style: AppTextStyles.titleLarge),
            ],
          ),
        ),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: rows.asMap().entries.map((entry) {
              final isLast = entry.key == rows.length - 1;
              final r = entry.value;
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 120,
                          child: Text(r.$1, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                        ),
                        Expanded(
                          child: Text(r.$2, style: AppTextStyles.labelLarge),
                        ),
                      ],
                    ),
                  ),
                  if (!isLast) const Divider(),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusXl),
        title: const Text('تسجيل الخروج'),
        content: const Text('هل أنت متأكد من رغبتك في تسجيل الخروج من حسابك؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.criticalRed),
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthCubit>().signOut();
              Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (r) => false);
            },
            child: const Text('خروج'),
          ),
        ],
      ),
    );
  }
}
