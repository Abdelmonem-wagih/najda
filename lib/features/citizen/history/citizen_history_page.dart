import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/shared/widgets/app_widgets.dart';
import '../../auth/presentation/cubit/auth_cubit.dart';

class CitizenHistoryPage extends StatelessWidget {
  const CitizenHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final historyTitle = l10n?.history ?? 'سجل البلاغات';
    final historyEmptyTitle = l10n?.historyEmpty ?? 'لا توجد بلاغات سابقة';
    final authState = context.read<AuthCubit>().state;

    if (authState is! AuthAuthenticated) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: Text(historyTitle)),
        body: const AppLoader(),
      );
    }

    final uid = authState.user.id;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        title: Text(historyTitle),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _combineReports(uid),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const AppLoader(message: 'جارٍ تحميل السجل...');
          }
          if (snap.hasError) {
            return AppEmptyState(
              icon: Icons.error_outline,
              title: 'حدث خطأ ما',
              subtitle: snap.error.toString(),
              actionLabel: 'إعادة المحاولة',
              onAction: () {},
            );
          }
          final reports = snap.data ?? [];
          if (reports.isEmpty) {
            return AppEmptyState(
              icon: Icons.history_outlined,
              title: historyEmptyTitle,
              subtitle: 'ستظهر هنا البلاغات التي تقوم بإرسالها',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: reports.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (ctx, i) => _ReportCard(report: reports[i]),
          );
        },
      ),
    );
  }

  Stream<List<Map<String, dynamic>>> _combineReports(String uid) {
    final fs = FirebaseFirestore.instance;

    final s1 = fs
        .collection('reports')
        .where('patientUid', isEqualTo: uid)
        .snapshots()
        .map((s) => s.docs.map((d) {
              final data = Map<String, dynamic>.from(d.data());
              data['_id'] = d.id;
              data['_collection'] = 'report';
              return data;
            }).toList());

    final s2 = fs
        .collection('emergency_reports')
        .where('patientUid', isEqualTo: uid)
        .snapshots()
        .map((s) => s.docs.map((d) {
              final data = Map<String, dynamic>.from(d.data());
              data['_id'] = d.id;
              data['_collection'] = 'emergency';
              return data;
            }).toList());

    return s1.asyncExpand((r1) => s2.map((r2) {
          final all = [...r1, ...r2];
          all.sort((a, b) {
            final tA = _ts(a);
            final tB = _ts(b);
            return tB.compareTo(tA);
          });
          return all;
        }));
  }

  DateTime _ts(Map<String, dynamic> d) {
    final v = d['createdAt'] ?? d['timestamp'];
    if (v is Timestamp) return v.toDate();
    if (v is String) return DateTime.tryParse(v) ?? DateTime(2000);
    return DateTime(2000);
  }
}

class _ReportCard extends StatelessWidget {
  final Map<String, dynamic> report;
  const _ReportCard({required this.report});

  @override
  Widget build(BuildContext context) {
    final isEmergency = report['_collection'] == 'emergency';
    final status = report['status'] as String? ?? 'pending';
    final ts = _parseTs(report);
    final type = report['type'] as String? ?? '';

    return AppCard(
      onTap: () => _showDetails(context, report),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: isEmergency
                      ? AppColors.criticalRed.withOpacity(0.1)
                      : AppColors.primaryBlue.withOpacity(0.1),
                  borderRadius: AppRadius.radiusMd,
                ),
                child: Icon(
                  isEmergency
                      ? Icons.emergency_outlined
                      : Icons.medical_services_outlined,
                  color: isEmergency ? AppColors.criticalRed : AppColors.primaryBlue,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEmergency ? 'بلاغ طوارئ' : _typeLabel(type),
                      style: AppTextStyles.titleLarge,
                    ),
                    Text(
                      ts != null
                          ? DateFormat('dd MMM yyyy – HH:mm', 'ar').format(ts)
                          : '—',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
              AppStatusBadge(status: status),
            ],
          ),

          if (report['address'] != null &&
              (report['address'] as String).isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            const Divider(),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                const Icon(Icons.location_on_outlined,
                    size: 16, color: AppColors.textMuted),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    report['address'] as String,
                    style: AppTextStyles.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  DateTime? _parseTs(Map<String, dynamic> d) {
    final v = d['createdAt'] ?? d['timestamp'];
    if (v is Timestamp) return v.toDate();
    if (v is String) return DateTime.tryParse(v);
    return null;
  }

  String _typeLabel(String key) {
    const m = {
      'carAccident': 'حادث سيارة',
      'pedestrianHit': 'دهس مشاة',
      'fallFromHeight': 'سقوط من ارتفاع',
      'fall': 'سقوط عادي',
      'electricShock': 'صدمة كهربائية',
      'fireBurn': 'حريق / حروق',
      'suffocation': 'اختناق',
      'drowning': 'غرق',
      'workInjury': 'إصابة عمل',
      'poisoning': 'تسمم',
      'assault': 'اعتداء',
      'sportInjury': 'إصابة رياضية',
      'gunshot': 'طلق ناري',
      'stabbing': 'طعن',
      'medicalEmergency': 'حالة مرضية',
    };
    return m[key] ?? key;
  }

  void _showDetails(BuildContext context, Map<String, dynamic> r) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DetailsSheet(report: r),
    );
  }
}

class _DetailsSheet extends StatelessWidget {
  final Map<String, dynamic> report;
  const _DetailsSheet({required this.report});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.xl)),
      ),
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.xl),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('تفاصيل البلاغ',
                style: AppTextStyles.headlineMedium),
            const SizedBox(height: AppSpacing.lg),
            ..._rows(report).map((row) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 120,
                        child: Text(row.$1,
                            style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.textSecondary)),
                      ),
                      Expanded(
                        child: Text(row.$2,
                            style: AppTextStyles.bodyLarge),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  List<(String, String)> _rows(Map<String, dynamic> r) {
    final rows = <(String, String)>[];
    if (r['type'] != null) rows.add(('النوع', _typeLabel(r['type'])));
    if (r['consciousnessLevel'] != null && (r['consciousnessLevel'] as String).isNotEmpty)
      rows.add(('الوعي', r['consciousnessLevel']));
    if (r['injuryLocation'] != null && (r['injuryLocation'] as String).isNotEmpty)
      rows.add(('موضع الإصابة', r['injuryLocation']));
    if (r['painLevel'] != null && (r['painLevel'] as String).isNotEmpty)
      rows.add(('مستوى الألم', r['painLevel']));
    if (r['status'] != null) rows.add(('الحالة', r['status']));
    if (r['address'] != null && (r['address'] as String).isNotEmpty)
      rows.add(('الموقع', r['address']));
    return rows;
  }

  String _typeLabel(String key) {
    const m = {
      'carAccident': 'حادث سيارة',
      'pedestrianHit': 'دهس مشاة',
      'fallFromHeight': 'سقوط من ارتفاع',
      'fall': 'سقوط عادي',
      'electricShock': 'صدمة كهربائية',
      'fireBurn': 'حريق / حروق',
      'suffocation': 'اختناق',
      'drowning': 'غرق',
      'workInjury': 'إصابة عمل',
      'poisoning': 'تسمم',
      'assault': 'اعتداء',
      'sportInjury': 'إصابة رياضية',
      'gunshot': 'طلق ناري',
      'stabbing': 'طعن',
      'medicalEmergency': 'حالة مرضية',
    };
    return m[key] ?? key;
  }
}
