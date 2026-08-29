import 'package:flutter/material.dart';

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
