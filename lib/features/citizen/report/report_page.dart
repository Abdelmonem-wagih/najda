import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/shared/widgets/app_widgets.dart';
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
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusXl),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_rounded,
                color: Colors.white, size: 38),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('تم إرسال البلاغ!', style: AppTextStyles.headlineLarge),
          const SizedBox(height: AppSpacing.sm),
          Text('الإسعاف في الطريق. ابقَ هادئاً.',
              style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: 'عودة للرئيسية',
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
          ),
        ]),
      ),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: AppColors.criticalRed,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusMd),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
          onPressed: () => _step > 0
              ? setState(() => _step--)
              : Navigator.pop(context),
        ),
        title: const Text('إبلاغ عن حادث'),
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (_step + 1) / 3,
            backgroundColor: AppColors.border,
            valueColor: const AlwaysStoppedAnimation(AppColors.primaryBlue),
            minHeight: 6,
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _buildStepContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_step) {
      case 0:
        return _StepType(
          key: const ValueKey(0),
          selected: _type,
          onSelect: (t) => setState(() {
            _type = t;
            _step = 1;
          }),
        );
      case 1:
        return _StepDetails(
          key: const ValueKey(1),
          consciousness: _consciousness,
          injuryLocation: _injuryLocation,
          painLevel: _painLevel,
          consciousnessOpts: _consciousnessOpts,
          injuryOpts: _injuryOpts,
          painOpts: _painOpts,
          onConsciousness: (v) => setState(() => _consciousness = v),
          onInjury: (v) => setState(() => _injuryLocation = v),
          onPain: (v) => setState(() => _painLevel = v),
          onNext: () => setState(() => _step = 2),
        );
      case 2:
        return _StepPhoto(
          key: const ValueKey(2),
          image: _image,
          loading: _loading,
          onPickImage: _pickImage,
          onRemove: () => setState(() => _image = null),
          onSubmit: _submit,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

class _StepType extends StatelessWidget {
  final AccidentType? selected;
  final ValueChanged<AccidentType> onSelect;

  const _StepType({super.key, this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ما نوع الحادث؟', style: AppTextStyles.headlineLarge),
              const SizedBox(height: AppSpacing.xs),
              Text('اختر التصنيف الأقرب للحالة للمساعدة في الاستجابة',
                  style: AppTextStyles.bodySmall),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: AppSpacing.md,
              crossAxisSpacing: AppSpacing.md,
              childAspectRatio: 0.9,
            ),
            itemCount: AccidentType.values.length,
            itemBuilder: (ctx, i) {
              final t = AccidentType.values[i];
              final sel = selected == t;
              return AppCard(
                onTap: () => onSelect(t),
                padding: EdgeInsets.zero,
                color: sel ? AppColors.primaryBlue : AppColors.surface,
                border: BorderSide(color: sel ? AppColors.primaryBlue : AppColors.border),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(t.icon,
                        color: sel ? AppColors.white : AppColors.primaryBlue,
                        size: 28),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      t.label,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: sel ? AppColors.white : AppColors.textPrimary,
                        fontSize: 10,
                        fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

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
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('تفاصيل الإصابة', style: AppTextStyles.headlineLarge),
          const SizedBox(height: AppSpacing.xs),
          Text('وصف حالة المصاب يساعد المسعف على الاستعداد', style: AppTextStyles.bodySmall),
          const SizedBox(height: AppSpacing.xl),

          _buildChipGroup('مستوى الوعي *', consciousnessOpts, consciousness,
              onConsciousness, AppColors.criticalRed),
          const SizedBox(height: AppSpacing.lg),

          _buildChipGroup('موضع الإصابة', injuryOpts, injuryLocation,
              onInjury, AppColors.primaryBlue),
          const SizedBox(height: AppSpacing.lg),

          _buildChipGroup('شدة الألم', painOpts, painLevel, onPain, AppColors.warning),
          const SizedBox(height: AppSpacing.xxl),

          AppButton(
            label: 'التالي — إضافة صورة',
            onPressed: onNext,
            icon: Icons.arrow_forward_ios_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildChipGroup(
    String title,
    List<String> opts,
    String? selected,
    ValueChanged<String?> onChange,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.titleLarge),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: opts.map((o) {
            final sel = selected == o;
            return ChoiceChip(
              label: Text(o),
              selected: sel,
              onSelected: (val) => onChange(val ? o : null),
              selectedColor: color.withOpacity(0.2),
              labelStyle: AppTextStyles.bodyMedium.copyWith(
                color: sel ? color : AppColors.textPrimary,
                fontWeight: sel ? FontWeight.w700 : FontWeight.w400,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.radiusXl,
                side: BorderSide(color: sel ? color : AppColors.border),
              ),
              showCheckmark: false,
            );
          }).toList(),
        ),
      ],
    );
  }
}

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
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('صورة الحالة', style: AppTextStyles.headlineLarge),
          const SizedBox(height: AppSpacing.xs),
          Text('اختياري: التقاط صورة للحادث يساعد فريق الإسعاف على فهم طبيعة الإصابة',
              style: AppTextStyles.bodySmall),
          const SizedBox(height: AppSpacing.xl),

          Expanded(
            child: AppCard(
              onTap: image == null ? onPickImage : null,
              padding: EdgeInsets.zero,
              child: image == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt_outlined,
                              color: AppColors.primaryBlue, size: 48),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text('اضغط هنا لالتقاط صورة',
                            style: AppTextStyles.labelLarge.copyWith(color: AppColors.primaryBlue)),
                      ],
                    )
                  : Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: AppRadius.radiusLg,
                          child: Image.file(image!, fit: BoxFit.cover),
                        ),
                        Positioned(
                          top: AppSpacing.sm,
                          left: AppSpacing.sm,
                          child: IconButton.filled(
                            onPressed: onRemove,
                            icon: const Icon(Icons.close, size: 20),
                            style: IconButton.styleFrom(backgroundColor: AppColors.criticalRed),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          AppButton(
            label: 'إرسال البلاغ',
            isLoading: loading,
            onPressed: onSubmit,
            icon: Icons.send_rounded,
          ),
          const SizedBox(height: AppSpacing.md),
          TextButton(
            onPressed: loading ? null : onSubmit,
            child: const Text('إرسال بدون صورة'),
          ),
        ],
      ),
    );
  }
}
