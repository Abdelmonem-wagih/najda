import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/design.dart';
import '../../auth/presentation/cubit/auth_cubit.dart';

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

class _ReportDetailsPageState extends State<ReportDetailsPage> {
  Map<String, dynamic>? _report;
  bool _loading = true;
  GoogleMapController? _mapCtrl;
  Position? _myPos;
  StreamSubscription? _posStream;
  bool _showMedicalForm = false;
  bool _submitting = false;

  final _medAnswers = <String, String>{};
  final _notesCtrl = TextEditingController();

  // Medical questions
  static const _questions = [
    ('consciousness_level', 'مستوى الوعي', ['واعٍ تماماً', 'يستجيب للصوت', 'يستجيب للألم فقط', 'فاقد الوعي']),
    ('breathing', 'التنفس', ['طبيعي', 'سريع', 'بطيء', 'مكتوم', 'متوقف']),
    ('pulse', 'النبض', ['طبيعي', 'سريع', 'بطيء', 'غير منتظم', 'لا يوجد']),
    ('bleeding', 'النزيف', ['لا يوجد', 'خفيف', 'متوسط', 'شديد']),
    ('skin_color', 'لون الجلد', ['طبيعي', 'شاحب', 'مزرق', 'أحمر']),
    ('pupil_response', 'استجابة الحدقة', ['طبيعية', 'متوسعة', 'متقلصة', 'غير متساوية']),
  ];

  @override
  void initState() {
    super.initState();
    _loadReport();
    _startLocation();
  }

  @override
  void dispose() {
    _posStream?.cancel();
    _mapCtrl?.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadReport() async {
    final collection = widget.reportType == 'emergency_report'
        ? AppConstants.emergencyReportsCollection
        : AppConstants.reportsCollection;

    final doc = await FirebaseFirestore.instance
        .collection(collection)
        .doc(widget.reportId)
        .get();

    if (mounted && doc.exists) {
      setState(() {
        _report = Map<String, dynamic>.from(doc.data()!);
        _report!['_id'] = doc.id;
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
    }
  }

  void _startLocation() async {
    final perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      await Geolocator.requestPermission();
    }
    _myPos = await Geolocator.getCurrentPosition();
    _posStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high, distanceFilter: 15),
    ).listen((p) {
      if (mounted) setState(() => _myPos = p);
    });
  }

  Future<void> _updateStatus(String newStatus) async {
    setState(() => _submitting = true);
    final collection = widget.reportType == 'emergency_report'
        ? AppConstants.emergencyReportsCollection
        : AppConstants.reportsCollection;

    await FirebaseFirestore.instance
        .collection(collection)
        .doc(widget.reportId)
        .update({'status': newStatus, 'updatedAt': FieldValue.serverTimestamp()});

    // Also update paramedic status
    final uid =
        (context.read<AuthCubit>().state as AuthAuthenticated).user.id;
    await FirebaseFirestore.instance
        .collection(AppConstants.paramedicCollection)
        .doc(uid)
        .update({'status': newStatus, 'updatedAt': FieldValue.serverTimestamp()});

    if (mounted) {
      setState(() {
        _report!['status'] = newStatus;
        _submitting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('تم تحديث الحالة',
            style: TextStyle(fontFamily: 'Cairo')),
        backgroundColor: NC.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    }
  }

  Future<void> _submitMedicalReport() async {
    setState(() => _submitting = true);
    final user =
        (context.read<AuthCubit>().state as AuthAuthenticated).user;

    await FirebaseFirestore.instance
        .collection(AppConstants.medicalReportsCollection)
        .add({
      'reportId': widget.reportId,
      'reportType': widget.reportType,
      'paramedicId': user.id,
      'paramedicName': user.paramedicFullName,
      'ambulanceId': user.ambulanceId ?? '',
      'medicalAnswers': _medAnswers,
      'additionalNotes': _notesCtrl.text.trim(),
      'submittedAt': FieldValue.serverTimestamp(),
    });

    await _updateStatus(AppConstants.paramedicOnWayToHospital);
    if (mounted) setState(() => _showMedicalForm = false);
  }

  Future<void> _openNavigation() async {
    final lat = (_report?['latitude'] as num?)?.toDouble();
    final lng = (_report?['longitude'] as num?)?.toDouble();
    if (lat == null || lng == null) return;

    final url = Uri.parse('google.navigation:q=$lat,$lng&mode=d');
    final fallback = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      await launchUrl(fallback, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: NajdaLoader(message: 'جارٍ التحميل...'));
    }
    if (_report == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('تفاصيل البلاغ')),
        body: const NajdaEmptyState(
          icon: Icons.error_outline,
          title: 'لم يتم العثور على البلاغ',
        ),
      );
    }

