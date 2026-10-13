import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/design.dart';
import '../../auth/presentation/cubit/auth_cubit.dart';

// Incident status (stored in incidents/criticals collection)
class _IS {
  static const pending          = 'pending';
  static const assigned         = 'assigned';
  static const onMission        = 'on_mission';    // en route to patient
  static const arrived          = 'arrived';       // at patient
  static const toHospital       = 'to_hospital';   // patient on board
  static const completed        = 'completed';
}

// Ambulance availability status (stored in ambulances collection)
class _AS {
  static const available        = 'available';
  static const assigned         = 'assigned';
  static const onMission        = 'on_mission';
  static const arrived          = 'arrived';
  static const toHospital       = 'to_hospital';
}

class ReportDetailsPage extends StatefulWidget {
  final String reportId;
  final String reportType;

  const ReportDetailsPage({
    super.key,
    required this.reportId,
    required this.reportType,
  });

  @override
  State<ReportDetailsPage> createState() => _ReportDetailsPageState();
}

class _ReportDetailsPageState extends State<ReportDetailsPage> with TickerProviderStateMixin {
  Map<String, dynamic>? _report;
  bool _loading  = true;
  bool _updating = false;
  bool _showMedForm = false;

  GoogleMapController? _mapCtrl;
  final Map<String, String> _medAnswers = {};
  final _notesCtrl = TextEditingController();

  StreamSubscription? _ambulanceSub;
  LatLng? _ambulancePos;
  double _ambulanceHeading = 0;

  // Animation for smooth movement
  AnimationController? _animCtrl;
  Animation<double>? _anim;
  LatLng? _oldPos;
  LatLng? _targetPos;

