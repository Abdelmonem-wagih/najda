import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/route/app_routes.dart';
import '../../../core/theme/design.dart';
import '../../auth/presentation/cubit/auth_cubit.dart';

class NotificationsHistoryPage extends StatelessWidget {
  final bool showHistory;
  const NotificationsHistoryPage({super.key, required this.showHistory});

  @override
  Widget build(BuildContext context) {
    final user = (context.read<AuthCubit>().state as AuthAuthenticated).user;
    final ambId = user.ambulanceId ?? user.id;

    return Scaffold(
      backgroundColor: NC.base,
      appBar: AppBar(
        backgroundColor: NC.surface,
        automaticallyImplyLeading: Navigator.canPop(context),
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_rounded,
                    color: NC.textHigh, size: 20),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: Text(
          showHistory ? 'سجل المهام' : 'الإشعارات',
          style: NC.display(16),
        ),
        actions: [
          if (!showHistory)
            TextButton(
              onPressed: () => _markAllRead(ambId),
              child: Text('تحديد الكل كمقروء',
                  style: NC.label(12, color: NC.primary)),
            ),
        ],
      ),
      body: showHistory
          ? _HistoryTab(ambulanceId: ambId)
          : _NotificationsTab(ambulanceId: ambId),
    );
  }

  Future<void> _markAllRead(String uid) async {
    final q = await FirebaseFirestore.instance
        .collection('notifications')
        .where('ambulanceId', isEqualTo: uid)
        .where('isRead', isEqualTo: false)
        .get();
    final batch = FirebaseFirestore.instance.batch();
    for (final d in q.docs) {
      batch.update(d.reference, {
        'isRead': true,
        'readAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }
}

// ─── Notifications tab ────────────────────────────────────────────
class _NotificationsTab extends StatelessWidget {
  final String ambulanceId;
  const _NotificationsTab({required this.ambulanceId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('notifications')
          .where('ambulanceId', isEqualTo: ambulanceId)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .snapshots(),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const NajdaSpinner(label: 'جارٍ التحميل...');
        }
        final docs = snap.data?.docs ?? [];
        if (docs.isEmpty) {
          return const NajdaEmpty(
            icon: Icons.notifications_off_outlined,
            title: 'لا توجد إشعارات',
            subtitle: 'ستظهر هنا إشعارات البلاغات الجديدة',
          );
        }
        return RefreshIndicator(
          onRefresh: () async {
            await Future.delayed(const Duration(milliseconds: 500));
          },
          child: docs.isEmpty
              ? const NajdaEmpty(
                  icon: Icons.notifications_off_outlined,
                  title: 'لا توجد إشعارات',
                  subtitle: 'ستظهر هنا إشعارات البلاغات الجديدة',
                )
              : ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (ctx, i) => _NotifCard(doc: docs[i]),
                ),
        );
      },
    );
  }
}

class _NotifCard extends StatelessWidget {
  final QueryDocumentSnapshot doc;
  const _NotifCard({required this.doc});

  @override
  Widget build(BuildContext context) {
    final d          = doc.data() as Map<String, dynamic>;
    final isRead     = d['isRead'] as bool? ?? false;
    final title      = d['title'] as String? ?? 'إشعار';
    final body       = d['body'] as String? ?? '';
    final type       = d['type'] as String? ?? '';
    final reportId   = d['reportId'] as String?;
    final reportType = d['reportType'] as String?;
    final ts         = d['createdAt'] as Timestamp?;
    final isEmergency = type.contains('emergency');
    final color = isEmergency ? NC.critical : NC.primary;

    return GestureDetector(
      onTap: () {
        // Mark read
        if (!isRead) {
          doc.reference.update({
            'isRead': true,
            'readAt': FieldValue.serverTimestamp(),
          });
        }
        // Navigate to report
        if (reportId != null && reportType != null) {
          Navigator.pushNamed(
            context,
            AppRoutes.ambulanceReportDetails,
            arguments: {
              'reportId': reportId,
              'reportType': reportType,
            },
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: NC.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isRead ? NC.cardBorder : color.withOpacity(0.5),
            width: isRead ? 1 : 1.5,
          ),
          boxShadow: isRead
              ? null
              : [
                  BoxShadow(
                    color: color.withOpacity(0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Unread dot
            Padding(
              padding: const EdgeInsets.only(top: 5, left: 10),
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isRead ? Colors.transparent : color,
                  border: Border.all(
                      color: isRead ? NC.cardBorder : color),
                ),
              ),
            ),
            // Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isEmergency
                    ? Icons.emergency_outlined
                    : Icons.assignment_outlined,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: NC.label(14,
                          weight: isRead
                              ? FontWeight.w500
                              : FontWeight.w700,
                          color:
                              isRead ? NC.textMid : NC.textHigh)),
                  if (body.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(body,
                        style: NC.body(12),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                  ],
                  const SizedBox(height: 6),
                  if (ts != null)
                    Text(
                      DateFormat('dd/MM – HH:mm', 'ar')
                          .format(ts.toDate()),
                      style: NC.body(10, color: NC.textLow),
                    ),
                ],
              ),
            ),
            if (reportId != null)
              const Icon(Icons.chevron_right_rounded,
                  color: NC.textLow, size: 16),
          ],
        ),
      ),
    );
  }
}

// ─── History tab ──────────────────────────────────────────────────
class _HistoryTab extends StatelessWidget {
  final String ambulanceId;
  const _HistoryTab({required this.ambulanceId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('ambulance_history')
          .where('ambulanceId', isEqualTo: ambulanceId)
          .orderBy('completedAt', descending: true)
          .limit(30)
          .snapshots(),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const NajdaSpinner(label: 'جارٍ التحميل...');
        }
        final docs = snap.data?.docs ?? [];
        if (docs.isEmpty) {
          return const NajdaEmpty(
            icon: Icons.history_outlined,
            title: 'لا توجد مهام مكتملة',
            subtitle: 'ستظهر هنا المهام التي أكملتها',
          );
        }
        return RefreshIndicator(
          onRefresh: () async {
            await Future.delayed(const Duration(milliseconds: 500));
          },
          child: docs.isEmpty
              ? const NajdaEmpty(
                  icon: Icons.history_outlined,
                  title: 'لا توجد مهام مكتملة',
                  subtitle: 'ستظهر هنا المهام التي أكملتها',
                )
              : ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (ctx, i) {
                    final d = docs[i].data() as Map<String, dynamic>;
                    final ts = d['completedAt'] as Timestamp?;
                    return GlassCard(
                      child: Row(children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: NC.success.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.assignment_turned_in_outlined,
                              color: NC.success, size: 20),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(d['patientName'] as String? ?? 'مريض',
                                  style: NC.label(14)),
                              if (d['address'] != null &&
                                  (d['address'] as String).isNotEmpty)
                                Text(d['address'] as String,
                                    style: NC.body(11),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                              if (ts != null)
                                Text(
                                  DateFormat('dd/MM/yyyy – HH:mm', 'ar')
                                      .format(ts.toDate()),
                                  style: NC.body(10, color: NC.textLow),
                                ),
                            ],
                          ),
                        ),
                        StatusBadge(d['status'] as String? ?? 'completed'),
                      ]),
                    );
                  },
                ),
        );
      },
    );
  }
}
