import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/l10n/generated/app_localizations.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../auth/presentation/cubit/auth_cubit.dart';
import '../cubit/report_cubit.dart';
import '../cubit/report_state.dart';
import '../widgets/report_step_type.dart';
import '../widgets/report_step_details.dart';
import '../widgets/report_step_photo.dart';
import '../widgets/report_success_dialog.dart';

class ReportPage extends StatelessWidget {
  const ReportPage({super.key});

  void _showSuccess(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const ReportSuccessDialog(),
    );
  }

  void _showError(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: AppColors.criticalRed,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocListener<ReportCubit, ReportState>(
      listenWhen: (prev, curr) => prev.status != curr.status,
      listener: (context, state) {
        if (state.status == ReportStatus.success) {
          _showSuccess(context);
        } else if (state.status == ReportStatus.error) {
          _showError(context, state.errorMessage ?? l10n.reportError);
        }
      },
      child: BlocBuilder<ReportCubit, ReportState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: AppColors.navy,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
                onPressed: () {
                  if (state.step > 0) {
                    context.read<ReportCubit>().previousStep();
                  } else {
                    Navigator.pop(context);
                  }
                },
              ),
              title: Text(l10n.reportTitle),
            ),
            body: Column(
              children: [
                LinearProgressIndicator(
                  value: (state.step + 1) / 3,
                  backgroundColor: AppColors.border,
                  valueColor: const AlwaysStoppedAnimation(AppColors.primaryBlue),
                  minHeight: 6,
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _buildStepContent(context, state),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStepContent(BuildContext context, ReportState state) {
    final cubit = context.read<ReportCubit>();
    switch (state.step) {
      case 0:
        return ReportStepType(
          key: const ValueKey(0),
          selected: state.type,
          onSelect: (t) => cubit.setType(t),
        );
      case 1:
        return ReportStepDetails(
          key: const ValueKey(1),
          consciousness: state.consciousness,
          injuryLocation: state.injuryLocation,
          painLevel: state.painLevel,
          onConsciousness: (v) => cubit.setConsciousness(v),
          onInjury: (v) => cubit.setInjuryLocation(v),
          onPain: (v) => cubit.setPainLevel(v),
          onNext: () => cubit.nextStep(),
        );
      case 2:
        return ReportStepPhoto(
          key: const ValueKey(2),
          image: state.image,
          loading: state.status == ReportStatus.loading,
          onPickImage: () => cubit.pickImage(),
          onRemove: () => cubit.removeImage(),
          onSubmit: () {
            final authState = context.read<AuthCubit>().state;
            if (authState is AuthAuthenticated) {
              cubit.submitReport(
                user: authState.user,
              );
            }
          },
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