  static const _medQuestions = [
    ('consciousness', 'مستوى الوعي',
        ['واعٍ تماماً', 'يستجيب للصوت', 'يستجيب للألم فقط', 'فاقد الوعي']),
    ('breathing', 'التنفس',
        ['طبيعي', 'سريع', 'بطيء', 'صعب', 'متوقف']),
    ('pulse', 'النبض',
        ['طبيعي', 'سريع', 'بطيء', 'غير منتظم', 'لا يوجد']),
    ('bleeding', 'النزيف',
        ['لا يوجد', 'خفيف', 'متوسط', 'شديد']),
    ('pupils', 'الحدقة',
        ['طبيعية', 'متوسعة', 'متقلصة', 'غير متساوية']),
    ('skin', 'الجلد',
        ['طبيعي', 'شاحب', 'مزرق', 'رطب بارد']),
  ];

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _anim = CurvedAnimation(parent: _animCtrl!, curve: Curves.linear);
    _animCtrl!.addListener(() {
      if (_oldPos != null && _targetPos != null) {
        final lat = _oldPos!.latitude + (_targetPos!.latitude - _oldPos!.latitude) * _anim!.value;
        final lng = _oldPos!.longitude + (_targetPos!.longitude - _oldPos!.longitude) * _anim!.value;
        setState(() {
          _ambulancePos = LatLng(lat, lng);
        });
      }
    });
    _loadReport();
    _startTrackingAmbulance();
  }

  @override
  void dispose() {
    _mapCtrl?.dispose();
    _notesCtrl.dispose();
    _ambulanceSub?.cancel();
    _animCtrl?.dispose();
    super.dispose();
  }

  void _startTrackingAmbulance() {
    final user = (context.read<AuthCubit>().state as AuthAuthenticated).user;
    final ambId = user.currentAmbulanceId;
    if (ambId == null || ambId.isEmpty) return;

    _ambulanceSub = FirebaseFirestore.instance
        .collection(AppConstants.ambulancesCollection)
        .doc(ambId)
        .snapshots()
        .listen((doc) {
      if (doc.exists) {
        final d = doc.data()!;
        final lat = (d['lat'] as num?)?.toDouble();
        final lng = (d['lng'] as num?)?.toDouble();
        final heading = (d['heading'] as num?)?.toDouble() ?? 0.0;

        if (lat != null && lng != null) {
          final newPos = LatLng(lat, lng);
          if (mounted) {
            if (_ambulancePos == null) {
              setState(() {
                _ambulancePos = newPos;
                _ambulanceHeading = heading;
              });
            } else {
              _oldPos = _ambulancePos;
              _targetPos = newPos;
              setState(() => _ambulanceHeading = heading);
              _animCtrl!.forward(from: 0);
            }
          }
        }
      }
    });
  }

  // ─── Collection name ──────────────────────────────────────────
  // CRITICAL: use correct collection names
  String get _collection =>
      widget.reportType == 'critical'
          ? 'criticals'    // ← NOT 'emergency_reports'
          : 'incidents';   // ← NOT 'reports'

  // ─── Load ────────────────────────────────────────────────────
  Future<void> _loadReport() async {
    final doc = await FirebaseFirestore.instance
        .collection(_collection)
        .doc(widget.reportId)
        .get();
    if (mounted && doc.exists) {
      setState(() {
        _report = Map<String, dynamic>.from(doc.data()!);
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
    }
  }

  Future<void> _updateStatus(
    String incidentStatus,
    String ambulanceStatus, {
    Map<String, dynamic> extra = const {},
  }) async {
    setState(() => _updating = true);
    final user = (context.read<AuthCubit>().state as AuthAuthenticated).user;

    try {
      // 1. Update the incident document
      await FirebaseFirestore.instance
          .collection(_collection)
          .doc(widget.reportId)
          .update({
        'status': incidentStatus,
        'updatedAt': FieldValue.serverTimestamp(),
        ...extra,
      });

      final isComplete = incidentStatus == _IS.completed;
      final isAvail = ambulanceStatus == _AS.available;

      await FirebaseFirestore.instance
          .collection(AppConstants.ambulancesCollection)
          .doc(user.id)
          .update({
        'status': ambulanceStatus,
        // Clear assignment if becoming available
        if (isAvail) 'currentIncidentId':   null,
        if (isAvail) 'currentIncidentType': null,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // 3. Add to history if completed
      if (isComplete) {
        await FirebaseFirestore.instance.collection('ambulance_history').add({
          'ambulanceId': user.ambulanceId ?? user.id,
          'patientName': _report!['patientName'] ?? 'مريض',
          'address':     _report!['address'] ?? '',
          'incidentId':   widget.reportId,
          'incidentType': widget.reportType,
          'completedAt': FieldValue.serverTimestamp(),
          'status':      'completed',
        });
      }

      await _loadReport();
      _showSnack('تم التحديث ✓', NC.success);
    } catch (e) {
      _showSnack('فشل: $e', NC.critical);
    } finally {
      if (mounted) setState(() => _updating = false);
    }
  }

  // ─── Submit medical form ──────────────────────────────────────
  Future<void> _submitMedicalForm() async {
    setState(() => _updating = true);
    final user = (context.read<AuthCubit>().state as AuthAuthenticated).user;
    try {
      // Write medical report
      await FirebaseFirestore.instance
          .collection(AppConstants.medicalReportsCollection)
          .add({
        'reportId':    widget.reportId,
        'reportType':  widget.reportType,
        'ambulanceId': user.id,
        'driverName':  user.fullName,
        'vehicleId':   user.currentAmbulanceId ?? '',
        'medicalAnswers': _medAnswers,
        'additionalNotes': _notesCtrl.text.trim(),
        'submittedAt': FieldValue.serverTimestamp(),
      });

      // Determine hospital via AI (best effort)
      final hospitalName = await _selectHospital();

      // Update statuses
      await _updateStatus(
        _IS.toHospital,
        _AS.toHospital,
        extra: {
          'medicalReportSubmitted': true,
          if (hospitalName != null) 'suggestedHospitalName': hospitalName,
          'enRouteHospitalAt': FieldValue.serverTimestamp(),
        },
      );

      setState(() => _showMedForm = false);
    } catch (e) {
      _showSnack('فشل إرسال التقرير: $e', NC.critical);
      setState(() => _updating = false);
    }
  }

  Future<String?> _selectHospital() async {
    // Simple logic: nearest hospital to patient
    // In production: call Groq AI function
    return 'أقرب مستشفى من موقعك';
  }

  // ─── Navigate to patient ──────────────────────────────────────
  Future<void> _navigate(double lat, double lng) async {
    final uri = Uri.parse('google.navigation:q=$lat,$lng&mode=d');
    final fb  = Uri.parse(
        'https://www.google.com/maps/dir/?api=1'
        '&destination=$lat,$lng&travelmode=driving');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      await launchUrl(fb, mode: LaunchMode.externalApplication);
    }
  }

  void _showSnack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: NC.label(13, color: Colors.white)),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  // ─── Build ────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: NajdaSpinner(label: 'جارٍ التحميل...'));
    if (_report == null) {
      return Scaffold(
        backgroundColor: NC.base,
        appBar: AppBar(backgroundColor: NC.surface),
        body: const NajdaEmpty(icon: Icons.error_outline, title: 'لم يُوجد البلاغ'),
      );
    }

    final status   = _report!['status'] as String? ?? 'assigned';
    final name     = _report!['patientName'] as String? ?? 'مريض';
    final shortId  = _report!['shortId'] as String? ?? 
                     (widget.reportId.length > 6 ? widget.reportId.substring(0, 6) : widget.reportId);
    final lat      = (_report!['latitude']  as num?)?.toDouble();
    final lng      = (_report!['longitude'] as num?)?.toDouble();
    final phone    = _report!['phoneNumber'] as String? ?? '';
    final address  = _report!['address']    as String? ?? '';
    final hospital = _report!['suggestedHospitalName'] as String?;
    final isEmergency = widget.reportType == 'critical';

    return Scaffold(
      backgroundColor: NC.base,
      appBar: AppBar(
        backgroundColor: NC.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: NC.textHigh, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            Text('تفاصيل البلاغ', style: NC.display(15)),
            Text(shortId,
                style: NC.label(11, color: NC.primary)),
          ],
        ),
        actions: [
          if (phone.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.phone_rounded,
                  color: NC.success, size: 22),
              onPressed: () => launchUrl(Uri.parse('tel:$phone')),
            ),
        ],
      ),
      body: _showMedForm
          ? _MedicalFormView(
              questions: _medQuestions,
              answers: _medAnswers,
              notesCtrl: _notesCtrl,
              updating: _updating,
              onSubmit: _submitMedicalForm,
              onCancel: () => setState(() => _showMedForm = false),
            )
          : RefreshIndicator(
              onRefresh: () async {
                await _loadReport();
                await Future.delayed(const Duration(milliseconds: 500));
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                  // ── Map ─────────────────────────────────────
                  if (lat != null && lng != null)
                    SizedBox(
                      height: 200,
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: LatLng(lat, lng),
                          zoom: 15,
                        ),
                        markers: {
                          Marker(
                            markerId: const MarkerId('patient'),
                            position: LatLng(lat, lng),
                            infoWindow: InfoWindow(title: name),
                            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                          ),
                          if (_ambulancePos != null)
                            Marker(
                              markerId: const MarkerId('ambulance'),
                              position: _ambulancePos!,
                              rotation: _ambulanceHeading,
                              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
                              infoWindow: const InfoWindow(title: 'موقعي'),
                            ),
                        },
                        onMapCreated: (c) => _mapCtrl = c,
                      ),
                    ),

                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Status badge ──────────────────────
                        Row(children: [
                          Text('الحالة: ',
                              style: NC.label(14, color: NC.textMid)),
                          StatusBadge(status),
                        ]),
                        const SizedBox(height: 16),

                        // ── Patient card ──────────────────────
                        GlassCard(
                          borderColor: isEmergency
                              ? NC.critical.withOpacity(0.4)
                              : NC.primary.withOpacity(0.3),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                Icon(
                                  isEmergency
                                      ? Icons.emergency_outlined
                                      : Icons.person_outlined,
                                  color: isEmergency ? NC.critical : NC.primary,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text('بيانات المريض',
                                    style: NC.label(14,
                                        weight: FontWeight.w700)),
                              ]),
                              const Divider(color: NC.cardBorder, height: 20),
                              _InfoRow('الاسم', name),
                              _InfoRow('الهاتف', phone),
                              _InfoRow('الموقع',
                                  address.isNotEmpty ? address : '—'),
                              if ((_report!['nationalId'] as String? ?? '').isNotEmpty)
                                _InfoRow('الرقم القومي',
                                    _report!['nationalId']),
                              if ((_report!['bloodType'] as String? ?? '').isNotEmpty)
                                _InfoRow('فصيلة الدم',
                                    _report!['bloodType']),
                              if ((_report!['accidentType'] as String? ?? '').isNotEmpty)
                                _InfoRow('نوع الحادث',
                                    _report!['accidentType']),
                              if ((_report!['consciousnessLevel'] as String? ?? '').isNotEmpty)
                                _InfoRow('الوعي',
                                    _report!['consciousnessLevel']),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // ── Medical profile ───────────────────
                        if (_hasMedical())
                          GlassCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: [
                                  const Icon(
                                      Icons.medical_information_outlined,
                                      color: NC.warning, size: 18),
                                  const SizedBox(width: 8),
                                  Text('الملف الطبي',
                                      style: NC.label(14,
                                          weight: FontWeight.w700)),
                                ]),
                                const Divider(color: NC.cardBorder, height: 20),
                                if ((_report!['chronicDiseases'] as List?)?.isNotEmpty == true)
                                  _InfoRow('أمراض مزمنة',
                                      (_report!['chronicDiseases'] as List)
                                          .join('، ')),
                                if ((_report!['allergies'] as List?)?.isNotEmpty == true)
                                  _InfoRow('حساسية',
                                      (_report!['allergies'] as List)
                                          .join('، ')),
                                if ((_report!['currentMedications'] as List?)?.isNotEmpty == true)
                                  _InfoRow('أدوية',
                                      (_report!['currentMedications'] as List)
                                          .join('، ')),
                              ],
                            ),
                          ),
                        const SizedBox(height: 16),

                        // ── Hospital (if assigned) ────────────
                        if (hospital != null &&
                            status == _IS.toHospital) ...[
                          GlassCard(
                            borderColor: NC.success.withOpacity(0.4),
                            child: Row(children: [
                              const Icon(Icons.local_hospital_outlined,
                                  color: NC.success, size: 22),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text('المستشفى المقترح',
                                        style: NC.body(11,
                                            color: NC.textMid)),
                                    Text(hospital,
                                        style: NC.label(15,
                                            color: NC.success)),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                    Icons.navigation_rounded,
                                    color: NC.success),
                                onPressed: () async {
                                  // Search hospital in maps
                                  final q = Uri.encodeComponent(hospital);
                                  final uri = Uri.parse(
                                      'https://www.google.com/maps/search/$q');
                                  await launchUrl(uri,
                                      mode: LaunchMode.externalApplication);
                                },
                              ),
                            ]),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // ── Action buttons ────────────────────
                        _ActionButtons(
                          status: status,
                          lat: lat,
                          lng: lng,
                          updating: _updating,
                          onNavigate: lat != null
                              ? () => _navigate(lat, lng!)
                              : null,
                          onArrived: () => _updateStatus(
                            _IS.arrived,
                            _AS.arrived,
                            extra: {'arrivedAt': FieldValue.serverTimestamp()},
                          ),
                          onMedForm: () =>
                              setState(() => _showMedForm = true),
                          onComplete: () => _updateStatus(
                            _IS.completed,
                            _AS.available,
                            extra: {'completedAt': FieldValue.serverTimestamp()},
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  bool _hasMedical() {
    final d = _report!;
    return (d['chronicDiseases'] as List?)?.isNotEmpty == true ||
        (d['allergies'] as List?)?.isNotEmpty == true ||
        (d['currentMedications'] as List?)?.isNotEmpty == true;
  }
}

// ─── Info row ─────────────────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  final String label;
  final String? value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    if (value == null || value!.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
          width: 100,
          child: Text(label, style: NC.body(12, color: NC.textMid)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(value!, style: NC.label(13, color: NC.textHigh)),
        ),
      ]),
    );
  }
}

