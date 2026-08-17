import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/shared/widgets/app_widgets.dart';
import '../../../core/route/app_routes.dart';
import '../../auth/domain/entities/app_user.dart';
import '../../auth/presentation/cubit/auth_cubit.dart';

class ParamedicHomePage extends StatefulWidget {
  const ParamedicHomePage({super.key});
  @override
  State<ParamedicHomePage> createState() => _ParamedicHomePageState();
}

class _ParamedicHomePageState extends State<ParamedicHomePage> {
  int _tab = 0;
  StreamSubscription? _sub1, _sub2;
  List<Map<String, dynamic>> _assigned = [];
  List<Map<String, dynamic>> _emergency = [];
  bool _isLoading = true;
  int _unreadNotifications = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startListening());
  }

  void _startListening() {
    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthAuthenticated) return;
    final user = authState.user;
    final fs = FirebaseFirestore.instance;

    _sub1 = fs
        .collection(AppConstants.reportsCollection)
        .where('assignedParamedicId', isEqualTo: user.id)
        .where('status', whereIn: [
          AppConstants.statusAssigned,
          AppConstants.statusInProgress,
          AppConstants.statusArrived,
        ])
        .snapshots()
        .listen((s) {
      if (mounted) {
        setState(() {
          _assigned = s.docs.map((d) {
            final data = Map<String, dynamic>.from(d.data());
            data['_id'] = d.id;
            data['_col'] = 'reports';
            return data;
          }).toList();
          _isLoading = false;
        });
      }
    });

    _sub2 = fs
        .collection(AppConstants.emergencyReportsCollection)
        .where('assignedParamedicId', isEqualTo: user.id)
        .where('status', whereIn: [
          AppConstants.statusAssigned,
          AppConstants.statusInProgress,
        ])
        .snapshots()
        .listen((s) {
      if (mounted) {
        setState(() {
          _emergency = s.docs.map((d) {
            final data = Map<String, dynamic>.from(d.data());
            data['_id'] = d.id;
            data['_col'] = 'emergency_report';
            return data;
          }).toList();
          _isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _sub1?.cancel();
    _sub2?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final authState = context.watch<AuthCubit>().state;
    if (authState is! AuthAuthenticated) return const AppLoader();
    final user = authState.user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        automaticallyImplyLeading: false,
        title: Text('مرحباً، ${user.firstName ?? ''}'),
        actions: [
          IconButton(
            icon: Badge(
              label: Text('$_unreadNotifications'),
              isLabelVisible: _unreadNotifications > 0,
              child: const Icon(Icons.notifications_outlined),
            ),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.paramedicNotifications),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (v) {
              if (v == 'history') {
                Navigator.pushNamed(context, AppRoutes.paramedicHistory);
              } else if (v == 'logout') {
                _confirmLogout(context);
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'history', child: Text('سجل المهام')),
              const PopupMenuItem(value: 'logout', child: Text('تسجيل الخروج', style: TextStyle(color: AppColors.criticalRed))),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildHeader(user),
          Expanded(
            child: _isLoading
                ? const AppLoader()
                : Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Row(
                          children: [
                            _buildStatCard('طوارئ', _emergency.length, AppColors.criticalRed, Icons.emergency_rounded),
                            const SizedBox(width: AppSpacing.md),
                            _buildStatCard('بلاغات', _assigned.length, AppColors.primaryBlue, Icons.assignment_rounded),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                        child: SegmentedButton<int>(
                          segments: const [
                            ButtonSegment(value: 0, label: Text('طوارئ')),
                            ButtonSegment(value: 1, label: Text('بلاغات')),
                          ],
                          selected: {_tab},
                          onSelectionChanged: (set) => setState(() => _tab = set.first),
                          showSelectedIcon: false,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Expanded(
                        child: _buildList(),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(AppUser user) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: const BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(AppRadius.xl)),
      ),
      child: AppCard(
        color: AppColors.white.withOpacity(0.1),
        border: BorderSide.none,
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: user.isAvailable ? AppColors.success : AppColors.textMuted,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('حالة التوفر', style: AppTextStyles.titleMedium.copyWith(color: AppColors.white)),
                  Text(
                    user.isAvailable ? 'متاح لاستقبال البلاغات' : 'غير متاح حالياً',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.white.withOpacity(0.7)),
                  ),
                ],
              ),
            ),
            Switch(
              value: user.isAvailable,
              onChanged: (val) => _toggleAvailability(val, user.id),
              activeColor: AppColors.success,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, int count, Color color, IconData icon) {
    return Expanded(
      child: AppCard(
        color: color.withOpacity(0.05),
        border: BorderSide(color: color.withOpacity(0.2)),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: AppSpacing.sm),
            Text('$count', style: AppTextStyles.displaySmall.copyWith(color: color)),
            Text(label, style: AppTextStyles.bodySmall),
          ],
        ),
      ),
    );
  }

  Widget _buildList() {
    final list = _tab == 0 ? _emergency : _assigned;
    if (list.isEmpty) {
      return AppEmptyState(
        icon: _tab == 0 ? Icons.emergency_outlined : Icons.assignment_turned_in_outlined,
        title: _tab == 0 ? 'لا توجد بلاغات طوارئ' : 'لا توجد بلاغات معينة',
        subtitle: 'سيظهر هنا أي بلاغ يتم تكليفك به',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (ctx, i) => _ReportCard(
        report: list[i],
        onTap: () => Navigator.pushNamed(
          context,
          AppRoutes.paramedicReportDetails,
          arguments: {
            'reportId': list[i]['_id'],
            'reportType': list[i]['_col'],
          },
        ),
      ),
    );
  }

  Future<void> _toggleAvailability(bool val, String uid) async {
    try {
      await FirebaseFirestore.instance
          .collection(AppConstants.paramedicCollection)
          .doc(uid)
          .update({'isAvailable': val});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('فشل التحديث: $e')));
    }
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل أنت متأكد من رغبتك في الخروج؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
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

class _ReportCard extends StatelessWidget {
  final Map<String, dynamic> report;
  final VoidCallback onTap;
  const _ReportCard({required this.report, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isEmergency = report['_col'] == 'emergency_report';
    final status = report['status'] as String? ?? 'pending';
    final patientName = report['patientName'] as String? ?? 'مريض';
    final address = report['address'] as String? ?? '';

    return AppCard(
      onTap: onTap,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: (isEmergency ? AppColors.criticalRed : AppColors.primaryBlue).withOpacity(0.1),
                  borderRadius: AppRadius.radiusMd,
                ),
                child: Icon(
                  isEmergency ? Icons.emergency_rounded : Icons.assignment_rounded,
                  color: isEmergency ? AppColors.criticalRed : AppColors.primaryBlue,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(patientName, style: AppTextStyles.titleLarge),
                    Text(address.isEmpty ? 'الموقع غير محدد' : address,
                        style: AppTextStyles.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              AppStatusBadge(status: status),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const Divider(),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(child: AppButton(label: 'التفاصيل', isPrimary: false, onPressed: onTap, icon: Icons.info_outline)),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppButton(
                  label: 'ملاحة',
                  onPressed: () => _navigate(report['latitude'], report['longitude']),
                  icon: Icons.navigation_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _navigate(double? lat, double? lng) async {
    if (lat == null || lng == null) return;
    final url = Uri.parse('google.navigation:q=$lat,$lng&mode=d');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      await launchUrl(Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng'));
    }
  }
}
