import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/route/app_routes.dart';
import '../../../../core/theme/design.dart';
import '../../auth/presentation/cubit/auth_cubit.dart';

class CitizenProfilePage extends StatelessWidget {
  const CitizenProfilePage({super.key});
  @override
  Widget build(BuildContext context) {
    final state = context.watch<AuthCubit>().state;
    if (state is! AuthAuthenticated) {
      return const Scaffold(body: Center(child: NajdaSpinner()));
    }
    final user = state.user;

    return Scaffold(
      backgroundColor: NC.base,
      appBar: AppBar(
        backgroundColor: NC.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: NC.textHigh, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('الملف الشخصي', style: NC.display(16)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                gradient: NC.primaryGrad,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: NC.primary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  user.fullName?.isNotEmpty == true
                      ? user.fullName![0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    fontFamily: NC.font,
                    fontSize: 38,
                    fontWeight: FontWeight.w800,
                    color: NC.base,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(user.fullName ?? '',
                style: NC.display(20)),
            const SizedBox(height: 4),
            Text(user.phone ?? '',
                style: NC.body(14, color: NC.textMid)),
            const SizedBox(height: 32),

            // Info cards
            _InfoSection(
              title: 'البيانات الشخصية',
              icon: Icons.person_outline_rounded,
              rows: [
                ('الاسم الكامل', user.fullName ?? '—'),
                ('رقم الهاتف', user.phone ?? '—'),
                ('الرقم القومي', user.nationalId ?? '—'),
                ('جهة اتصال الطوارئ', user.emergencyContact ?? '—'),
              ],
            ),
            const SizedBox(height: 16),

            _InfoSection(
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
            const SizedBox(height: 32),

            // Logout
            GestureDetector(
              onTap: () => _confirmLogout(context),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: NC.critical.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: NC.critical.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.logout_rounded, color: NC.critical, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      'تسجيل الخروج',
                      style: NC.label(15, color: NC.critical, weight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: NC.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: NC.critical.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.logout_rounded, color: NC.critical, size: 32),
              ),
              const SizedBox(height: 20),
              Text('تسجيل الخروج', style: NC.display(18)),
              const SizedBox(height: 8),
              Text(
                'هل أنت متأكد من رغبتك في تسجيل الخروج من حسابك؟',
                textAlign: TextAlign.center,
                style: NC.body(14),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('إلغاء', style: NC.label(14, color: NC.textMid)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GradientButton(
                      label: 'خروج',
                      gradient: NC.criticalGrad,
                      height: 48,
                      onTap: () {
                        Navigator.pop(context);
                        context.read<AuthCubit>().signOut();
                        Navigator.pushNamedAndRemoveUntil(
                            context, AppRoutes.login, (r) => false);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<(String, String)> rows;

  const _InfoSection({required this.title, required this.icon, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 8, bottom: 10),
          child: Row(
            children: [
              Icon(icon, color: NC.primary, size: 18),
              const SizedBox(width: 8),
              Text(title, style: NC.label(14, weight: FontWeight.w700)),
            ],
          ),
        ),
        GlassCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: rows.asMap().entries.map((entry) {
              final isLast = entry.key == rows.length - 1;
              final r = entry.value;
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 120,
                          child: Text(r.$1, style: NC.body(13, color: NC.textMid)),
                        ),
                        Expanded(
                          child: Text(r.$2, style: NC.label(14)),
                        ),
                      ],
                    ),
                  ),
                  if (!isLast) const Divider(color: NC.cardBorder, height: 1),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
