import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../core/route/app_routes.dart';
import '../../../core/theme/design.dart';
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
    final user =
        (context.read<AuthCubit>().state as AuthAuthenticated).user;
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
    if (l10n == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final user =
        (context.watch<AuthCubit>().state as AuthAuthenticated).user;

    final allReports = [..._emergency, ..._assigned];
    final hasActive = allReports.isNotEmpty;

    return Scaffold(
      backgroundColor: NC.surface,
      body: CustomScrollView(
        slivers: [
          // ── App bar ────────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            floating: false,
            automaticallyImplyLeading: false,
            backgroundColor: NajdaColors.navy,
            actions: [
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined,
                        color: Colors.white),
                    onPressed: () => Navigator.pushNamed(
                        context, AppRoutes.paramedicNotifications),
                  ),
                  if (_unreadNotifications > 0)
                    Positioned(
                      right: 8, top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: NC.critical,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          _unreadNotifications > 9
                              ? '9+'
                              : '$_unreadNotifications',
                          style: const TextStyle(
                              fontFamily: 'Cairo',
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                ],
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onSelected: (v) {
                  if (v == 'history') {
                    Navigator.pushNamed(
                        context, AppRoutes.paramedicHistory);
                  } else if (v == 'logout') {
                    _confirmLogout(context, l10n);
                  }
                },
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'history',
                    child: Row(children: [
                      const Icon(Icons.history_outlined,
                          color: NC.primary, size: 18),
                      const SizedBox(width: 10),
                      Text(l10n.paramedicHistory,
                          style:
                              const TextStyle(fontFamily: 'Cairo')),
                    ]),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem(
                    value: 'logout',
                    child: Row(children: [
                      const Icon(Icons.logout_outlined,
                          color: NC.critical, size: 18),
                      const SizedBox(width: 10),
                      Text(l10n.logout,
                          style: const TextStyle(
                              fontFamily: 'Cairo',
                              color: NC.critical)),
                    ]),
                  ),
                ],
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                    gradient: NajdaColors.navyGradient),
                padding: const EdgeInsets.fromLTRB(20, 70, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'مرحباً، ${user.firstName ?? ''}',
                      style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Row(children: [
                      Container(
                        width: 8, height: 8,
                        decoration: BoxDecoration(
                          color: user.isAvailable
                              ? NajdaColors.success
                              : NajdaColors.textMuted,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        user.isAvailable ? 'متاح' : 'غير متاح',
                        style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.8)),
                      ),
                    ]),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // ── Availability toggle ──────────────────────────────
                  _AvailabilityCard(user: user),
                  const SizedBox(height: 16),

                  // ── Stats row ────────────────────────────────────────
                  Row(children: [
                    _StatChip(
                      icon: Icons.assignment_outlined,
                      label: 'بلاغات',
                      value: _assigned.length.toString(),
                      color: NC.primary,
                    ),
                    const SizedBox(width: 10),
                    _StatChip(
                      icon: Icons.emergency_outlined,
                      label: 'طوارئ',
                      value: _emergency.length.toString(),
                      color: NC.critical,
                    ),
                  ]),
                  const SizedBox(height: 20),

                  // ── Tab bar ──────────────────────────────────────────
                  _ReportsTabs(
                    selected: _tab,
                    emergencyCount: _emergency.length,
                    assignedCount: _assigned.length,
                    onChanged: (i) => setState(() => _tab = i),
                  ),
                  const SizedBox(height: 14),
                ],
              ),
            ),
          ),

          // ── Report cards ─────────────────────────────────────────────
          if (_isLoading)
            const SliverFillRemaining(
                child: NajdaLoader(message: 'جارٍ التحميل...'))
          else if ((_tab == 0 && _emergency.isEmpty) ||
              (_tab == 1 && _assigned.isEmpty))
            SliverFillRemaining(
              child: NajdaEmptyState(
                icon: Icons.assignment_turned_in_outlined,
                title: _tab == 0
                    ? l10n.noEmergencyReports
                    : l10n.noAssignedReports,
                subtitle: 'لا توجد بلاغات حالياً',
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) {
                    final list = _tab == 0 ? _emergency : _assigned;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _ReportCard(
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
                  },
                  childCount: _tab == 0
                      ? _emergency.length
                      : _assigned.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.logoutConfirm,
            style: const TextStyle(fontFamily: 'Cairo')),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel,
                  style: const TextStyle(fontFamily: 'Cairo'))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: NC.critical),
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthCubit>().signOut();
              Navigator.pushNamedAndRemoveUntil(
                  context, AppRoutes.login, (r) => false);
            },
            child: Text(l10n.yes,
                style: const TextStyle(fontFamily: 'Cairo')),
          ),
        ],
      ),
    );
  }
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _AvailabilityCard extends StatelessWidget {
  final AppUser user;
  const _AvailabilityCard({required this.user});

  Future<void> _toggle(BuildContext context) async {
    try {
      final newVal = !user.isAvailable;
      await FirebaseFirestore.instance
          .collection(AppConstants.paramedicCollection)
          .doc(user.id)
          .update({
        'isAvailable': newVal,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('فشل التحديث: $e'),
        backgroundColor: NC.critical,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return NajdaCard(
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: user.isAvailable
                  ? NC.success
                  : NajdaColors.textMuted,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('حالة التوفر',
                    style: Theme.of(context).textTheme.titleSmall),
                Text(
                  user.isAvailable
                      ? 'متاح للبلاغات الجديدة'
                      : 'غير متاح — لن تصلك بلاغات',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: NajdaColors.textSecondary),
                ),
              ],
            ),
          ),
          Switch(
            value: user.isAvailable,
            onChanged: (_) => _toggle(context),
            activeColor: NC.success,
            inactiveThumbColor: NajdaColors.textMuted,
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border:
              Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: color)),
                Text(label,
                    style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12,
                        color: NajdaColors.textSecondary)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportsTabs extends StatelessWidget {
  final int selected;
  final int emergencyCount;
  final int assignedCount;
  final ValueChanged<int> onChanged;

  const _ReportsTabs({
    required this.selected,
    required this.emergencyCount,
    required this.assignedCount,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: NajdaColors.border,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        children: [
          _Tab(
            label: 'طوارئ ($emergencyCount)',
            selected: selected == 0,
            onTap: () => onChanged(0),
            color: NC.critical,
          ),
          _Tab(
            label: 'مُعيَّنة ($assignedCount)',
            selected: selected == 1,
            onTap: () => onChanged(1),
            color: NC.primary,
          ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color color;

  const _Tab(
      {required this.label,
      required this.selected,
      required this.onTap,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? NajdaColors.cardBg : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: selected
                ? [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 6,
                        offset: const Offset(0, 2))
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13,
              fontWeight:
                  selected ? FontWeight.w700 : FontWeight.w400,
              color: selected ? color : NajdaColors.textMuted,
            ),
          ),
        ),
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
    final patientName =
        report['patientName'] as String? ?? 'مريض';
    final address = report['address'] as String? ?? '';
    final lat = (report['latitude'] as num?)?.toDouble();
    final lng = (report['longitude'] as num?)?.toDouble();

    return NajdaCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                      : Icons.assignment_outlined,
                  color: isEmergency
                      ? NC.critical
                      : NC.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(patientName,
                        style:
                            Theme.of(context).textTheme.titleMedium),
                    if (address.isNotEmpty)
                      Text(address,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                  color: NajdaColors.textSecondary)),
                  ],
                ),
              ),
              NajdaStatusBadge(status),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onTap,
                  icon: const Icon(Icons.info_outline, size: 16),
                  label: const Text('التفاصيل',
                      style: TextStyle(
                          fontFamily: 'Cairo', fontSize: 13)),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 38),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              if (lat != null && lng != null)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _navigate(lat, lng),
                    icon: const Icon(Icons.navigation_outlined,
                        size: 16),
                    label: const Text('ملاحة',
                        style: TextStyle(
                            fontFamily: 'Cairo', fontSize: 13)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: NC.success,
                      minimumSize: const Size(0, 38),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _navigate(double lat, double lng) async {
    final url = Uri.parse(
        'google.navigation:q=$lat,$lng&mode=d');
    final fallback = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      await launchUrl(fallback,
          mode: LaunchMode.externalApplication);
    }
  }
}
