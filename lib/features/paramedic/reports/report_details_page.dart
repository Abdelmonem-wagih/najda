import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/shared/widgets/app_widgets.dart';
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

  static const _questions = [
    ('consciousness_level', 'مستوى الوعي', ['واعٍ تماماً', 'يستجيب للصوت', 'يستجيب للألم', 'فاقد الوعي']),
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

    final doc = await FirebaseFirestore.instance.collection(collection).doc(widget.reportId).get();

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
    if (perm == LocationPermission.denied) await Geolocator.requestPermission();
    _myPos = await Geolocator.getCurrentPosition();
    _posStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 15),
    ).listen((p) {
      if (mounted) setState(() => _myPos = p);
    });
  }

  Future<void> _updateStatus(String newStatus) async {
    setState(() => _submitting = true);
    final collection = widget.reportType == 'emergency_report'
        ? AppConstants.emergencyReportsCollection
        : AppConstants.reportsCollection;

    await FirebaseFirestore.instance.collection(collection).doc(widget.reportId).update({
      'status': newStatus,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    final uid = (context.read<AuthCubit>().state as AuthAuthenticated).user.id;
    await FirebaseFirestore.instance.collection(AppConstants.paramedicCollection).doc(uid).update({
      'status': newStatus,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    if (mounted) {
      setState(() {
        _report!['status'] = newStatus;
        _submitting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تحديث الحالة بنجاح')));
    }
  }

  Future<void> _submitMedicalReport() async {
    setState(() => _submitting = true);
    final user = (context.read<AuthCubit>().state as AuthAuthenticated).user;

    await FirebaseFirestore.instance.collection(AppConstants.medicalReportsCollection).add({
      'reportId': widget.reportId,
      'reportType': widget.reportType,
      'paramedicId': user.id,
      'paramedicName': user.fullName,
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
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      await launchUrl(Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng'));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: AppLoader(message: 'تحميل التفاصيل...'));
    if (_report == null) return const Scaffold(body: AppEmptyState(icon: Icons.error, title: 'البلاغ غير موجود'));

    final status = _report!['status'] as String? ?? 'assigned';
    final lat = (_report?['latitude'] as num?)?.toDouble();
    final lng = (_report?['longitude'] as num?)?.toDouble();
    final patientName = _report!['patientName'] as String? ?? 'مريض';
    final phone = _report!['phoneNumber'] as String? ?? '';
    final address = _report!['address'] as String? ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        title: const Text('تفاصيل البلاغ'),
        actions: [
          if (phone.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.phone),
              onPressed: () => launchUrl(Uri.parse('tel:$phone')),
            ),
        ],
      ),
      body: _showMedicalForm
          ? _MedicalForm(
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
                  if (lat != null && lng != null)
                    SizedBox(
                      height: 250,
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(target: LatLng(lat, lng), zoom: 15),
                        markers: {
                          Marker(markerId: const MarkerId('patient'), position: LatLng(lat, lng)),
                          if (_myPos != null)
                            Marker(
                              markerId: const MarkerId('me'),
                              position: LatLng(_myPos!.latitude, _myPos!.longitude),
                              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
                            ),
                        },
                        onMapCreated: (c) => _mapCtrl = c,
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AppCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text('الحالة:', style: AppTextStyles.titleMedium),
                                  const SizedBox(width: AppSpacing.sm),
                                  AppStatusBadge(status: status),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.md),
                              const Divider(),
                              const SizedBox(height: AppSpacing.md),
                              _buildInfoRow('الاسم', patientName),
                              if (phone.isNotEmpty) _buildInfoRow('الهاتف', phone),
                              if (address.isNotEmpty) _buildInfoRow('الموقع', address),
                              if (_report!['type'] != null) _buildInfoRow('نوع الحادث', _report!['type']),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        _buildActionButtons(status),
                        const SizedBox(height: AppSpacing.xl),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 100, child: Text(label, style: AppTextStyles.bodySmall)),
          Expanded(child: Text(value, style: AppTextStyles.bodyMedium)),
        ],
      ),
    );
  }

  Widget _buildActionButtons(String status) {
    final isOnMission = status == AppConstants.statusAssigned || status == AppConstants.statusInProgress;
    final isArrived = status == AppConstants.paramedicArrived || status == AppConstants.statusArrived;
    final isToHospital = status == AppConstants.paramedicOnWayToHospital;

    return Column(
      children: [
        AppButton(label: 'الملاحة إلى الموقع', onPressed: _openNavigation, icon: Icons.navigation_rounded),
        const SizedBox(height: AppSpacing.md),
        if (isOnMission)
          AppButton(
            label: 'تأكيد الوصول للموقع',
            onPressed: () => _updateStatus(AppConstants.paramedicArrived),
            isLoading: _submitting,
            icon: Icons.check_circle_rounded,
          ),
        if (isArrived)
          AppButton(
            label: 'تعبئة التقرير الطبي',
            onPressed: () => setState(() => _showMedicalForm = true),
            icon: Icons.assignment_rounded,
          ),
        if (isToHospital)
          AppButton(
            label: 'إنهاء المهمة / تسليم المريض',
            onPressed: () => _updateStatus(AppConstants.paramedicAvailable),
            isLoading: _submitting,
            icon: Icons.local_hospital_rounded,
          ),
      ],
    );
  }
}

class _MedicalForm extends StatefulWidget {
  final List<(String, String, List<String>)> questions;
  final Map<String, String> answers;
  final TextEditingController notesCtrl;
  final bool submitting;
  final VoidCallback onSubmit;
  final VoidCallback onCancel;

  const _MedicalForm({
    required this.questions,
    required this.answers,
    required this.notesCtrl,
    required this.submitting,
    required this.onSubmit,
    required this.onCancel,
  });

  @override
  State<_MedicalForm> createState() => _MedicalFormState();
}

class _MedicalFormState extends State<_MedicalForm> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('التقرير الطبي الميداني', style: AppTextStyles.headlineLarge),
          const SizedBox(height: AppSpacing.md),
          ...widget.questions.map((q) {
            final (id, label, opts) = q;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: AppTextStyles.titleLarge),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.sm,
                      children: opts.map((opt) {
                        final sel = widget.answers[id] == opt;
                        return ChoiceChip(
                          label: Text(opt),
                          selected: sel,
                          onSelected: (val) => setState(() => widget.answers[id] = opt),
                          selectedColor: AppColors.primaryBlue.withOpacity(0.2),
                          labelStyle: AppTextStyles.bodyMedium.copyWith(
                            color: sel ? AppColors.primaryBlue : AppColors.textPrimary,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            );
          }),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ملاحظات إضافية', style: AppTextStyles.titleLarge),
                const SizedBox(height: AppSpacing.sm),
                TextField(
                  controller: widget.notesCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(hintText: 'اكتب أي ملاحظات أخرى هنا...'),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          AppButton(label: 'إرسال التقرير', onPressed: widget.onSubmit, isLoading: widget.submitting),
          const SizedBox(height: AppSpacing.md),
          AppButton(label: 'إلغاء', isPrimary: false, onPressed: widget.onCancel),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}
