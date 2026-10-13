import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

import '../route/app_routes.dart';

/// Handles FCM and local notifications for Najda.
class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();

  final _messaging = FirebaseMessaging.instance;
  final _localNotif = FlutterLocalNotificationsPlugin();
  
  // Navigation key reference
  GlobalKey<NavigatorState>? _navigatorKey;

  Future<void> init(GlobalKey<NavigatorState> navKey) async {
    _navigatorKey = navKey;

    // 1. Request Permission
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // 2. Initialize Local Notifications
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    await _localNotif.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
      onDidReceiveNotificationResponse: (response) => _handleTap(response.payload),
    );

    // 3. Setup FCM Listeners
    FirebaseMessaging.onMessage.listen(_showForegroundNotification);
    FirebaseMessaging.onMessageOpenedApp.listen((msg) => _handleTapFromRemote(msg.data));
    
    // Check if app was opened from terminated state via notification
    final initialMsg = await _messaging.getInitialMessage();
    if (initialMsg != null) {
      _handleTapFromRemote(initialMsg.data);
    }
  }

  void _showForegroundNotification(RemoteMessage message) {
    final notification = message.notification;
    final android = message.notification?.android;

    if (notification != null && android != null) {
      _localNotif.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            importance: Importance.max,
            priority: Priority.high,
            icon: android.smallIcon,
          ),
        ),
        payload: message.data.toString(),
      );
    }
  }

  void _handleTap(String? payload) {
    if (payload == null) return;
    // Parse manual string if needed, or better use map directly
    // For simplicity, let's assume we pass data as stringified map or just use the remote handler
  }

  void _handleTapFromRemote(Map<String, dynamic> data) {
    final type = data['type'];
    final reportId = data['reportId'];
    final reportType = data['reportType'];

    if (reportId != null && reportType != null) {
      _navigatorKey?.currentState?.pushNamed(
        AppRoutes.ambulanceReportDetails,
        arguments: {
          'reportId': reportId,
          'reportType': reportType,
        },
      );
    }
  }
}
