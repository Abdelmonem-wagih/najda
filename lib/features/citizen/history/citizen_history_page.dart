import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/shared/widgets/app_widgets.dart';
import '../../auth/presentation/cubit/auth_cubit.dart';
import 'presentation/cubit/history_cubit.dart';
import 'presentation/cubit/history_state.dart';
import 'presentation/widgets/history_card.dart';
import 'data/repositories/history_repository_impl.dart';
import 'data/datasources/history_remote_datasource.dart';

class CitizenHistoryPage extends StatelessWidget {
  const CitizenHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authState = context.read<AuthCubit>().state;

    if (authState is! AuthAuthenticated) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: Text(l10n.history)),
        body: const AppLoader(),
      );
    }

    return BlocProvider(
      create: (context) => HistoryCubit(
        repository: HistoryRepositoryImpl(
          remoteDataSource: HistoryRemoteDataSourceImpl(),
        ),
      )..loadHistory(authState.user.id),
      child: const _HistoryView(),
    );
  }
}

class _HistoryView extends StatelessWidget {
  const _HistoryView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        title: Text(l10n.history),
      ),
      body: BlocBuilder<HistoryCubit, HistoryState>(
        builder: (context, state) {
          if (state is HistoryLoading) {
            return AppLoader(message: l10n.loading);
          }
          if (state is HistoryError) {
            return AppEmptyState(
              icon: Icons.error_outline,
              title: l10n.error,
              subtitle: state.message,
              actionLabel: l10n.retry,
              onAction: () {
                final authState = context.read<AuthCubit>().state as AuthAuthenticated;
                context.read<HistoryCubit>().loadHistory(authState.user.id);
              },
            );
          }
          if (state is HistoryLoaded) {
            final reports = state.reports;
            return RefreshIndicator(
              onRefresh: () async {
                final authState =
                    context.read<AuthCubit>().state as AuthAuthenticated;
                context.read<HistoryCubit>().loadHistory(authState.user.id);
                await Future.delayed(const Duration(milliseconds: 600));
              },
              child: reports.isEmpty
                  ? ListView(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.7,
                          child: AppEmptyState(
                            icon: Icons.history_outlined,
                            title: l10n.historyEmpty,
                            subtitle: l10n.historyDescription,
                          ),
                        ),
                      ],
                    )
                  : ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      itemCount: reports.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppSpacing.md),
                      itemBuilder: (ctx, i) => HistoryCard(report: reports[i]),
                    ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
