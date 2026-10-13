import 'dart:async';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

import '../route/app_routes.dart';
import 'firebase_citizen_token.dart';

/// Handles FCM and local notifications for Najda.
///
/// Routing is role/type aware: a citizen notification (type starts with
/// 'citizen_', data carries incidentCollection) opens TrackingPage; an
/// ambulance notification opens the paramedic report details page.
/// Previously EVERY tap (local or remote) always opened
/// AppRoutes.ambulanceReportDetails regardless of who received it, and a
/// locally-shown foreground notification's tap did nothing at all — its
/// payload was message.data.toString() (a Dart Map's toString(), not valid
/// JSON) handed to a handler that was an empty stub.
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
    FirebaseMessaging.onMessageOpenedApp.listen((msg) => _route(msg.data));

    // Check if app was opened from terminated state via notification
    final initialMsg = await _messaging.getInitialMessage();
    if (initialMsg != null) {
      _route(initialMsg.data);
    }

    // Citizen push notifications (CC10): citizens previously never had an
    // FCM token saved anywhere, so the backend had nothing to send to even
    // after Phase 2 added citizen-targeted notifications. Saves/refreshes
    // it whenever a citizen is signed in — see firebase_citizen_token.dart.
    await maybeSaveCitizenFcmToken();
    FirebaseMessaging.instance.onTokenRefresh.listen((_) => maybeSaveCitizenFcmToken());
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
        // Must be valid JSON to survive the round-trip through a tapped
        // local notification's payload string — Map.toString() is not.
        payload: jsonEncode(message.data),
      );
    }
  }

  void _handleTap(String? payload) {
    if (payload == null || payload.isEmpty) return;
    try {
      final data = Map<String, dynamic>.from(jsonDecode(payload) as Map);
      _route(data);
    } catch (e) {
      debugPrint('[Notifications] Failed to parse tapped payload: $e');
    }
  }

  void _route(Map<String, dynamic> data) {
    final type = data['type'] as String?;
    final incidentId = data['incidentId'] as String?;
    final incidentCollection = data['incidentCollection'] as String?;
    if (incidentId == null || incidentCollection == null) return;

    final isForCitizen = type != null && type.startsWith('citizen_');
    final reportType = incidentCollection == 'criticals' ? 'critical' : 'incident';

    if (isForCitizen) {
      _navigatorKey?.currentState?.pushNamed(
        AppRoutes.trackIncident,
        arguments: {
          'reportId': incidentId,
          'reportType': reportType,
          // No displayId/patientLat/patientLng from a push payload —
          // TrackingPage derives a displayId fallback and sources its
          // position from the live document itself (see tracking_page.dart).
        },
      );
    } else {
      _navigatorKey?.currentState?.pushNamed(
        AppRoutes.ambulanceReportDetails,
        arguments: {
          'reportId': incidentId,
          'reportType': reportType,
        },
      );
    }
  }
}
