import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/route/app_routes.dart';
import '../../../core/theme/design.dart';
import '../../auth/domain/entities/app_user.dart';
import '../../auth/presentation/cubit/auth_cubit.dart';

class AmbulanceHomePage extends StatefulWidget {
  const AmbulanceHomePage({super.key});
  @override
  State<AmbulanceHomePage> createState() => _AmbulanceHomePageState();
}

class _AmbulanceHomePageState extends State<AmbulanceHomePage> {
  StreamSubscription? _subReports, _subEmergency;
  List<Map<String, dynamic>> _allIncidents = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startListening());
  }

  @override
  void dispose() {
    _subReports?.cancel();
    _subEmergency?.cancel();
    super.dispose();
  }

  void _startListening() {
    _subReports?.cancel();
    _subEmergency?.cancel();

    final user = (context.read<AuthCubit>().state as AuthAuthenticated).user;
    final ambId = user.ambulanceId ?? user.id;
    final fs = FirebaseFirestore.instance;

    // Helper to merge and sort
    void _updateList() {
      if (!mounted) return;
      setState(() {
        _allIncidents.sort((a, b) {
          // 1. Sort by Urgency (Emergency first)
          final aIsE = a['_col'] == 'critical';
          final bIsE = b['_col'] == 'critical';
          if (aIsE != bIsE) return aIsE ? -1 : 1;
          
          // 2. Sort by Time (Newest first)
          final aTs = (a['createdAt'] as Timestamp?)?.millisecondsSinceEpoch ?? 0;
          final bTs = (b['createdAt'] as Timestamp?)?.millisecondsSinceEpoch ?? 0;
          return bTs.compareTo(aTs);
        });
        _loading = false;
      });
    }

    _subEmergency = fs
        .collection('criticals')
        .where('assignedAmbulanceId', isEqualTo: ambId)
        .where('status', whereNotIn: ['completed', 'cancelled', 'duplicate'])
        .snapshots()
        .listen((s) {
      _allIncidents.removeWhere((item) => item['_col'] == 'critical');
      _allIncidents.addAll(s.docs.map((d) {
        final data = Map<String, dynamic>.from(d.data());
        data['_id']  = d.id;
        data['_col'] = 'critical';
        return data;
      }));
      _updateList();
    });

    _subReports = fs
        .collection('incidents')
        .where('assignedAmbulanceId', isEqualTo: ambId)
        .where('status', whereNotIn: ['completed', 'cancelled', 'duplicate'])
        .snapshots()
        .listen((s) {
      _allIncidents.removeWhere((item) => item['_col'] == 'incident');
      _allIncidents.addAll(s.docs.map((d) {
        final data = Map<String, dynamic>.from(d.data());
        data['_id']  = d.id;
        data['_col'] = 'incident';
        return data;
      }));
      _updateList();
    });
  }

  // Toggle ONLINE/OFFLINE (driver's shift status)
  Future<void> _toggleOnline(AppUser user) async {
    final newVal = !user.isOnline;
    final docId = user.ambulanceId ?? user.id;
    try {
      await FirebaseFirestore.instance
          .collection(AppConstants.ambulancesCollection)
          .doc(docId)
          .update({
        'isOnline': newVal,
        // Operational status remains 'available' if not on mission
        if (newVal && user.currentIncidentId == null)
          'status': 'available',
        'updatedAt': FieldValue.serverTimestamp(),
      });
      _showSnack(newVal ? 'أنت الآن متصل ✓' : 'أنت الآن غير متصل',
          newVal ? NC.success : NC.textMid);
    } catch (e) {
      _showSnack('فشل التحديث: $e', NC.critical);
    }
  }

  void _showSnack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: NC.label(13, color: Colors.white)),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: const Duration(seconds: 2),
    ));
  }

  Color _availabilityColor(String s) {
    switch (s) {
      case 'available':    return NC.success;
      case 'assigned':     return NC.warning;
      case 'on_mission':   return NC.primary;
    case 'arrived':      return const Color(0xFF00C2FF);
    case 'to_hospital':  return const Color(0xFFBB86FC);
      default:             return NC.textMid;
    }
  }

  String _availabilityLabel(String s) {
    switch (s) {
      case 'available':    return '● متاح';
      case 'assigned':     return '● معيّن';
      case 'on_mission':   return '● في الطريق';
      case 'arrived':      return '● وصل';
      case 'to_hospital':  return '● للمستشفى';
      default:             return s;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = (context.watch<AuthCubit>().state as AuthAuthenticated).user;

    return Scaffold(
      backgroundColor: NC.base,
      appBar: AppBar(
        title: Text('البلاغات النشطة', style: NC.display(18)),
        centerTitle: false,
        backgroundColor: NC.surface,
        actions: [
          // Replace the single toggle Row with:
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(children: [
              // Online/Offline toggle
              GestureDetector(
                onTap: () => _toggleOnline(user),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: user.isOnline
                        ? NC.success.withOpacity(0.15)
                        : NC.critical.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: user.isOnline
                          ? NC.success.withOpacity(0.4)
                          : NC.critical.withOpacity(0.4),
                    ),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Container(
                      width: 8, height: 8,
                      decoration: BoxDecoration(
                        color: user.isOnline ? NC.success : NC.critical,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 7),
                    Text(
                      user.isOnline ? 'Online' : 'Offline',
                      style: NC.label(12,
                          color: user.isOnline ? NC.success : NC.critical),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      user.isOnline
                          ? Icons.toggle_on_rounded
                          : Icons.toggle_off_rounded,
                      color: user.isOnline ? NC.success : NC.critical,
                      size: 20,
                    ),
                  ]),
                ),
              ),
              const SizedBox(width: 8),

              // Availability status badge (system controlled)
              if (user.isOnline)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _availabilityColor(user.status).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _availabilityColor(user.status).withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    _availabilityLabel(user.status),
                    style: NC.label(11,
                        color: _availabilityColor(user.status)),
                  ),
                ),
            ]),
          ),
        ],
      ),
      body: _loading
          ? const NajdaSpinner(label: 'جارٍ تحميل البلاغات...')
          : RefreshIndicator(
              onRefresh: () async {
                _startListening();
                await Future.delayed(const Duration(milliseconds: 600));
              },
              child: _allIncidents.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.7,
                          child: const NajdaEmpty(
                            icon: Icons.assignment_turned_in_outlined,
                            title: 'لا توجد بلاغات نشطة',
                            subtitle: 'ستظهر هنا البلاغات الموجهة إليك فور ورودها',
                          ),
                        ),
                      ],
                    )
                  : ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                      itemCount: _allIncidents.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (ctx, i) => _IncidentCard(
                        data: _allIncidents[i],
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRoutes.ambulanceReportDetails,
                          arguments: {
                            'reportId': _allIncidents[i]['_id'],
                            'reportType': _allIncidents[i]['_col'],
                          },
                        ),
                      ),
                    ),
            ),
    );
  }
}