// ─── Action buttons (status machine) ─────────────────────────────
class _ActionButtons extends StatelessWidget {
  final String status;
  final double? lat;
  final double? lng;
  final bool updating;
  final VoidCallback? onNavigate;
  final VoidCallback onArrived;
  final VoidCallback onMedForm;
  final VoidCallback onComplete;

  const _ActionButtons({
    required this.status,
    this.lat,
    this.lng,
    required this.updating,
    this.onNavigate,
    required this.onArrived,
    required this.onMedForm,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Always show navigation button if en-route to patient
        if (onNavigate != null && (status == _IS.assigned || status == _IS.onMission))
          GradientButton(
            label: 'فتح الملاحة',
            icon: Icons.navigation_rounded,
            gradient: NC.successGrad,
            height: 50,
            onTap: onNavigate,
          ),
        if (status == _IS.assigned || status == _IS.onMission)
          const SizedBox(height: 10),

        // Status-specific buttons
        if (status == _IS.assigned || status == _IS.onMission)
          GradientButton(
            label: updating ? 'جارٍ التحديث...' : 'وصلت للمريض ✓',
            icon: Icons.check_circle_outline_rounded,
            gradient: NC.primaryGrad,
            height: 50,
            loading: updating,
            onTap: onArrived,
          ),

        if (status == _IS.arrived) ...[
          GradientButton(
            label: 'إرسال التقرير الطبي',
            icon: Icons.assignment_outlined,
            gradient: NC.accentGradient,
            height: 50,
            loading: updating,
            onTap: onMedForm,
          ),
        ],

        if (status == _IS.toHospital)
          GradientButton(
            label: updating ? 'جارٍ التحديث...' : 'وصلت المستشفى — إنهاء ✓',
            icon: Icons.local_hospital_outlined,
            gradient: NC.primaryGrad,
            height: 50,
            loading: updating,
            onTap: onComplete,
          ),
      ],
    );
  }
}

