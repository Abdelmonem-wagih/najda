import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/shared/widgets/app_widgets.dart';
import '../../../core/l10n/generated/app_localizations.dart';

class NotificationsHistoryPage extends StatelessWidget {
  final bool showHistory;
  const NotificationsHistoryPage({super.key, required this.showHistory});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        title: Text(showHistory ? l10n.paramedicHistory : l10n.notifications),
      ),
      body: AppEmptyState(
        icon: showHistory ? Icons.history_rounded : Icons.notifications_none_rounded,
        title: showHistory ? l10n.noMissionHistory : l10n.noNotificationsTitle,
        subtitle: showHistory ? l10n.missionHistorySubtitle : l10n.notificationsSubtitle,
      ),
    );
  }
}