// ─── Incident card ────────────────────────────────────────────────
class _IncidentCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onTap;

  const _IncidentCard({required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isEmergency = data['_col'] == 'critical';
    final status      = data['status'] as String? ?? 'assigned';
    final name        = data['patientName'] as String? ?? 'مريض';
    final address     = data['address'] as String? ?? '';
    final shortId     = data['shortId'] as String?
        ?? ((data['_id'] as String).length > 6 
            ? (data['_id'] as String).substring(0, 6).toUpperCase()
            : (data['_id'] as String).toUpperCase());
    final ts          = data['createdAt'] as Timestamp?;
    final lat         = (data['latitude'] as num?)?.toDouble();
    final lng         = (data['longitude'] as num?)?.toDouble();

    final color = isEmergency ? NC.critical : NC.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: NC.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header with Type Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isEmergency
                        ? Icons.emergency_rounded
                        : Icons.assignment_rounded,
                    color: color,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isEmergency ? 'طوارئ حرجة' : 'بلاغ عادي',
                    style: NC.label(12, color: color, weight: FontWeight.w800),
                  ),
                  const Spacer(),
                  Text(shortId, style: NC.label(12, color: NC.textLow)),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: NC.base,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isEmergency
                          ? Icons.personal_injury_rounded
                          : Icons.car_crash_rounded,
                      color: color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Text(name,
                              style: NC.label(16,
                                  weight: FontWeight.w700)),
                          const Spacer(),
                          StatusBadge(status),
                        ]),
                        const SizedBox(height: 6),
                        if (address.isNotEmpty)
                          Row(children: [
                            const Icon(Icons.location_on_outlined,
                                size: 14, color: NC.textLow),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(address,
                                  style: NC.body(12),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                            ),
                          ]),
                        const SizedBox(height: 6),
                        if (ts != null)
                          Text(
                            DateFormat('HH:mm – dd/MM').format(ts.toDate()),
                            style: NC.body(11, color: NC.textLow),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Action buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Row(children: [
                Expanded(
                  child: _ActionBtn(
                    label: 'التفاصيل',
                    icon: Icons.info_outline_rounded,
                    color: NC.primary,
                    onTap: onTap,
                  ),
                ),
                if (lat != null && lng != null && status != 'arrived' && status != 'to_hospital') ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ActionBtn(
                      label: 'ملاحة',
                      icon: Icons.navigation_rounded,
                      color: NC.success,
                      onTap: () => _openMaps(lat, lng),
                    ),
                  ),
                ],
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openMaps(double lat, double lng) async {
    final uri = Uri.parse(
        'google.navigation:q=$lat,$lng&mode=d');
    final fallback = Uri.parse(
        'https://www.google.com/maps/dir/?api=1'
        '&destination=$lat,$lng&travelmode=driving');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      await launchUrl(fallback, mode: LaunchMode.externalApplication);
    }
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Text(label, style: NC.label(13, color: color)),
          ],
        ),
      ),
    );
  }
}
