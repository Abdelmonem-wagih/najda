import 'dart:math';

/// A self-contained utility to encode latitude and longitude coordinates into a Geohash.
String encodeGeohash(double latitude, double longitude, {int precision = 9}) {
  const String base32 = '0123456789bcdefghjkmnpqrstuvwxyz';
  
  double latMin = -90.0, latMax = 90.0;
  double lonMin = -180.0, lonMax = 180.0;
  
  int bit = 0;
  int ch = 0;
  String geohash = '';
  
  while (geohash.length < precision) {
    if (bit % 2 == 0) {
      double mid = (lonMin + lonMax) / 2;
      if (longitude > mid) {
        ch |= (1 << (4 - (bit % 5)));
        lonMin = mid;
      } else {
        lonMax = mid;
      }
    } else {
      double mid = (latMin + latMax) / 2;
      if (latitude > mid) {
        ch |= (1 << (4 - (bit % 5)));
        latMin = mid;
      } else {
        latMax = mid;
      }
    }
    
    bit++;
    
    if (bit % 5 == 0) {
      geohash += base32[ch];
      ch = 0;
    }
  }
  
  return geohash;
}