// ─── Medical form ──────────────────────────────────────────────────
class _MedicalFormView extends StatefulWidget {
  final List<(String, String, List<String>)> questions;
  final Map<String, String> answers;
  final TextEditingController notesCtrl;
  final bool updating;
  final VoidCallback onSubmit;
  final VoidCallback onCancel;

  const _MedicalFormView({
    required this.questions,
    required this.answers,
    required this.notesCtrl,
    required this.updating,
    required this.onSubmit,
    required this.onCancel,
  });

  @override
  State<_MedicalFormView> createState() => _MedicalFormViewState();
}

class _MedicalFormViewState extends State<_MedicalFormView> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.medical_services_outlined,
                color: NC.primary, size: 22),
            const SizedBox(width: 10),
            Text('التقرير الطبي الميداني', style: NC.display(16)),
          ]),
          const SizedBox(height: 4),
          Text('أجب على الأسئلة قبل النقل للمستشفى',
              style: NC.body(12, color: NC.textMid)),
          const SizedBox(height: 20),

          ...widget.questions.map((q) {
            final (id, label, opts) = q;
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: NC.label(14, weight: FontWeight.w700)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: opts.map((opt) {
                        final sel = widget.answers[id] == opt;
                        return GestureDetector(
                          onTap: () => setState(() {
                            widget.answers[id] = opt;
                          }),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: sel
                                  ? NC.primary.withOpacity(0.2)
                                  : NC.overlay,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: sel ? NC.primary : NC.cardBorder,
                              ),
                            ),
                            child: Text(
                              opt,
                              style: NC.label(13,
                                  color: sel ? NC.primary : NC.textMid),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            );
          }),

          // Notes
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ملاحظات إضافية',
                    style: NC.label(14, weight: FontWeight.w700)),
                const SizedBox(height: 10),
                TextField(
                  controller: widget.notesCtrl,
                  maxLines: 3,
                  style: NC.inputText(),
                  decoration: const InputDecoration(
                    hintText: 'أي ملاحظات طبية إضافية...',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          GradientButton(
            label: 'إرسال التقرير والتوجه للمستشفى',
            gradient: NC.primaryGrad,
            height: 52,
            loading: widget.updating,
            onTap: widget.onSubmit,
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 46),
              side: const BorderSide(color: NC.cardBorder),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: widget.onCancel,
            child: Text('إلغاء', style: NC.label(14, color: NC.textMid)),
          ),
        ],
      ),
    );
  }
}
