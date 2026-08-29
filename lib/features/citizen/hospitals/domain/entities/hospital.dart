import 'package:equatable/equatable.dart';

class Hospital extends Equatable {
  final String name;
  final String address;
  final String placeId;
  final String phone;
  final double lat;
  final double lng;
  final double distKm;
  final bool isOpen;
  final double? rating;

  const Hospital({
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

  @override
  List<Object?> get props => [
        name, address, placeId, phone, lat, lng, distKm, isOpen, rating
      ];
}
