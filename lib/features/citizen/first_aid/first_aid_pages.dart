import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/shared/widgets/app_widgets.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import 'presentation/cubit/first_aid_cubit.dart';
import 'presentation/cubit/first_aid_state.dart';
import 'presentation/widgets/first_aid_card.dart';
import 'data/repositories/first_aid_repository_impl.dart';

class FirstAidListPage extends StatelessWidget {
  const FirstAidListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FirstAidCubit(
        repository: FirstAidRepositoryImpl(),
      )..loadFirstAidItems(),
      child: const _FirstAidListView(),
    );
  }
}

class _FirstAidListView extends StatelessWidget {
  const _FirstAidListView();

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
        title: Text(l10n.firstAid),
      ),
      body: BlocBuilder<FirstAidCubit, FirstAidState>(
        builder: (context, state) {
          if (state is FirstAidLoading) {
            return const AppLoader();
          }
          if (state is FirstAidError) {
            return AppEmptyState(
              icon: Icons.error_outline,
              title: l10n.error,
              subtitle: state.message,
              actionLabel: l10n.retry,
              onAction: () => context.read<FirstAidCubit>().loadFirstAidItems(),
            );
          }
          if (state is FirstAidLoaded) {
            final filtered = state.filteredItems;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: TextField(
                    onChanged: (v) => context.read<FirstAidCubit>().search(v),
                    decoration: InputDecoration(
                      hintText: l10n.searchFirstAidHint,
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: state.query.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                context.read<FirstAidCubit>().search('');
                                FocusScope.of(context).unfocus();
                              },
                            )
                          : null,
                    ),
                  ),
                ),
                Expanded(
                  child: filtered.isEmpty
                      ? AppEmptyState(
                          icon: Icons.search_off_rounded,
                          title: l10n.noResults,
                          subtitle: l10n.tryDifferentSearch,
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.xl),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                          itemBuilder: (ctx, i) => FirstAidCard(item: filtered[i]),
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
