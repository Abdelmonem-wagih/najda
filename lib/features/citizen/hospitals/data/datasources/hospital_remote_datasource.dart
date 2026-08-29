import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import '../models/hospital_model.dart';

abstract class HospitalRemoteDataSource {
  Future<List<HospitalModel>> getNearbyHospitals(double lat, double lng);
}

class HospitalRemoteDataSourceImpl implements HospitalRemoteDataSource {
  final String _apiKey = dotenv.env['GOOGLE_MAPS_KEY'] ?? '';

  @override
  Future<List<HospitalModel>> getNearbyHospitals(double lat, double lng) async {
    final nearbyUrl = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
      '?location=$lat,$lng'
      '&radius=5000'
      '&type=hospital'
      '&language=ar'
      '&key=$_apiKey',
    );

    final nearbyRes = await http.get(nearbyUrl);
    if (nearbyRes.statusCode != 200) {
      throw Exception('Failed to load data (${nearbyRes.statusCode})');
    }

    final nearbyData = json.decode(nearbyRes.body);
    if (nearbyData['status'] == 'REQUEST_DENIED') {
      throw Exception('Google Maps key is invalid or Places API not enabled');
    }

    final results = (nearbyData['results'] as List).take(10).toList();

    final hospitals = await Future.wait(results.map((r) async {
      final loc = r['geometry']['location'];
      final hLat = (loc['lat'] as num).toDouble();
      final hLng = (loc['lng'] as num).toDouble();
      final dist = Geolocator.distanceBetween(lat, lng, hLat, hLng) / 1000;

      String phone = '123';
      try {
        phone = await _getPhone(r['place_id'] as String);
      } catch (_) {}

      return HospitalModel(
        name: r['name'] as String? ?? '',
        address: r['vicinity'] as String? ?? '',
        placeId: r['place_id'] as String? ?? '',
        phone: phone,
        lat: hLat,
        lng: hLng,
        distKm: dist,
        isOpen: (r['opening_hours']?['open_now'] as bool?) ?? true,
        rating: (r['rating'] as num?)?.toDouble(),
      );
    }));

    hospitals.sort((a, b) => a.distKm.compareTo(b.distKm));
    return hospitals;
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
}