    final status = _report!['status'] as String? ?? 'assigned';
    final lat = (_report?['latitude'] as num?)?.toDouble();
    final lng = (_report?['longitude'] as num?)?.toDouble();
    final patientName = _report!['patientName'] as String? ?? 'مريض';
    final phone = _report!['phoneNumber'] as String? ?? '';
    final address = _report!['address'] as String? ?? '';

    return Scaffold(
      backgroundColor: NajdaColors.surface,
      appBar: AppBar(
        title: const Text('تفاصيل البلاغ'),
        actions: [
          if (phone.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.phone_outlined),
              onPressed: () => launchUrl(Uri.parse('tel:$phone')),
            ),
        ],
      ),
      body: _showMedicalForm
          ? _MedicalFormView(
              questions: _questions,
              answers: _medAnswers,
              notesCtrl: _notesCtrl,
              submitting: _submitting,
              onSubmit: _submitMedicalReport,
              onCancel: () => setState(() => _showMedicalForm = false),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Map
                  if (lat != null && lng != null)
                    SizedBox(
                      height: 220,
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: LatLng(lat, lng),
                          zoom: 15,
                        ),
                        markers: {
                          Marker(
                            markerId: const MarkerId('patient'),
                            position: LatLng(lat, lng),
                            infoWindow: InfoWindow(title: patientName),
                            icon: BitmapDescriptor.defaultMarkerWithHue(
                                BitmapDescriptor.hueRed),
                          ),
                          if (_myPos != null)
                            Marker(
                              markerId: const MarkerId('me'),
                              position: LatLng(
                                  _myPos!.latitude, _myPos!.longitude),
                              icon: BitmapDescriptor.defaultMarkerWithHue(
                                  BitmapDescriptor.hueBlue),
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
                        // Status
                        Row(
                          children: [
                            Text('الحالة الحالية:',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall),
                            const SizedBox(width: 10),
                            NajdaStatusBadge(status),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Patient info
                        NajdaCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                const Icon(Icons.person_outlined,
                                    color: NC.primary, size: 18),
                                const SizedBox(width: 8),
                                Text('بيانات المريض',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium),
                              ]),
                              const Divider(height: 20),
                              _row(context, 'الاسم', patientName),
                              if (phone.isNotEmpty)
                                _row(context, 'الهاتف', phone),
                              if (address.isNotEmpty)
                                _row(context, 'الموقع', address),
                              if (_report!['consciousnessLevel'] != null &&
                                  (_report!['consciousnessLevel'] as String)
                                      .isNotEmpty)
                                _row(context, 'مستوى الوعي',
                                    _report!['consciousnessLevel']),
                              if (_report!['type'] != null)
                                _row(context, 'النوع', _report!['type']),
                            ],
                          ),
                        ),

