import 'package:flutter/material.dart';

// Auth
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/otp_page.dart';
import '../../features/auth/presentation/pages/registration_page.dart';
import '../../features/citizen/ai/ai_chat_page.dart';
import '../../features/citizen/emergency/emergency_numbers_page.dart';
import '../../features/citizen/first_aid/first_aid_pages.dart';
import '../../features/citizen/history/citizen_history_page.dart';
import '../../features/citizen/home/citizen_home_page.dart';
import '../../features/citizen/hospitals/hospitals_page.dart';
import '../../features/citizen/profile/citizen_profile_page.dart';
import '../../features/citizen/report/report_page.dart';
import '../../features/paramedic/home/paramedic_home_page.dart';
import '../../features/paramedic/notifications/notifications_history_page.dart';
import '../../features/paramedic/reports/report_details_page.dart';


class AppRoutes {
  AppRoutes._();

  // Auth
  static const String splash       = '/';
  static const String login        = '/login';
  static const String otp          = '/otp';
  static const String registration = '/registration';

  // Citizen
  static const String citizenHome      = '/citizen/home';
  static const String citizenReport    = '/citizen/report';
  static const String citizenHistory   = '/citizen/history';
  static const String citizenFirstAid  = '/citizen/first-aid';
  static const String citizenHospitals = '/citizen/hospitals';
  static const String citizenEmergency = '/citizen/emergency';
  static const String citizenProfile   = '/citizen/profile';
  static const String aiChat           = '/ai/chat';

  // Paramedic
  static const String paramedicHome         = '/paramedic/home';
  static const String paramedicReportDetails = '/paramedic/report-details';
  static const String paramedicNotifications = '/paramedic/notifications';
  static const String paramedicHistory      = '/paramedic/history';
}

class AppRouter {
  static final navigatorKey = GlobalKey<NavigatorState>();

  static Route<dynamic> onGenerateRoute(RouteSettings s) {
    switch (s.name) {
      case AppRoutes.splash:
        return _fade(const SplashPage(), s);
      case AppRoutes.login:
        return _fade(const LoginPage(), s);
      case AppRoutes.otp:
        return _slide(OtpPage(verificationId: s.arguments as String), s);
      case AppRoutes.registration:
        final a = s.arguments as Map<String, dynamic>;
        return _slide(RegistrationPage(
            uid: a['uid'], phoneNumber: a['phoneNumber']), s);

      // Citizen
      case AppRoutes.citizenHome:
        return _fade(const CitizenHomePage(), s);
      case AppRoutes.citizenReport:
        return _slide(const ReportPage(), s);
      case AppRoutes.citizenHistory:
        return _slide(const CitizenHistoryPage(), s);
      case AppRoutes.citizenFirstAid:
        return _slide(const FirstAidListPage(), s);
      case AppRoutes.citizenHospitals:
        return _slide(const HospitalsPage(), s);
      case AppRoutes.citizenEmergency:
        return _slide(const EmergencyNumbersPage(), s);
      case AppRoutes.citizenProfile:
        return _slide(const CitizenProfilePage(), s);
      case AppRoutes.aiChat:
        return _modal(const AiChatPage(), s);

      // Paramedic
      case AppRoutes.paramedicHome:
        return _fade(const ParamedicHomePage(), s);
      case AppRoutes.paramedicReportDetails:
        final a = s.arguments as Map<String, dynamic>;
        return _slide(ReportDetailsPage(
            reportId: a['reportId'], reportType: a['reportType']), s);
      case AppRoutes.paramedicNotifications:
        return _slide(const NotificationsHistoryPage(showHistory: false), s);
      case AppRoutes.paramedicHistory:
        return _slide(const NotificationsHistoryPage(showHistory: true), s);

      default:
        return _fade(const SplashPage(), s);
    }
  }

  static PageRoute _fade(Widget p, RouteSettings s) => PageRouteBuilder(
        settings: s,
        pageBuilder: (_, __, ___) => p,
        transitionsBuilder: (_, a, __, c) =>
            FadeTransition(opacity: a, child: c),
        transitionDuration: const Duration(milliseconds: 280),
      );

  static PageRoute _slide(Widget p, RouteSettings s) => PageRouteBuilder(
        settings: s,
        pageBuilder: (_, __, ___) => p,
        transitionsBuilder: (_, a, __, c) => SlideTransition(
          position: Tween<Offset>(
                  begin: const Offset(1, 0), end: Offset.zero)
              .animate(CurvedAnimation(parent: a, curve: Curves.easeInOut)),
          child: c,
        ),
        transitionDuration: const Duration(milliseconds: 260),
      );

  static PageRoute _modal(Widget p, RouteSettings s) => PageRouteBuilder(
        settings: s,
        pageBuilder: (_, __, ___) => p,
        transitionsBuilder: (_, a, __, c) => SlideTransition(
          position: Tween<Offset>(
                  begin: const Offset(0, 1), end: Offset.zero)
              .animate(CurvedAnimation(parent: a, curve: Curves.easeOut)),
          child: c,
        ),
        transitionDuration: const Duration(milliseconds: 320),
      );
}
