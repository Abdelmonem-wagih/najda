import '../../domain/entities/hospital.dart';

class HospitalModel extends Hospital {
  const HospitalModel({
    required super.name,
    required super.address,
    required super.placeId,
    required super.phone,
    required super.lat,
    required super.lng,
    required super.distKm,
    required super.isOpen,
    super.rating,
  });
}
