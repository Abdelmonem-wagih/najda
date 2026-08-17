import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/design.dart';
import '../../auth/presentation/cubit/auth_cubit.dart';


enum AccidentType {
  carAccident('حادث سيارة / تصادم', Icons.directions_car_outlined),
  pedestrianHit('دهس مشاة', Icons.directions_walk_outlined),
  fallFromHeight('سقوط من ارتفاع', Icons.vertical_align_bottom_outlined),
  fall('سقوط عادي', Icons.person_off_outlined),
  electricShock('صدمة كهربائية', Icons.flash_on_outlined),
  fireBurn('حريق / حروق', Icons.local_fire_department_outlined),
  suffocation('اختناق', Icons.air_outlined),
  drowning('غرق', Icons.pool_outlined),
  workInjury('إصابة عمل', Icons.engineering_outlined),
  poisoning('تسمم', Icons.warning_amber_outlined),
  assault('اعتداء / عنف', Icons.shield_outlined),
  sportInjury('إصابة رياضية', Icons.sports_outlined),
  gunshot('طلق ناري', Icons.gps_fixed_outlined),
  stabbing('طعن بآلة حادة', Icons.cut_outlined),
  medicalEmergency('حالة مرضية طارئة', Icons.monitor_heart_outlined);

  final String label;
  final IconData icon;
  const AccidentType(this.label, this.icon);
}

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  int _step = 0; // 0=type, 1=details, 2=photo
  AccidentType? _type;
  String? _consciousness;
  String? _injuryLocation;
  String? _painLevel;
  File? _image;
  bool _loading = false;

  final _consciousnessOpts = ['واعٍ تماماً', 'شبه واعٍ', 'فاقد الوعي'];
  final _injuryOpts = [
    'الرأس', 'الرقبة', 'الصدر', 'البطن',
    'الذراع', 'الساق', 'الظهر', 'متعدد', 'غير محدد',
  ];
  final _painOpts = ['خفيف', 'متوسط', 'شديد', 'لا يطاق'];

  Future<void> _pickImage() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) return;
    final picked = await ImagePicker().pickImage(
        source: ImageSource.camera, imageQuality: 70, maxWidth: 1280);
    if (picked != null && mounted) setState(() => _image = File(picked.path));
  }

  Future<void> _submit() async {
    if (_type == null) return;
    setState(() => _loading = true);
    try {
      final user = (context.read<AuthCubit>().state as AuthAuthenticated).user;
      final perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) await Geolocator.requestPermission();
      final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      String? imageUrl;
      if (_image != null) {
        final ref = FirebaseStorage.instance
            .ref('reports/${user.id}/${DateTime.now().millisecondsSinceEpoch}.jpg');
        await ref.putFile(_image!);
        imageUrl = await ref.getDownloadURL();
      }

      await FirebaseFirestore.instance.collection('reports').add({
        'patientUid': user.id,
        'phoneNumber': user.phone ?? '',
        'latitude': pos.latitude,
        'longitude': pos.longitude,
        'address': '',
        'type': _type!.name,
        'consciousnessLevel': _consciousness ?? '',
        'injuryLocation': _injuryLocation ?? '',
        'painLevel': _painLevel ?? '',
        'imageUrl': imageUrl ?? '',
        'status': 'pending',
        'medicalReportSubmitted': false,
        'createdAt': FieldValue.serverTimestamp(),
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        _showSuccess();
      }
    } catch (e) {
      if (mounted) _showError('فشل إرسال البلاغ');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: NC.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 68,
              height: 68,
              decoration: const BoxDecoration(
                  gradient: NC.successGrad, shape: BoxShape.circle),
              child: const Icon(Icons.check_rounded,
                  color: Colors.white, size: 36),
            ),
            const SizedBox(height: 18),
            Text('تم إرسال البلاغ!', style: NC.display(18)),
            const SizedBox(height: 8),
            Text('الإسعاف في الطريق.',
                style: NC.body(13), textAlign: TextAlign.center),
            const SizedBox(height: 22),
            GradientButton(
              label: 'عودة للرئيسية',
              gradient: NC.primaryGrad,
              height: 48,
              onTap: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
          ]),
        ),
      ),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: NC.body(13, color: Colors.white)),
      backgroundColor: NC.critical,
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NC.base,
      appBar: AppBar(
        backgroundColor: NC.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: NC.textHigh, size: 20),
          onPressed: () => _step > 0
              ? setState(() => _step--)
              : Navigator.pop(context),
        ),
        title: Text('إبلاغ عن حادث', style: NC.display(16)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: (_step + 1) / 3,
            backgroundColor: NC.cardBorder,
            valueColor: const AlwaysStoppedAnimation(NC.primary),
          ),
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _step == 0
            ? _StepType(
                key: const ValueKey(0),
                selected: _type,
                onSelect: (t) => setState(() {
                  _type = t;
                  _step = 1;
                }),
              )
            : _step == 1
                ? _StepDetails(
                    key: const ValueKey(1),
                    consciousness: _consciousness,
                    injuryLocation: _injuryLocation,
                    painLevel: _painLevel,
                    consciousnessOpts: _consciousnessOpts,
                    injuryOpts: _injuryOpts,
                    painOpts: _painOpts,
                    onConsciousness: (v) =>
                        setState(() => _consciousness = v),
                    onInjury: (v) =>
                        setState(() => _injuryLocation = v),
                    onPain: (v) => setState(() => _painLevel = v),
                    onNext: () => setState(() => _step = 2),
                  )
                : _StepPhoto(
                    key: const ValueKey(2),
                    image: _image,
                    loading: _loading,
                    onPickImage: _pickImage,
                    onRemove: () => setState(() => _image = null),
                    onSubmit: _submit,
                  ),
      ),
    );
  }
}

