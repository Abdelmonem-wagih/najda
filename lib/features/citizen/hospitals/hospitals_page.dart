import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/shared/widgets/app_widgets.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import 'presentation/cubit/hospital_cubit.dart';
import 'presentation/cubit/hospital_state.dart';
import 'presentation/widgets/hospital_card.dart';
import 'data/repositories/hospital_repository_impl.dart';
import 'data/datasources/hospital_remote_datasource.dart';

class HospitalsPage extends StatelessWidget {
  const HospitalsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HospitalCubit(
        repository: HospitalRepositoryImpl(
          remoteDataSource: HospitalRemoteDataSourceImpl(),
        ),
      )..loadNearbyHospitals(),
      child: const _HospitalsView(),
    );
  }
}

class _HospitalsView extends StatelessWidget {
  const _HospitalsView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(l10n.hospitalsTitle),
        actions: [
          BlocBuilder<HospitalCubit, HospitalState>(
            builder: (context, state) {
              if (state is HospitalLoading) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.refresh_rounded),
                onPressed: () => context.read<HospitalCubit>().loadNearbyHospitals(),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<HospitalCubit, HospitalState>(
        builder: (context, state) {
          if (state is HospitalLoading) {
            return AppLoader(message: l10n.hospitalsSearching);
          }
          if (state is HospitalError) {
            return AppEmptyState(
              icon: Icons.location_off_rounded,
              title: l10n.locationAccessError,
              subtitle: state.message,
              actionLabel: l10n.retry,
              onAction: () => context.read<HospitalCubit>().loadNearbyHospitals(),
            );
          }
          if (state is HospitalLoaded) {
            final hospitals = state.hospitals;
            return Column(
              children: [
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
                        l10n.foundHospitalsNearYou(hospitals.length),
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.primaryBlue),
                      ),
                    ),
                  ]),
                ),
                Expanded(
                  child: hospitals.isEmpty
                      ? AppEmptyState(
                          icon: Icons.local_hospital_outlined,
                          title: l10n.noHospitalsFound,
                          subtitle: l10n.checkLocationOrRetry,
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.xl),
                          itemCount: hospitals.length,
                          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                          itemBuilder: (ctx, i) => HospitalCard(h: hospitals[i]),
                        ),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
