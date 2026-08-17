import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../core/theme/design.dart';
import '../../auth/presentation/cubit/auth_cubit.dart';

class CitizenHistoryPage extends StatelessWidget {
  const CitizenHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final historyTitle = l10n?.history ?? 'السجل';
    final historyEmptyTitle = l10n?.historyEmpty ?? 'لا يوجد سجل بعد';
    final authState = context.read<AuthCubit>().state;

    // Guard: if not authenticated (e.g. during logout transition), show nothing
    if (authState is! AuthAuthenticated) {
      return Scaffold(
        backgroundColor: NC.surface,
        appBar: AppBar(title: Text(historyTitle)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final uid = authState.user.id;

    return Scaffold(
      backgroundColor: NC.surface,
      appBar: AppBar(title: Text(historyTitle)),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _combineReports(uid),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const NajdaLoader(message: 'جارٍ التحميل...');
          }
          if (snap.hasError) {
            return NajdaEmptyState(
              icon: Icons.error_outline,
              title: 'حدث خطأ',
              subtitle: snap.error.toString(),
              actionLabel: 'إعادة المحاولة',
              onAction: () {},
            );
          }
          final reports = snap.data ?? [];
          if (reports.isEmpty) {
            return NajdaEmptyState(
              icon: Icons.history_outlined,
              title: historyEmptyTitle,
              subtitle: 'لا توجد بلاغات سابقة لعرضها',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: reports.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
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

    return NajdaCard(
      onTap: () => _showDetails(context, report),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: isEmergency
                      ? NC.critical.withOpacity(0.1)
                      : NC.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isEmergency
                      ? Icons.emergency_outlined
                      : Icons.medical_services_outlined,
                  color: isEmergency ? NC.critical : NC.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEmergency ? 'بلاغ طوارئ' : _typeLabel(type),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      ts != null
                          ? DateFormat('dd MMM yyyy – HH:mm', 'ar').format(ts)
                          : '—',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: NajdaColors.textMuted),
                    ),
                  ],
                ),
              ),
              NajdaStatusBadge(status),
            ],
          ),

          if (report['address'] != null &&
              (report['address'] as String).isNotEmpty) ...[
            const SizedBox(height: 10),
            const Divider(),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.location_on_outlined,
                    size: 14, color: NajdaColors.textMuted),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    report['address'] as String,
                    style: Theme.of(context).textTheme.bodySmall,
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
        color: NajdaColors.cardBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: NajdaColors.border,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            Text('تفاصيل البلاغ',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 20),
            ..._rows(report).map((row) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 120,
                        child: Text(row.$1,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                    color: NajdaColors.textSecondary)),
                      ),
                      Expanded(
                        child: Text(row.$2,
                            style: Theme.of(context).textTheme.bodyMedium),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  List<(String, String)> _rows(Map<String, dynamic> r) {
    final rows = <(String, String)>[];
    if (r['type'] != null) rows.add(('النوع', r['type']));
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
}
