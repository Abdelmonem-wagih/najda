import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/firestore_contract.dart';
import '../../../core/theme/design.dart';

class TrackingPage extends StatefulWidget {
  final String reportId;
  final String reportType; // 'critical' | 'incident' — see incidentKindFor()
  final String displayId;
  // Nullable: a notification tap doesn't carry these, and an SOS submitted
  // with no GPS fix (see SOSCubit._resolvePosition) has none either. Either
  // way, _listenToReport() below fills these in from the live document the
  // moment it loads — these are just an optional fast-path to avoid a blank
  // first frame when the caller already has them (e.g. fresh off the SOS
  // confirmation dialog).
  final double? patientLat;
  final double? patientLng;

  const TrackingPage({
    super.key,
    required this.reportId,
    required this.reportType,
    required this.displayId,
    this.patientLat,
    this.patientLng,
  });

  @override
  State<TrackingPage> createState() => _TrackingPageState();
}

// No live map here on purpose — the citizen only ever sees ETA + a status
// line, never the ambulance's exact position. Policy: showing the real-time
// location of a dispatched vehicle on a citizen-facing map is not something
// this is cleared to do.
class _TrackingPageState extends State<TrackingPage> {

  // ── ETA ───────────────────────────────────────────────────────────
  int?    _etaMinutes;
  double? _distanceKm;
  bool    _routeUnavailable = false;
  Timer?  _etaTimer;

  // ── Report state ──────────────────────────────────────────────────
  String  _status          = 'assigned';
  String  _driverName      = '';
  String  _vehicleId       = '';
  StreamSubscription? _reportSub;
  StreamSubscription? _ambulanceSub;

  // Last known ambulance position — used ONLY to compute the ETA number,
  // never rendered on a map.
  double? _ambulanceLat;
  double? _ambulanceLng;

  // Patient position — widget.patientLat/Lng is just a fast-path initial
  // value; the live document (read in _listenToReport) is authoritative
  // and fills this in whenever the widget didn't have it.
  double? _patientLat;
  double? _patientLng;

  final String _mapsKey = dotenv.env['GOOGLE_MAPS_KEY'] ?? '';

