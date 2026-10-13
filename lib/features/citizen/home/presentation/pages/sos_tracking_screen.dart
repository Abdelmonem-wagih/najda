import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/shared/widgets/app_widgets.dart';
import '../../../../../core/l10n/generated/app_localizations.dart';
import '../../../report/data/models/incident_model.dart';

class SosTrackingScreen extends StatefulWidget {
  final String reportId;
  const SosTrackingScreen({super.key, required this.reportId});

  @override
  State<SosTrackingScreen> createState() => _SosTrackingScreenState();
}

class _SosTrackingScreenState extends State<SosTrackingScreen> with TickerProviderStateMixin {
  GoogleMapController? _mapCtrl;
  StreamSubscription? _ambulanceSub;
  
  LatLng? _ambulancePos;
  double _ambulanceHeading = 0;

  // Animation for smooth movement
  AnimationController? _animCtrl;
  Animation<double>? _anim;
  LatLng? _oldPos;
  LatLng? _targetPos;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _anim = CurvedAnimation(parent: _animCtrl!, curve: Curves.linear);
    _animCtrl!.addListener(() {
      if (_oldPos != null && _targetPos != null) {
        final lat = _oldPos!.latitude + (_targetPos!.latitude - _oldPos!.latitude) * _anim!.value;
        final lng = _oldPos!.longitude + (_targetPos!.longitude - _oldPos!.longitude) * _anim!.value;
        setState(() {
          _ambulancePos = LatLng(lat, lng);
        });
      }
    });
  }

  @override
  void dispose() {
    _mapCtrl?.dispose();
    _ambulanceSub?.cancel();
    _animCtrl?.dispose();
    super.dispose();
  }

  void _listenToAmbulance(String? ambulanceId) {
    if (ambulanceId == null || ambulanceId.isEmpty || _ambulanceSub != null) return;

    _ambulanceSub = FirebaseFirestore.instance
        .collection(AppConstants.ambulancesCollection)
        .doc(ambulanceId)
        .snapshots()
        .listen((doc) {
      if (doc.exists) {
        final d = doc.data()!;
        final lat = (d['lat'] as num?)?.toDouble();
        final lng = (d['lng'] as num?)?.toDouble();
        final heading = (d['heading'] as num?)?.toDouble() ?? 0.0;

        if (lat != null && lng != null) {
          final newPos = LatLng(lat, lng);
          if (mounted) {
            if (_ambulancePos == null) {
              setState(() {
                _ambulancePos = newPos;
                _ambulanceHeading = heading;
              });
            } else {
              _oldPos = _ambulancePos;
              _targetPos = newPos;
              setState(() => _ambulanceHeading = heading);
              _animCtrl!.forward(from: 0);
            }
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.criticalRed,
        title: Text(l10n.sosSentTitle),
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection(AppConstants.incidentsCollection)
            .doc(widget.reportId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return AppEmptyState(icon: Icons.error, title: l10n.error, subtitle: snapshot.error.toString());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const AppLoader();
          }

          final incident = IncidentModel.fromFirestore(snapshot.data!);
          
          // Start listening to ambulance if assigned
          if (incident.assignment?.ambulanceId != null) {
            _listenToAmbulance(incident.assignment!.ambulanceId);
          }

          final patientPos = LatLng(incident.location.latitude, incident.location.longitude);

          return Column(
            children: [
              // ── Map ─────────────────────────────────────────────────
              Expanded(
                flex: 2,
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: patientPos,
                    zoom: 14,
                  ),
                  onMapCreated: (c) => _mapCtrl = c,
                  markers: {
                    Marker(
                      markerId: const MarkerId('patient'),
                      position: patientPos,
                      infoWindow: const InfoWindow(title: 'موقعي'),
                      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                    ),
                    if (_ambulancePos != null)
                      Marker(
                        markerId: const MarkerId('ambulance'),
                        position: _ambulancePos!,
                        rotation: _ambulanceHeading,
                        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
                        infoWindow: const InfoWindow(title: 'سيارة الإسعاف'),
                      ),
                  },
                ),
              ),

              // ── Details ─────────────────────────────────────────────
              Expanded(
                flex: 3,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _StatusCard(incident: incident),
                      const SizedBox(height: AppSpacing.lg),
                      if (incident.assignment?.ambulanceId != null)
                        _AmbulanceCard(incident: incident),
                      const SizedBox(height: AppSpacing.lg),
                      if (incident.assignedHospital?.name != null)
                        _HospitalCard(incident: incident),
                      const SizedBox(height: AppSpacing.xl),
                      AppButton(
                        label: l10n.ok,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final IncidentModel incident;
  const _StatusCard({required this.incident});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AppCard(
      child: Column(
        children: [
          const Icon(Icons.emergency_rounded, size: 48, color: AppColors.criticalRed),
          const SizedBox(height: AppSpacing.md),
          Text(l10n.sosSentSubtitle, style: AppTextStyles.titleLarge, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(l10n.statusLabel, style: AppTextStyles.bodyMedium),
              const SizedBox(width: AppSpacing.sm),
              AppStatusBadge(status: incident.status),
            ],
          ),
        ],
      ),
    );
  }
}

class _AmbulanceCard extends StatelessWidget {
  final IncidentModel incident;
  const _AmbulanceCard({required this.incident});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AppCard(
      color: AppColors.primaryBlue.withOpacity(0.05),
      border: BorderSide(color: AppColors.primaryBlue.withOpacity(0.2)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.emergency_rounded, color: AppColors.primaryBlue),
              const SizedBox(width: AppSpacing.sm),
              Text(l10n.ambulanceAssigned, style: AppTextStyles.titleMedium),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            '${l10n.ambulanceName}: ${incident.assignment?.driverName ?? "..."}',
            style: AppTextStyles.bodyMedium,
          ),
          Text(
            '${l10n.plateNumberLabel}: ${incident.assignment?.vehicleId ?? "..."}',
            style: AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          const LinearProgressIndicator(
            backgroundColor: AppColors.border,
            valueColor: AlwaysStoppedAnimation(AppColors.primaryBlue),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text('Ambulance is en route to your location', style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }
}


class _HospitalCard extends StatelessWidget {
  final IncidentModel incident;
  const _HospitalCard({required this.incident});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: AppColors.success.withOpacity(0.05),
      border: BorderSide(color: AppColors.success.withOpacity(0.2)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.local_hospital_rounded, color: AppColors.success),
              const SizedBox(width: AppSpacing.sm),
              Text('Assigned Hospital', style: AppTextStyles.titleMedium),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            incident.assignedHospital?.name ?? '',
            style: AppTextStyles.titleLarge,
          ),
          Text(
            incident.assignedHospital?.address ?? '',
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }
}
