import 'package:flutter/material.dart';
import '../../../core/theme/design.dart';

class NotificationsHistoryPage extends StatelessWidget {
  final bool showHistory;
  const NotificationsHistoryPage({super.key, required this.showHistory});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NC.base,
      appBar: AppBar(
        backgroundColor: NC.surface,
        title: Text(showHistory ? 'سجل المهام' : 'الإشعارات',
            style: NC.display(16)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: NC.textHigh, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: NajdaEmpty(
          icon: showHistory
              ? Icons.history_outlined
              : Icons.notifications_outlined,
          title: showHistory ? 'لا توجد مهام' : 'لا توجد إشعارات',
        ),
      ),
    );
  }
}