// ─── Step 1: Accident Type ────────────────────────────────────────
class _StepType extends StatelessWidget {
  final AccidentType? selected;
  final ValueChanged<AccidentType> onSelect;

  const _StepType({super.key, this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ما نوع الحادث؟', style: NC.display(20)),
              const SizedBox(height: 4),
              Text('اختر النوع الأقرب للحالة',
                  style: NC.body(13)),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.9,
            ),
            itemCount: AccidentType.values.length,
            itemBuilder: (ctx, i) {
              final t = AccidentType.values[i];
              final sel = selected == t;
              return GestureDetector(
                onTap: () => onSelect(t),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    gradient: sel ? NC.primaryGrad : null,
                    color: sel ? null : NC.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: sel
                          ? NC.primary
                          : NC.cardBorder,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(t.icon,
                          color: sel ? NC.base : NC.textMid,
                          size: 26),
                      const SizedBox(height: 8),
                      Text(
                        t.label,
                        textAlign: TextAlign.center,
                        style: NC.body(10,
                            color: sel ? NC.base : NC.textMid),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─── Step 2: Medical Details ───────────────────────────────────────
class _StepDetails extends StatelessWidget {
  final String? consciousness;
  final String? injuryLocation;
  final String? painLevel;
  final List<String> consciousnessOpts;
  final List<String> injuryOpts;
  final List<String> painOpts;
  final ValueChanged<String?> onConsciousness;
  final ValueChanged<String?> onInjury;
  final ValueChanged<String?> onPain;
  final VoidCallback onNext;

  const _StepDetails({
    super.key,
    this.consciousness,
    this.injuryLocation,
    this.painLevel,
    required this.consciousnessOpts,
    required this.injuryOpts,
    required this.painOpts,
    required this.onConsciousness,
    required this.onInjury,
    required this.onPain,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('تفاصيل الحالة', style: NC.display(20)),
          const SizedBox(height: 4),
          Text('هذه المعلومات تساعد المسعف', style: NC.body(13)),
          const SizedBox(height: 24),

          _chipGroup('مستوى الوعي *', consciousnessOpts, consciousness,
              onConsciousness, NC.critical),
          const SizedBox(height: 20),

          _chipGroup('موضع الإصابة', injuryOpts, injuryLocation,
              onInjury, NC.primary),
          const SizedBox(height: 20),

          _chipGroup('شدة الألم', painOpts, painLevel, onPain, NC.warning),
          const SizedBox(height: 32),

          GradientButton(
            label: 'التالي — إضافة صورة',
            gradient: NC.primaryGrad,
            icon: Icons.arrow_forward_ios_rounded,
            onTap: onNext,
          ),
        ],
      ),
    );
  }

  Widget _chipGroup(
    String title,
    List<String> opts,
    String? selected,
    ValueChanged<String?> onChange,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: NC.label(14)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: opts.map((o) {
            final sel = selected == o;
            return GestureDetector(
              onTap: () => onChange(sel ? null : o),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: sel ? color.withOpacity(0.2) : NC.card,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: sel ? color : NC.cardBorder),
                ),
                child: Text(o,
                    style: NC.label(13,
                        color: sel ? color : NC.textMid,
                        weight: sel
                            ? FontWeight.w700
                            : FontWeight.w400)),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ─── Step 3: Photo + Submit ────────────────────────────────────────
class _StepPhoto extends StatelessWidget {
  final File? image;
  final bool loading;
  final VoidCallback onPickImage;
  final VoidCallback onRemove;
  final VoidCallback onSubmit;

  const _StepPhoto({
    super.key,
    this.image,
    required this.loading,
    required this.onPickImage,
    required this.onRemove,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('صورة الحادث', style: NC.display(20)),
          Text('اختيارية — تساعد في التشخيص',
              style: NC.body(13)),
          const SizedBox(height: 24),

          Expanded(
            child: image == null
                ? GestureDetector(
                    onTap: onPickImage,
                    child: Container(
                      decoration: BoxDecoration(
                        color: NC.card,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: NC.primary.withOpacity(0.3),
                            style: BorderStyle.solid),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: NC.primary.withOpacity(0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt_outlined,
                                color: NC.primary, size: 36),
                          ),
                          const SizedBox(height: 16),
                          Text('اضغط لالتقاط صورة',
                              style: NC.label(15, color: NC.primary)),
                          const SizedBox(height: 4),
                          Text('اضغط مطولاً للاختيار من المعرض',
                              style: NC.body(12)),
                        ],
                      ),
                    ),
                  )
                : Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.file(image!, fit: BoxFit.cover),
                      ),
                      Positioned(
                        top: 12,
                        left: 12,
                        child: GestureDetector(
                          onTap: onRemove,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: NC.critical,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close_rounded,
                                color: Colors.white, size: 16),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: GestureDetector(
                          onTap: onPickImage,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: NC.base.withOpacity(0.7),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt_outlined,
                                color: NC.textHigh, size: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: 20),

          GradientButton(
            label: 'إرسال البلاغ',
            gradient: NC.criticalGrad,
            icon: Icons.send_outlined,
            loading: loading,
            onTap: onSubmit,
          ),
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: loading ? null : onSubmit,
              child: Text('إرسال بدون صورة',
                  style: NC.label(13, color: NC.textMid)),
            ),
          ),
        ],
      ),
    );
  }
}