                        // Medical info
                        if (_hasMedInfo()) ...[
                          const SizedBox(height: 12),
                          NajdaCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: [
                                  const Icon(
                                      Icons.medical_information_outlined,
                                      color: NC.primary,
                                      size: 18),
                                  const SizedBox(width: 8),
                                  Text('البيانات الطبية',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium),
                                ]),
                                const Divider(height: 20),
                                if ((_report!['chronicDiseases'] as List?)
                                        ?.isNotEmpty ==
                                    true)
                                  _row(
                                      context,
                                      'أمراض مزمنة',
                                      (_report!['chronicDiseases']
                                              as List)
                                          .join('، ')),
                                if ((_report!['allergies'] as List?)
                                        ?.isNotEmpty ==
                                    true)
                                  _row(
                                      context,
                                      'حساسية',
                                      (_report!['allergies'] as List)
                                          .join('، ')),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 20),

                        // Action buttons
                        _ActionButtons(
                          status: status,
                          submitting: _submitting,
                          onNavigate: _openNavigation,
                          onArrived: () =>
                              _updateStatus(AppConstants.paramedicArrived),
                          onMedicalForm: () =>
                              setState(() => _showMedicalForm = true),
                          onComplete: () =>
                              _updateStatus(AppConstants.paramedicAvailable),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  bool _hasMedInfo() {
    final c = _report!['chronicDiseases'];
    final a = _report!['allergies'];
    return (c is List && c.isNotEmpty) || (a is List && a.isNotEmpty);
  }

  Widget _row(BuildContext context, String label, String val) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: NajdaColors.textSecondary)),
          ),
          Expanded(
            child: Text(val,
                style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

// ─── Action buttons ───────────────────────────────────────────────────────────
class _ActionButtons extends StatelessWidget {
  final String status;
  final bool submitting;
  final VoidCallback onNavigate;
  final VoidCallback onArrived;
  final VoidCallback onMedicalForm;
  final VoidCallback onComplete;

  const _ActionButtons({
    required this.status,
    required this.submitting,
    required this.onNavigate,
    required this.onArrived,
    required this.onMedicalForm,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final isOnMission = status == AppConstants.paramedicOnMission ||
        status == AppConstants.statusAssigned ||
        status == AppConstants.statusInProgress;
    final isArrived = status == AppConstants.paramedicArrived ||
        status == AppConstants.statusArrived;
    final isToHospital = status == AppConstants.paramedicOnWayToHospital;

    return Column(
      children: [
        // Navigate button — always visible
        ElevatedButton.icon(
          onPressed: onNavigate,
          icon: const Icon(Icons.navigation_outlined, size: 18),
          label: const Text('فتح الملاحة',
              style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700)),
          style: ElevatedButton.styleFrom(
            backgroundColor: NC.success,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 10),

        if (isOnMission)
          ElevatedButton.icon(
            onPressed: submitting ? null : onArrived,
            icon: const Icon(Icons.check_circle_outline, size: 18),
            label: Text(
                submitting ? 'جارٍ التحديث...' : 'تحديد الوصول للمريض',
                style: const TextStyle(fontFamily: 'Cairo')),
            style: ElevatedButton.styleFrom(
              backgroundColor: NC.primary,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),

        if (isArrived)
          ElevatedButton.icon(
            onPressed: onMedicalForm,
            icon: const Icon(Icons.assignment_outlined, size: 18),
            label: const Text('إرسال التقرير الطبي',
                style: TextStyle(fontFamily: 'Cairo')),
            style: ElevatedButton.styleFrom(
              backgroundColor: NajdaColors.accent,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),

        if (isToHospital)
          ElevatedButton.icon(
            onPressed: submitting ? null : onComplete,
            icon: const Icon(Icons.local_hospital_outlined, size: 18),
            label: Text(
                submitting ? 'جارٍ التحديث...' : 'تسليم للمستشفى / إنهاء المهمة',
                style: const TextStyle(fontFamily: 'Cairo')),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
      ],
    );
  }
}

// ─── Medical Form ─────────────────────────────────────────────────────────────
class _MedicalFormView extends StatelessWidget {
  final List<(String, String, List<String>)> questions;
  final Map<String, String> answers;
  final TextEditingController notesCtrl;
  final bool submitting;
  final VoidCallback onSubmit;
  final VoidCallback onCancel;

  const _MedicalFormView({
    required this.questions,
    required this.answers,
    required this.notesCtrl,
    required this.submitting,
    required this.onSubmit,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.medical_services_outlined,
                color: NC.primary),
            const SizedBox(width: 10),
            Text('التقرير الطبي',
                style: Theme.of(context).textTheme.headlineSmall),
          ]),
          const SizedBox(height: 4),
          Text('أجب على الأسئلة التالية قبل نقل المريض',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: NajdaColors.textSecondary)),
          const SizedBox(height: 20),

          ...questions.map((q) {
            final (id, label, opts) = q;
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: NajdaCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: opts.map((opt) {
                        final sel = answers[id] == opt;
                        return ChoiceChip(
                          label: Text(opt,
                              style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 12,
                                  color: sel
                                      ? Colors.white
                                      : NajdaColors.textPrimary)),
                          selected: sel,
                          selectedColor: NC.primary,
                          backgroundColor: NC.surface,
                          onSelected: (_) {
                            answers[id] = opt;
                            // force rebuild via parent stateful
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            );
          }),

          NajdaCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ملاحظات إضافية',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 10),
                TextField(
                  controller: notesCtrl,
                  maxLines: 3,
                  style: NC.inputText(),
                  decoration: const InputDecoration(
                    hintText: 'أي ملاحظات طبية إضافية...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: submitting ? null : onSubmit,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: submitting
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor:
                            AlwaysStoppedAnimation(Colors.white)))
                : const Text('إرسال التقرير الطبي',
                    style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 16,
                        fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: onCancel,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 46),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('إلغاء',
                style: TextStyle(fontFamily: 'Cairo')),
          ),
        ],
      ),
    );
  }
}
