import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/design.dart';

class TrackingPage extends StatefulWidget {
  final String reportId;
  final String reportType; // 'emergency_report' | 'report'
  final String displayId;
  final double patientLat;
  final double patientLng;

  const TrackingPage({
    super.key,
    required this.reportId,
    required this.reportType,
    required this.displayId,
    required this.patientLat,
    required this.patientLng,
  });

  @override
  State<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage>
    with TickerProviderStateMixin {

  // ── Map ──────────────────────────────────────────────────────────
  GoogleMapController? _mapCtrl;
  Set<Marker>    _markers     = {};
  Set<Polyline>  _polylines   = {};
  BitmapDescriptor? _ambulanceIcon;
  BitmapDescriptor? _patientIcon;

  // ── Position ──────────────────────────────────────────────────────
  LatLng? _ambulancePos;
  double  _bearing = 0;

  // ── Animation (smooth movement) ───────────────────────────────────
  AnimationController? _moveCtrl;
  Animation<double>?   _moveAnim;
  LatLng? _animFrom;
  LatLng? _animTo;

  // ── ETA ───────────────────────────────────────────────────────────
  int?    _etaMinutes;
  double? _distanceKm;
  Timer?  _etaTimer;

  // ── Report state ──────────────────────────────────────────────────
  String  _status          = 'assigned';
  String  _driverName      = '';
  String  _vehicleId       = '';
  StreamSubscription? _reportSub;
  StreamSubscription? _ambulanceSub;

  final String _mapsKey = dotenv.env['GOOGLE_MAPS_KEY'] ?? '';

  @override
  void initState() {
    super.initState();
    _loadIcons();
    _listenToReport();

    // ETA refresh every 30 seconds
    _etaTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (_ambulancePos != null) _fetchETA(_ambulancePos!);
    });
  }

  @override
  void dispose() {
    _reportSub?.cancel();
    _ambulanceSub?.cancel();
    _etaTimer?.cancel();
    _moveCtrl?.dispose();
    _mapCtrl?.dispose();
    super.dispose();
  }

  // ── Load custom icons ────────────────────────────────────────────
  Future<void> _loadIcons() async {
    try {
      _ambulanceIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(52, 52)),
        'assets/images/ambulance_icon.png',
      );
    } catch (_) {
      // Fallback: red circle
      _ambulanceIcon = BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueRed);
    }

    _patientIcon = BitmapDescriptor.defaultMarkerWithHue(
        BitmapDescriptor.hueAzure);

    _updateMarkers();
  }

  // ── Listen to report status ──────────────────────────────────────
  void _listenToReport() {
    // In this app, we use 'incidents' collection for both SOS and others
    // but the user's snippet suggested 'criticals' vs 'reports'.
    // I will adapt it to the project's 'incidents' collection if possible,
    // but to follow "exactly like Uber" snippet, I'll keep the logic but use 'incidents' as fallback.
    
    final col = widget.reportType == 'critical'
        ? 'criticals'
        : 'incidents';

    _reportSub = FirebaseFirestore.instance
        .collection(col)
        .doc(widget.reportId)
        .snapshots()
        .listen((snap) {
      if (!snap.exists || !mounted) return;
      final d = snap.data()!;

      final newStatus      = d['status'] as String? ?? 'assigned';
      
      // Adaptation to IncidentModel structure
      final assignmentRaw = d['assignment'];
      final Map<String, dynamic>? assignment = (assignmentRaw is Map<String, dynamic>) ? assignmentRaw : null;
      final newDriver      = assignment?['driverName'] as String? ?? '';
      final newVehicleId   = assignment?['vehicleId'] as String? ?? '';
      final ambulanceId    = assignment?['ambulanceId'] as String?;

      setState(() {
        _status        = newStatus;
        _driverName    = newDriver;
        _vehicleId     = newVehicleId;
      });

      // Start listening to ambulance GPS when assigned
      if (ambulanceId != null && ambulanceId.isNotEmpty && _ambulanceSub == null) {
        _listenToAmbulanceGPS(ambulanceId, newVehicleId);
      }
    });
  }

  // ── Listen to ambulance GPS (real-time) ──────────────────────────
  void _listenToAmbulanceGPS(String ambulanceId, String vehicleId) {
    if (ambulanceId.isEmpty) return;
    // Listen to 'ambulances' collection as updated by LocationService
    final stream = FirebaseFirestore.instance
        .collection('ambulances')
        .doc(ambulanceId)
        .snapshots();

    _ambulanceSub = stream.listen((snap) {
      if (!snap.exists || !mounted) return;
      final d = snap.data()!;

      final lat     = (d['latitude']  as num?)?.toDouble();
      final lng     = (d['longitude'] as num?)?.toDouble();
      final bearing = (d['bearing']   as num?)?.toDouble() ?? 0;

      if (lat == null || lng == null) return;

      final newPos = LatLng(lat, lng);

      if (_ambulancePos != null && _ambulancePos != newPos) {
        // Animate from old position to new position (smooth movement)
        _animateMarker(_ambulancePos!, newPos, bearing);
      } else {
        // First position — just set it
        setState(() {
          _ambulancePos = newPos;
          _bearing      = bearing;
        });
        _updateMarkers();
        _fetchETA(newPos);
        _fitMapBounds(newPos);
      }
    });
  }

  // ── CORE: Smooth marker animation (Uber effect) ───────────────────
  void _animateMarker(LatLng from, LatLng to, double bearing) {
    _moveCtrl?.dispose();

    _animFrom = from;
    _animTo   = to;

    _moveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _moveAnim = CurvedAnimation(
      parent: _moveCtrl!,
      curve: Curves.easeInOut,
    );

    _moveCtrl!.addListener(() {
      final t = _moveAnim!.value;
      // Linear interpolation between from and to
      final lat = from.latitude  + (to.latitude  - from.latitude)  * t;
      final lng = from.longitude + (to.longitude - from.longitude) * t;

      if (mounted) {
        setState(() {
          _ambulancePos = LatLng(lat, lng);
          _bearing      = bearing;
        });
        _updateMarkers();
      }
    });

    _moveCtrl!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Update route polyline
        _drawRoute(to, LatLng(widget.patientLat, widget.patientLng));
        // Fetch new ETA
        _fetchETA(to);
      }
    });

    _moveCtrl!.forward();
  }

  // ── Update map markers ────────────────────────────────────────────
  void _updateMarkers() {
    final markers = <Marker>{};

    // Patient marker (always shown)
    markers.add(Marker(
      markerId: const MarkerId('patient'),
      position: LatLng(widget.patientLat, widget.patientLng),
      icon: _patientIcon ?? BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueAzure),
      infoWindow: const InfoWindow(title: 'موقعك'),
    ));

    // Ambulance marker (animated, rotating)
    if (_ambulancePos != null) {
      markers.add(Marker(
        markerId: const MarkerId('ambulance'),
        position: _ambulancePos!,
        icon: _ambulanceIcon ?? BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueRed),
        rotation: _bearing,              // ← rotates with direction
        anchor: const Offset(0.5, 0.5), // center of icon
        flat: true,                      // flat on map (not billboarded)
        infoWindow: InfoWindow(
          title: '🚑 الإسعاف',
          snippet: _vehicleId.isNotEmpty ? 'رقم: $_vehicleId' : null,
        ),
      ));
    }

    if (mounted) setState(() => _markers = markers);
  }

  // ── Draw route polyline ───────────────────────────────────────────
  Future<void> _drawRoute(LatLng from, LatLng to) async {
    if (_mapsKey.isEmpty) return;
    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json'
        '?origin=${from.latitude},${from.longitude}'
        '&destination=${to.latitude},${to.longitude}'
        '&mode=driving'
        '&key=$_mapsKey',
      );

      final res = await http.get(url);
      if (res.statusCode != 200) return;
      final data = json.decode(res.body);

      if (data['routes']?.isEmpty ?? true) return;

      // Decode polyline
      final encoded = data['routes'][0]['overview_polyline']['points'] as String;
      final points  = _decodePolyline(encoded);

      if (mounted) {
        setState(() {
          _polylines = {
            Polyline(
              polylineId: const PolylineId('route'),
              points: points,
              color: const Color(0xFF00C2FF), // NC.primary
              width: 4,
              patterns: [
                PatternItem.dash(20),
                PatternItem.gap(10),
              ],
            ),
          };
        });
      }
    } catch (e) {
      debugPrint('[Route] Failed to draw route: $e');
    }
  }

  // ── Fetch ETA from Directions API ────────────────────────────────
  Future<void> _fetchETA(LatLng from) async {
    if (_mapsKey.isEmpty) {
      // Fallback: calculate ETA from distance (40 km/h city speed)
      final dist = _haversineKm(
        from.latitude, from.longitude,
        widget.patientLat, widget.patientLng,
      );
      if (mounted) {
        setState(() {
          _distanceKm = dist;
          _etaMinutes = (dist / 40 * 60).round();
        });
      }
      return;
    }

    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json'
        '?origin=${from.latitude},${from.longitude}'
        '&destination=${widget.patientLat},${widget.patientLng}'
        '&mode=driving'
        '&departure_time=now'
        '&key=$_mapsKey',
      );

      final res  = await http.get(url);
      final data = json.decode(res.body);

      if (data['routes']?.isEmpty ?? true) return;

      final leg = data['routes'][0]['legs'][0];

      // Duration in traffic if available
      final durationSec = (leg['duration_in_traffic']?['value']
          ?? leg['duration']['value']) as int;
      final distanceM  = leg['distance']['value'] as int;

      if (mounted) {
        setState(() {
          _etaMinutes  = (durationSec / 60).round();
          _distanceKm  = distanceM / 1000;
        });
      }
    } catch (e) {
      debugPrint('[ETA] Failed: $e');
    }
  }

  // ── Fit map to show both markers ─────────────────────────────────
  void _fitMapBounds(LatLng ambulancePos) {
    if (_mapCtrl == null) return;

    final patient   = LatLng(widget.patientLat, widget.patientLng);
    final southwest = LatLng(
      min(ambulancePos.latitude, patient.latitude) - 0.005,
      min(ambulancePos.longitude, patient.longitude) - 0.005,
    );
    final northeast = LatLng(
      max(ambulancePos.latitude, patient.latitude) + 0.005,
      max(ambulancePos.longitude, patient.longitude) + 0.005,
    );

    _mapCtrl!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(southwest: southwest, northeast: northeast),
        80, // padding
      ),
    );
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

  // ── Decode Google Maps polyline ───────────────────────────────────
  List<LatLng> _decodePolyline(String encoded) {
    final points = <LatLng>[];
    int index = 0, lat = 0, lng = 0;
    while (index < encoded.length) {
      int shift = 0, result = 0, b;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      lat += (result & 1) != 0 ? ~(result >> 1) : (result >> 1);

      shift = 0; result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      lng += (result & 1) != 0 ? ~(result >> 1) : (result >> 1);

      points.add(LatLng(lat / 1e5, lng / 1e5));
    }
    return points;
  }

  // ── Status label ─────────────────────────────────────────────────
  (String, Color) _getStatusInfo() {
    switch (_status) {
      case 'assigned':
      case 'dispatched':
      case 'en_route':
        return ('🚑 الإسعاف في الطريق إليك', const Color(0xFF00C2FF));
      case 'arrived_scene':
      case 'on_scene':
      case 'arrived':
        return ('✅ الإسعاف وصل إليك', const Color(0xFF00E096));
      case 'en_route_hospital':
      case 'to_hospital':
        return ('🏥 في الطريق للمستشفى', const Color(0xFFBB86FC));
      case 'completed':
      case 'resolved':
        return ('✅ اكتملت المهمة', const Color(0xFF00E096));
      default:
        return ('⏳ جارٍ التعيين...', const Color(0xFFFFB800));
    }
  }

  // ── Build ─────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final (statusLabel, statusColor) = _getStatusInfo();
    final isCompleted = _status == 'completed' || _status == 'resolved';

    return Scaffold(
      backgroundColor: NC.base,
      body: Stack(
        children: [
          // ── Full-screen map ─────────────────────────────────────
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(widget.patientLat, widget.patientLng),
              zoom: 15,
            ),
            markers:   _markers,
            polylines: _polylines,
            myLocationEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            compassEnabled: false,
            mapType: MapType.normal,
            onMapCreated: (ctrl) {
              _mapCtrl = ctrl;
              _updateMarkers();
              // Initial route if ambulance already known
              if (_ambulancePos != null) {
                _drawRoute(
                  _ambulancePos!,
                  LatLng(widget.patientLat, widget.patientLng),
                );
              }
            },
          ),

          // ── Top bar (back + report ID) ──────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: NC.base.withOpacity(0.85),
                        shape: BoxShape.circle,
                        border: Border.all(color: NC.cardBorder),
                      ),
                      child: const Icon(Icons.arrow_back_ios_rounded,
                          color: NC.textHigh, size: 18),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: NC.base.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: NC.cardBorder),
                    ),
                    child: Text('رقم البلاغ: ${widget.displayId}',
                        style: NC.label(13, color: NC.primary)),
                  ),
                ],
              ),
            ),
          ),

          // ── Center on ambulance button ──────────────────────────
          if (_ambulancePos != null)
            Positioned(
              left: 16,
              bottom: 220,
              child: GestureDetector(
                onTap: () => _fitMapBounds(_ambulancePos!),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: NC.base.withOpacity(0.9),
                    shape: BoxShape.circle,
                    border: Border.all(color: NC.cardBorder),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.center_focus_strong_rounded,
                      color: NC.primary, size: 22),
                ),
              ),
            ),

          // ── Bottom info sheet ───────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: NC.surface,
                borderRadius: BorderRadius.vertical(
                    top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 20,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag handle
                  Container(
                    width: 40, height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: NC.cardBorder,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // Status
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: statusColor.withOpacity(0.35)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (!isCompleted)
                          SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(statusColor),
                            ),
                          ),
                        if (!isCompleted) const SizedBox(width: 10),
                        Text(statusLabel,
                            style: NC.label(14, color: statusColor,
                                weight: FontWeight.w700)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ETA + Distance
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
                  if (_ambulancePos == null && !isCompleted) ...[
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

                  // Ambulance info
                  if (_driverName.isNotEmpty || _vehicleId.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    const Divider(color: NC.cardBorder, height: 1),
                    const SizedBox(height: 14),
                    Row(
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
                                    style: NC.label(14)),
                              if (_vehicleId.isNotEmpty)
                                Text('🚑 عربية: $_vehicleId',
                                    style: NC.body(12,
                                        color: NC.textMid)),
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
                                    style: NC.label(13,
                                        color: Colors.white)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
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
