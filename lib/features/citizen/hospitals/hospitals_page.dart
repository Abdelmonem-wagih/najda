import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../../core/theme/design.dart';

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
      // 1. Get location
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.deniedForever) {
        throw Exception('صلاحية الموقع مرفوضة. فعّلها من الإعدادات.');
      }

      _pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      // 2. Nearby Search — hospitals within 5km
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

      // 3. Build hospital list (parallel phone fetching)
      final hospitals = await Future.wait(results.map((r) async {
        final loc = r['geometry']['location'];
        final lat = (loc['lat'] as num).toDouble();
        final lng = (loc['lng'] as num).toDouble();
        final dist = Geolocator.distanceBetween(
              _pos!.latitude, _pos!.longitude, lat, lng) / 1000;

        // Fetch phone from Place Details
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
      backgroundColor: NC.base,
      appBar: AppBar(
        backgroundColor: NC.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: NC.textHigh, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('مستشفيات قريبة', style: NC.display(16)),
        actions: [
          if (!_loading)
            IconButton(
              icon: const Icon(Icons.refresh_rounded,
                  color: NC.primary, size: 22),
              onPressed: _load,
            ),
        ],
      ),
      body: _loading
          ? const NajdaSpinner(label: 'جارٍ البحث عن مستشفيات قريبة...')
          : _error != null
              ? _ErrorView(error: _error!, onRetry: _load)
              : Column(
                  children: [
                    // Location bar
                    if (_pos != null)
                      Container(
                        margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: NC.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: NC.primary.withOpacity(0.25)),
                        ),
                        child: Row(children: [
                          const Icon(Icons.my_location_rounded,
                              color: NC.primary, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            'تعرض ${_hospitals.length} مستشفى في دائرة 5 كم — مرتبة بالقرب',
                            style: NC.body(12, color: NC.textMid),
                          ),
                        ]),
                      ),
                    const SizedBox(height: 10),

                    Expanded(
                      child: _hospitals.isEmpty
                          ? const NajdaEmpty(
                              icon: Icons.local_hospital_outlined,
                              title: 'لا توجد مستشفيات قريبة',
                              subtitle: 'جرب توسيع نطاق البحث',
                            )
                          : ListView.separated(
                              padding:
                                  const EdgeInsets.fromLTRB(16, 4, 16, 100),
                              itemCount: _hospitals.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (ctx, i) =>
                                  _HospitalCard(h: _hospitals[i]),
                            ),
                    ),
                  ],
                ),
    );
  }
}

// ─── Hospital card ────────────────────────────────────────────────
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
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: NC.success.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: NC.success.withOpacity(0.3)),
                ),
                child: const Icon(Icons.local_hospital_outlined,
                    color: NC.success, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(h.name,
                        style: NC.label(14, weight: FontWeight.w700),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 3),
                    Text(h.address,
                        style: NC.body(11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Distance badge
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: NC.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${h.distKm.toStringAsFixed(1)} كم',
                      style: NC.label(11, color: NC.primary),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(children: [
                    Icon(Icons.circle,
                        size: 7,
                        color: h.isOpen ? NC.success : NC.critical),
                    const SizedBox(width: 4),
                    Text(
                      h.isOpen ? 'مفتوح' : 'مغلق',
                      style: NC.body(10,
                          color:
                              h.isOpen ? NC.success : NC.critical),
                    ),
                  ]),
                ],
              ),
            ],
          ),

          // Rating
          if (h.rating != null) ...[
            const SizedBox(height: 8),
            Row(children: [
              const Icon(Icons.star_rounded,
                  color: NC.warning, size: 14),
              const SizedBox(width: 4),
              Text(h.rating!.toStringAsFixed(1),
                  style: NC.label(12, color: NC.warning)),
            ]),
          ],

          const SizedBox(height: 14),
          const Divider(color: NC.cardBorder, height: 1),
          const SizedBox(height: 12),

          // Action buttons
          Row(children: [
            _Btn(
              icon: Icons.local_hospital_rounded,
              label: 'طوارئ',
              color: NC.critical,
              onTap: () => _call('123'),
            ),
            const SizedBox(width: 8),
            _Btn(
              icon: Icons.phone_rounded,
              label: 'اتصال',
              color: NC.primary,
              onTap: () => _call(h.phone.isNotEmpty ? h.phone : '123'),
            ),
            const SizedBox(width: 8),
            _Btn(
              icon: Icons.navigation_rounded,
              label: 'اتجاهات',
              color: NC.success,
              onTap: _maps,
            ),
          ]),
        ],
      ),
    );
  }
}

class _Btn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _Btn(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 4),
            Text(label,
                style: NC.label(11, color: color)),
          ]),
        ),
      ),
    );
  }
}

// ─── Error view ───────────────────────────────────────────────────
class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: NC.critical.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.wifi_off_rounded,
                color: NC.critical, size: 42),
          ),
          const SizedBox(height: 20),
          Text('فشل تحميل المستشفيات',
              style: NC.display(16), textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(error,
              style: NC.body(12),
              textAlign: TextAlign.center),
          const SizedBox(height: 24),
          GradientButton(
            label: 'إعادة المحاولة',
            gradient: NC.primaryGrad,
            icon: Icons.refresh_rounded,
            height: 48,
            onTap: onRetry,
          ),
        ]),
      ),
    );
  }
}
