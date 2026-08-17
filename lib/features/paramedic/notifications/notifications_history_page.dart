import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/shared/widgets/app_widgets.dart';

class NotificationsHistoryPage extends StatelessWidget {
  final bool showHistory;
  const NotificationsHistoryPage({super.key, required this.showHistory});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        title: Text(showHistory ? 'سجل المهام' : 'الإشعارات'),
      ),
      body: AppEmptyState(
        icon: showHistory ? Icons.history_rounded : Icons.notifications_none_rounded,
        title: showHistory ? 'لا يوجد سجل للمهام' : 'لا توجد إشعارات حالياً',
        subtitle: showHistory ? 'سيظهر هنا تاريخ المهام التي قمت بإنجازها' : 'ستصلك هنا إشعارات بالبلاغات الجديدة الموجهة إليك',
      ),
    );
  }
}