  @override
  void initState() {
    super.initState();
    _patientLat = widget.patientLat;
    _patientLng = widget.patientLng;
    _listenToReport();

    // ETA refresh every 30 seconds
    _etaTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (_ambulanceLat != null && _ambulanceLng != null) {
        _fetchETA(_ambulanceLat!, _ambulanceLng!);
      }
    });
  }

  @override
  void dispose() {
    _reportSub?.cancel();
    _ambulanceSub?.cancel();
    _etaTimer?.cancel();
    super.dispose();
  }

  // ── Listen to report status ──────────────────────────────────────
  void _listenToReport() {
    final col = incidentCollectionFor(incidentKindFor(widget.reportType));

    _reportSub = FirebaseFirestore.instance
        .collection(col)
        .doc(widget.reportId)
        .snapshots()
        .listen((snap) {
      if (!snap.exists || !mounted) return;
      final d = snap.data()!;

      // FLAT fields only — the backend never writes a nested `assignment`
      // map (it never did), so this used to read fields that were always
      // null, which meant the ETA/driver card never appeared for any real
      // assignment. See firebase/CONTRACT.md.
      final newStatus    = d[IncidentFields.status] as String? ?? IncidentStatus.pending;
      final newDriver    = d[IncidentFields.assignedDriverName] as String? ?? '';
      final newVehicleId = d[IncidentFields.assignedVehicleId] as String? ?? '';
      final ambulanceId  = d[IncidentFields.assignedAmbulanceId] as String?;
      final docLat       = (d[IncidentFields.latitude] as num?)?.toDouble();
      final docLng       = (d[IncidentFields.longitude] as num?)?.toDouble();

      setState(() {
        _status        = newStatus;
        _driverName    = newDriver;
        _vehicleId     = newVehicleId;
        _patientLat  ??= docLat;
        _patientLng  ??= docLng;
      });

      // Start listening to ambulance GPS once assigned.
      if (ambulanceId != null && ambulanceId.isNotEmpty && _ambulanceSub == null) {
        _listenToAmbulanceGPS(ambulanceId);
      }
    });
  }

  // ── Listen to ambulance GPS (real-time) — ETA input only, never shown ──
  void _listenToAmbulanceGPS(String ambulanceId) {
    if (ambulanceId.isEmpty) return;
    // Position lives in tracking/{ambulanceId} — the ambulances doc itself
    // no longer carries latitude/longitude/bearing (see CONTRACT.md).
    final stream = FirebaseFirestore.instance
        .collection(FirestoreCollections.tracking)
        .doc(ambulanceId)
        .snapshots();

    _ambulanceSub = stream.listen((snap) {
      if (!snap.exists || !mounted) return;
      final d = snap.data()!;

      final lat = (d['latitude']  as num?)?.toDouble();
      final lng = (d['longitude'] as num?)?.toDouble();
      if (lat == null || lng == null) return;

      setState(() {
        _ambulanceLat = lat;
        _ambulanceLng = lng;
      });
      _fetchETA(lat, lng);
    });
  }

  // ── Fetch ETA from Directions API ────────────────────────────────
  void _fetchETAFallback(double fromLat, double fromLng) {
    // Haversine/40km-h estimate — used when there's no Maps key AND when
    // the Directions API is reachable but returns no route (previously
    // this second case just silently did nothing, leaving a stale or
    // blank ETA with no explanation).
    final dist = _haversineKm(fromLat, fromLng, _patientLat!, _patientLng!);
    if (mounted) {
      setState(() {
        _distanceKm = dist;
        _etaMinutes = (dist / 40 * 60).round();
        _routeUnavailable = true;
      });
    }
  }

  Future<void> _fetchETA(double fromLat, double fromLng) async {
    if (_mapsKey.isEmpty) {
      _fetchETAFallback(fromLat, fromLng);
      return;
    }

    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json'
        '?origin=$fromLat,$fromLng'
        '&destination=${_patientLat!},${_patientLng!}'
        '&mode=driving'
        '&departure_time=now'
        '&key=$_mapsKey',
      );

      final res  = await http.get(url);
      final data = json.decode(res.body);

      if (data['routes']?.isEmpty ?? true) {
        _fetchETAFallback(fromLat, fromLng);
        return;
      }

      final leg = data['routes'][0]['legs'][0];

      // Duration in traffic if available
      final durationSec = (leg['duration_in_traffic']?['value']
          ?? leg['duration']['value']) as int;
      final distanceM  = leg['distance']['value'] as int;

      if (mounted) {
        setState(() {
          _etaMinutes  = (durationSec / 60).round();
          _distanceKm  = distanceM / 1000;
          _routeUnavailable = false;
        });
      }
    } catch (e) {
      debugPrint('[ETA] Failed: $e');
      _fetchETAFallback(fromLat, fromLng);
    }
  }

  // ── Haversine distance ────────────────────────────────────────────
  double _haversineKm(double lat1, double lng1, double lat2, double lng2) {
    const R = 6371.0;
    final dLat = (lat2 - lat1) * pi / 180;
    final dLng = (lng2 - lng1) * pi / 180;
    final a = sin(dLat/2) * sin(dLat/2) +
              cos(lat1*pi/180) * cos(lat2*pi/180) *
              sin(dLng/2) * sin(dLng/2);
    return R * 2 * atan2(sqrt(a), sqrt(1-a));
  }

  // ── Status label ─────────────────────────────────────────────────
  (String, Color) _getStatusInfo() {
    switch (_status) {
      case IncidentStatus.assigned:
        return ('🚑 تم تعيين سيارة إسعاف', const Color(0xFF00C2FF));
      case IncidentStatus.onMission:
        return ('🚑 الإسعاف في الطريق إليك', const Color(0xFF00C2FF));
      case IncidentStatus.arrived:
        return ('✅ الإسعاف وصل إليك', const Color(0xFF00E096));
      case IncidentStatus.toHospital:
        return ('🏥 في الطريق للمستشفى', const Color(0xFFBB86FC));
      case IncidentStatus.completed:
        return ('✅ اكتملت المهمة', const Color(0xFF00E096));
      case IncidentStatus.cancelled:
        return ('⛔ تم إلغاء البلاغ', const Color(0xFF9AA0A6));
      default:
        return ('⏳ جارٍ التعيين...', const Color(0xFFFFB800));
    }
  }

  // ── Build ─────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    // No position yet (either the SOS was sent with no GPS fix, or the
    // report document is still loading after e.g. a notification tap).
    if (_patientLat == null || _patientLng == null) {
      return const Scaffold(
        backgroundColor: NC.base,
        body: NajdaSpinner(label: 'جارٍ تحديد موقع البلاغ...'),
      );
    }

    final (statusLabel, statusColor) = _getStatusInfo();
    final isCompleted = _status == IncidentStatus.completed || _status == IncidentStatus.cancelled;
    final hasAmbulance = _ambulanceLat != null && _ambulanceLng != null;

    return Scaffold(
      backgroundColor: NC.base,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar (back + report ID) ──────────────────────────
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: NC.surface,
                        shape: BoxShape.circle,
                        border: Border.all(color: NC.cardBorder),
                      ),
                      // BackButtonIcon auto-mirrors for RTL, unlike a
                      // literal Icons.arrow_back_ios_rounded which always
                      // points the same physical direction.
                      child: const IconTheme(
                        data: IconThemeData(color: NC.textHigh, size: 18),
                        child: BackButtonIcon(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: NC.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: NC.cardBorder),
                      ),
                      child: Text('رقم البلاغ: ${widget.displayId}',
                          overflow: TextOverflow.ellipsis,
                          style: NC.label(13, color: NC.primary)),
                    ),
                  ),
                ],
              ),
            ),

            // ── Status + ETA content fills the rest of the screen ───
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Big status icon
                      Container(
                        width: 96, height: 96,
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: isCompleted
                              ? Icon(Icons.check_circle_rounded, color: statusColor, size: 48)
                              : SizedBox(
                                  width: 40, height: 40,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    valueColor: AlwaysStoppedAnimation(statusColor),
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      Text(statusLabel,
                          textAlign: TextAlign.center,
                          style: NC.label(18, color: statusColor, weight: FontWeight.w800)),
                      const SizedBox(height: 24),

                      // ETA + Distance
                      if (_routeUnavailable && (_etaMinutes != null || _distanceKm != null))
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            'تعذر تحديد المسار الدقيق — الوقت تقديري',
                            style: NC.body(12, color: NC.textMid),
                          ),
                        ),
                      if (_etaMinutes != null || _distanceKm != null)
                        Row(
                          children: [
                            if (_distanceKm != null)
                              Expanded(
                                child: _InfoTile(
                                  icon: Icons.straighten_rounded,
                                  label: 'المسافة',
                                  value: '${_distanceKm!.toStringAsFixed(1)} كم',
                                  color: NC.primary,
                                ),
                              ),
                            if (_distanceKm != null && _etaMinutes != null)
                              const SizedBox(width: 12),
                            if (_etaMinutes != null)
                              Expanded(
                                child: _InfoTile(
                                  icon: Icons.access_time_rounded,
                                  label: 'وقت الوصول',
                                  value: _etaMinutes == 0
                                      ? 'وصل!'
                                      : '~$_etaMinutes دقيقة',
                                  color: NC.warning,
                                ),
                              ),
                          ],
                        ),

                      // No ambulance yet
                      if (!hasAmbulance && !isCompleted) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 14, height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(NC.textMid),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text('جارٍ تحديد موقع الإسعاف...',
                                style: NC.body(13)),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            // ── Bottom card: driver/vehicle + call ──────────────────
            if (_driverName.isNotEmpty || _vehicleId.isNotEmpty)
              Container(
                margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: NC.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: NC.cardBorder),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: NC.primary.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.local_hospital_outlined,
                          color: NC.primary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_driverName.isNotEmpty)
                            Text(_driverName,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: NC.label(14)),
                          if (_vehicleId.isNotEmpty)
                            Text('🚑 عربية: $_vehicleId',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: NC.body(12, color: NC.textMid)),
                        ],
                      ),
                    ),
                    // Call emergency number
                    GestureDetector(
                      onTap: () => launchUrl(Uri.parse('tel:123')),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: NC.criticalGrad,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.phone_rounded,
                                color: Colors.white, size: 14),
                            const SizedBox(width: 6),
                            Text('123',
                                style: NC.label(13, color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Info tile ──────────────────────────────────────────────────────
class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: NC.body(10, color: NC.textMid)),
              Text(value,
                  style: NC.label(15, color: color,
                      weight: FontWeight.w800)),
            ],
          ),
        ],
      ),
    );
  }
}
