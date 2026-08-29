import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/shared/widgets/app_widgets.dart';
import '../../../core/route/app_routes.dart';
import '../../auth/presentation/cubit/auth_cubit.dart';
import 'presentation/cubit/paramedic_home_cubit.dart';
import 'presentation/cubit/paramedic_home_state.dart';
import 'presentation/widgets/paramedic_header.dart';
import 'presentation/widgets/paramedic_report_card.dart';
import 'presentation/widgets/stat_card.dart';
import 'data/repositories/paramedic_home_repository_impl.dart';
import 'data/datasources/paramedic_home_remote_datasource.dart';

class ParamedicHomePage extends StatelessWidget {
  const ParamedicHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthAuthenticated) return const AppLoader();

    return BlocProvider(
      create: (context) => ParamedicHomeCubit(
        repository: ParamedicHomeRepositoryImpl(
          remoteDataSource: ParamedicHomeRemoteDataSourceImpl(),
        ),
      )..startListening(authState.user.id),
      child: const _ParamedicHomeView(),
    );
  }
}

class _ParamedicHomeView extends StatefulWidget {
  const _ParamedicHomeView();

  @override
  State<_ParamedicHomeView> createState() => _ParamedicHomeViewState();
}

class _ParamedicHomeViewState extends State<_ParamedicHomeView> {
  int _tab = 0;
  final int _unreadNotifications = 0; // Mocked for now as per original

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authState = context.watch<AuthCubit>().state as AuthAuthenticated;
    final user = authState.user;

    return BlocListener<ParamedicHomeCubit, ParamedicHomeState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.updateFailed(state.errorMessage!))));
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.navy,
          automaticallyImplyLeading: false,
          title: Text(l10n.paramedicGreeting(user.firstName ?? '')),
          actions: [
            IconButton(
              icon: Badge(
                label: Text('$_unreadNotifications'),
                isLabelVisible: _unreadNotifications > 0,
                child: const Icon(Icons.notifications_outlined),
              ),
              onPressed: () => Navigator.pushNamed(context, AppRoutes.paramedicNotifications),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (v) {
                if (v == 'history') {
                  Navigator.pushNamed(context, AppRoutes.paramedicHistory);
                } else if (v == 'settings') {
                  Navigator.pushNamed(context, AppRoutes.settings);
                } else if (v == 'logout') {
                  _confirmLogout(context);
                }
              },
              itemBuilder: (_) => [
                PopupMenuItem(value: 'history', child: Text(l10n.paramedicHistory)),
                PopupMenuItem(value: 'settings', child: Text(l10n.settings)),
                PopupMenuItem(value: 'logout', child: Text(l10n.logoutAction, style: const TextStyle(color: AppColors.criticalRed))),
              ],
            ),
          ],
        ),
        body: Column(
          children: [
            ParamedicHeader(
              user: user,
              onAvailabilityChanged: (val) =>
                  context.read<ParamedicHomeCubit>().toggleAvailability(user.id, val),
            ),
            Expanded(
              child: BlocBuilder<ParamedicHomeCubit, ParamedicHomeState>(
                builder: (context, state) {
                  if (state.isLoading && state.assignedReports.isEmpty && state.emergencyReports.isEmpty) {
                    return const AppLoader();
                  }
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Row(
                          children: [
                            StatCard(
                                label: l10n.emergency,
                                count: state.emergencyReports.length,
                                color: AppColors.criticalRed,
                                icon: Icons.emergency_rounded),
                            const SizedBox(width: AppSpacing.md),
                            StatCard(
                                label: l10n.reports,
                                count: state.assignedReports.length,
                                color: AppColors.primaryBlue,
                                icon: Icons.assignment_rounded),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                        child: SegmentedButton<int>(
                          segments: [
                            ButtonSegment(value: 0, label: Text(l10n.emergency)),
                            ButtonSegment(value: 1, label: Text(l10n.reports)),
                          ],
                          selected: {_tab},
                          onSelectionChanged: (set) => setState(() => _tab = set.first),
                          showSelectedIcon: false,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Expanded(
                        child: _buildList(state),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(ParamedicHomeState state) {
    final l10n = AppLocalizations.of(context)!;
    final list = _tab == 0 ? state.emergencyReports : state.assignedReports;
    
    if (list.isEmpty) {
      return AppEmptyState(
        icon: _tab == 0 ? Icons.emergency_outlined : Icons.assignment_turned_in_outlined,
        title: _tab == 0 ? l10n.noAssignedEmergencyReports : l10n.noAssignedReports,
        subtitle: l10n.noAssignedReportsSubtitle,
      );
    }
    
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (ctx, i) => ParamedicReportCard(
        report: list[i],
        onTap: () => Navigator.pushNamed(
          context,
          AppRoutes.paramedicReportDetails,
          arguments: {
            'reportId': list[i].id,
            'reportType': list[i].incidentType == 'emergency' ? 'emergency_report' : 'reports',
          },
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.logoutAction),
        content: Text(l10n.logoutConfirmMessage),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.criticalRed),
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthCubit>().signOut();
              Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (r) => false);
            },
            child: Text(l10n.logoutAction),
          ),
        ],
      ),
    );
  }
}
