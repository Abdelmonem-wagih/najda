import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/shared/widgets/app_widgets.dart';

class _Hospital {
  final String name;
  final String address;
  final String placeId;
  final String phone;
  final double lat;
  final double lng;
  final double distKm;
  final bool isOpen;
  final double? rating;

  const _Hospital({
    required this.name,
    required this.address,
    required this.placeId,
    required this.phone,
    required this.lat,
    required this.lng,
    required this.distKm,
    required this.isOpen,
    this.rating,
  });
}

class HospitalsPage extends StatefulWidget {
  const HospitalsPage({super.key});

  @override
  State<HospitalsPage> createState() => _HospitalsPageState();
}

class _HospitalsPageState extends State<HospitalsPage> {
  List<_Hospital> _hospitals = [];
  bool _loading = true;
  String? _error;
  Position? _pos;

  final String _apiKey = dotenv.env['GOOGLE_MAPS_KEY'] ?? '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.deniedForever) {
        throw Exception('صلاحية الموقع مرفوضة. فعّلها من الإعدادات.');
      }

      _pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      final nearbyUrl = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
        '?location=${_pos!.latitude},${_pos!.longitude}'
        '&radius=5000'
        '&type=hospital'
        '&language=ar'
        '&key=$_apiKey',
      );

      final nearbyRes = await http.get(nearbyUrl);
      if (nearbyRes.statusCode != 200) {
        throw Exception('فشل تحميل البيانات (${nearbyRes.statusCode})');
      }

      final nearbyData = json.decode(nearbyRes.body);
      if (nearbyData['status'] == 'REQUEST_DENIED') {
        throw Exception('مفتاح Google Maps غير صحيح أو Places API غير مفعّل');
      }

      final results = (nearbyData['results'] as List).take(10).toList();

      final hospitals = await Future.wait(results.map((r) async {
        final loc = r['geometry']['location'];
        final lat = (loc['lat'] as num).toDouble();
        final lng = (loc['lng'] as num).toDouble();
        final dist = Geolocator.distanceBetween(
              _pos!.latitude, _pos!.longitude, lat, lng) / 1000;

        String phone = '123';
        try {
          phone = await _getPhone(r['place_id'] as String);
        } catch (_) {}

        return _Hospital(
          name: r['name'] as String? ?? '',
          address: r['vicinity'] as String? ?? '',
          placeId: r['place_id'] as String? ?? '',
          phone: phone,
          lat: lat,
          lng: lng,
          distKm: dist,
          isOpen: (r['opening_hours']?['open_now'] as bool?) ?? true,
          rating: (r['rating'] as num?)?.toDouble(),
        );
      }));

      hospitals.sort((a, b) => a.distKm.compareTo(b.distKm));

      if (mounted) {
        setState(() {
          _hospitals = hospitals;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  Future<String> _getPhone(String placeId) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/details/json'
      '?place_id=$placeId'
      '&fields=international_phone_number,formatted_phone_number'
      '&key=$_apiKey',
    );
    final res = await http.get(url);
    if (res.statusCode != 200) return '123';
    final data = json.decode(res.body);
    return (data['result']?['international_phone_number'] as String?) ??
        (data['result']?['formatted_phone_number'] as String?) ??
        '123';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('مستشفيات قريبة'),
        actions: [
          if (!_loading)
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: _load,
            ),
        ],
      ),
      body: _loading
          ? const AppLoader(message: 'جارٍ البحث عن أقرب المستشفيات...')
          : _error != null
              ? _ErrorView(error: _error!, onRetry: _load)
              : Column(
                  children: [
                    if (_pos != null)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.all(AppSpacing.lg),
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withOpacity(0.08),
                          borderRadius: AppRadius.radiusMd,
                          border: Border.all(color: AppColors.primaryBlue.withOpacity(0.2)),
                        ),
                        child: Row(children: [
                          const Icon(Icons.my_location_rounded,
                              color: AppColors.primaryBlue, size: 16),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              'تم العثور على ${_hospitals.length} مستشفيات بالقرب منك',
                              style: AppTextStyles.bodySmall.copyWith(color: AppColors.primaryBlue),
                            ),
                          ),
                        ]),
                      ),

                    Expanded(
                      child: _hospitals.isEmpty
                          ? const AppEmptyState(
                              icon: Icons.local_hospital_outlined,
                              title: 'لم يتم العثور على مستشفيات',
                              subtitle: 'تأكد من تفعيل الموقع أو جرب لاحقاً',
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.xl),
                              itemCount: _hospitals.length,
                              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                              itemBuilder: (ctx, i) => _HospitalCard(h: _hospitals[i]),
                            ),
                    ),
                  ],
                ),
    );
  }
}

class _HospitalCard extends StatelessWidget {
  final _Hospital h;
  const _HospitalCard({required this.h});

  Future<void> _call(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _maps() async {
    final uri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1'
        '&destination=${h.lat},${h.lng}'
        '&destination_place_id=${h.placeId}'
        '&travelmode=driving');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: AppRadius.radiusMd,
                ),
                child: const Icon(Icons.local_hospital_outlined,
                    color: AppColors.success, size: 28),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(h.name, style: AppTextStyles.titleLarge),
                    Text(h.address,
                        style: AppTextStyles.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withOpacity(0.1),
                      borderRadius: AppRadius.radiusSm,
                    ),
                    child: Text(
                      '${h.distKm.toStringAsFixed(1)} كم',
                      style: AppTextStyles.labelMedium.copyWith(color: AppColors.primaryBlue, fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    h.isOpen ? 'مفتوح الآن' : 'مغلق',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: h.isOpen ? AppColors.success : AppColors.criticalRed,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),

          if (h.rating != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Row(children: [
              const Icon(Icons.star_rounded, color: AppColors.warning, size: 16),
              const SizedBox(width: AppSpacing.xs),
              Text(h.rating!.toStringAsFixed(1),
                  style: AppTextStyles.labelMedium.copyWith(color: AppColors.warning)),
            ]),
          ],

          const SizedBox(height: AppSpacing.md),
          const Divider(),
          const SizedBox(height: AppSpacing.md),

          Row(children: [
            Expanded(
              child: AppButton(
                label: 'اتصال',
                isPrimary: false,
                onPressed: () => _call(h.phone.isNotEmpty ? h.phone : '123'),
                icon: Icons.phone_rounded,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: AppButton(
                label: 'الاتجاهات',
                onPressed: _maps,
                icon: Icons.navigation_rounded,
              ),
            ),
          ]),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      icon: Icons.location_off_rounded,
      title: 'تعذر الوصول للموقع',
      subtitle: error,
      actionLabel: 'إعادة المحاولة',
      onAction: onRetry,
    );
  }
}
