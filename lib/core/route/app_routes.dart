import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../constants/app_constants.dart';

// Auth
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/otp_page.dart';
import '../../features/auth/presentation/pages/registration_page.dart';
import '../../features/citizen/ai/ai_chat_page.dart';
import '../../features/citizen/emergency/emergency_numbers_page.dart';
import '../../features/citizen/first_aid/first_aid_pages.dart';
import '../../features/citizen/history/citizen_history_page.dart';
import '../../features/citizen/home/citizen_home_page.dart';
import '../../features/citizen/home/presentation/cubit/sos_cubit.dart';
import '../../features/citizen/home/data/repositories/sos_repository_impl.dart';
import '../../features/citizen/home/data/datasources/sos_remote_datasource.dart';
import '../../features/citizen/hospitals/hospitals_page.dart';
import '../../features/citizen/profile/presentation/pages/citizen_profile_page.dart';
import '../../features/citizen/profile/presentation/pages/edit_profile_page.dart';
import '../../features/citizen/report/presentation/pages/report_page.dart';
import '../../features/citizen/report/presentation/cubit/report_cubit.dart';
import '../../features/citizen/report/data/repositories/report_repository_impl.dart';
import '../../features/citizen/report/data/datasources/report_remote_datasource.dart';
import '../../features/paramedic/notifications/notifications_history_page.dart';
import '../../features/paramedic/reports/report_details_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/settings/presentation/pages/language_page.dart';
import '../../features/settings/presentation/pages/help_support_page.dart';
import '../../features/settings/presentation/pages/privacy_policy_page.dart';
import '../../features/settings/presentation/pages/terms_page.dart';
import '../../features/settings/presentation/pages/about_page.dart';
import '../../features/settings/presentation/pages/rate_page.dart';
import '../../features/settings/presentation/pages/share_page.dart';
import '../../features/citizen/tracking/tracking_page.dart';

import '../../features/paramedic/presentation/pages/paramedic_main_scaffold.dart';

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
  static const String editProfile      = '/citizen/edit-profile';
  static const String trackIncident    = '/citizen/track';

  // Settings
  static const String settings         = '/settings';
  static const String settingsLanguage = '/settings/language';
  static const String settingsHelp     = '/settings/help';
  static const String settingsPrivacy  = '/settings/privacy';
  static const String settingsTerms    = '/settings/terms';
  static const String settingsAbout    = '/settings/about';
  static const String settingsRate     = '/settings/rate';
  static const String settingsShare    = '/settings/share';

  static const String aiChat           = '/ai/chat';

  // Ambulance
  static const String ambulanceHome         = '/ambulance/home';
  static const String ambulanceReportDetails = '/ambulance/report-details';
  static const String ambulanceNotifications = '/ambulance/notifications';
  static const String ambulanceHistory      = '/ambulance/history';

  /// Routes reachable without being signed in at all.
  static const Set<String> publicRoutes = {splash, login, otp, registration};
}

class AppRouter {
  static final navigatorKey = GlobalKey<NavigatorState>();

  static Route<dynamic> onGenerateRoute(RouteSettings s) {
    final guarded = _applyRoleGuard(s);
    if (guarded != null) return guarded;

    switch (s.name) {
      case AppRoutes.splash:
        return _fade(const SplashPage(), s);
      case AppRoutes.login:
        return _fade(const LoginPage(), s);
      case AppRoutes.otp:
        final verificationId = s.arguments;
        if (verificationId is! String) return _fade(const LoginPage(), s);
        return _slide(OtpPage(verificationId: verificationId), s);
      case AppRoutes.registration: {
        final a = _args(s);
        final uid = a['uid'] as String?;
        final phoneNumber = a['phoneNumber'] as String?;
        if (uid == null || phoneNumber == null) return _fade(const LoginPage(), s);
        return _slide(RegistrationPage(uid: uid, phoneNumber: phoneNumber), s);
      }

      // Citizen
      case AppRoutes.citizenHome:
        return _fade(
          BlocProvider(
            create: (context) => SOSCubit(
              repository: SOSRepositoryImpl(
                remoteDataSource: SOSRemoteDataSourceImpl(),
              ),
            ),
            child: const CitizenHomePage(),
          ),
          s,
        );
      case AppRoutes.citizenReport:
        return _slide(
          BlocProvider(
            create: (context) => ReportCubit(
              repository: ReportRepositoryImpl(
                remoteDataSource: ReportRemoteDataSourceImpl(),
              ),
            ),
            child: const ReportPage(),
          ),
          s,
        );
      case AppRoutes.citizenHistory:
        return _slide(const CitizenHistoryPage(), s);
      case AppRoutes.citizenFirstAid:
        return _slide(const FirstAidListPage(), s);
      case AppRoutes.citizenHospitals:
        return _slide(const HospitalsPage(), s);
      case AppRoutes.citizenEmergency:
        return _slide(const EmergencyNumbersPage(), s);
      case AppRoutes.trackIncident: {
        final a = _args(s);
        final reportId = a['reportId'] as String?;
        final reportType = a['reportType'] as String?;
        if (reportId == null || reportType == null) return _fade(const SplashPage(), s);
        return _slide(TrackingPage(
          reportId:   reportId,
          reportType: reportType,
          // Falls back to a short id derived from the report id itself —
          // a notification tap's arguments don't carry a displayId.
          displayId:  (a['displayId'] as String?) ??
              (reportId.length > 6 ? reportId.substring(0, 6) : reportId),
          patientLat: (a['patientLat'] as num?)?.toDouble(),
          patientLng: (a['patientLng'] as num?)?.toDouble(),
        ), s);
      }
      case AppRoutes.citizenProfile:
        return _slide(const CitizenProfilePage(), s);
      case AppRoutes.editProfile:
        return _slide(const EditProfilePage(), s);

      // Settings
      case AppRoutes.settings:
        return _slide(const SettingsPage(), s);
      case AppRoutes.settingsLanguage:
        return _slide(const LanguagePage(), s);
      case AppRoutes.settingsHelp:
        return _slide(const HelpSupportPage(), s);
      case AppRoutes.settingsPrivacy:
        return _slide(const PrivacyPolicyPage(), s);
      case AppRoutes.settingsTerms:
        return _slide(const TermsPage(), s);
      case AppRoutes.settingsAbout:
        return _slide(const AboutPage(), s);
      case AppRoutes.settingsRate:
        return _slide(const RatePage(), s);
      case AppRoutes.settingsShare:
        return _slide(const SharePage(), s);

      case AppRoutes.aiChat:
        // AI is cancelled for v1 (AppConstants.aiEnabled) — guarded here so
        // the route is unreachable even via a direct pushNamed() call.
        if (!AppConstants.aiEnabled) return _fade(const SplashPage(), s);
        return _modal(const AiChatPage(), s);

      // Ambulance
      case AppRoutes.ambulanceHome:
        return _fade(const AmbulanceMainScaffold(), s);
      case AppRoutes.ambulanceReportDetails: {
        final a = _args(s);
        final reportId = a['reportId'] as String?;
        final reportType = a['reportType'] as String?;
        if (reportId == null || reportType == null) return _fade(const SplashPage(), s);
        return _slide(ReportDetailsPage(reportId: reportId, reportType: reportType), s);
      }
      case AppRoutes.ambulanceNotifications:
        return _slide(const NotificationsHistoryPage(showHistory: false), s);
      case AppRoutes.ambulanceHistory:
        return _slide(const NotificationsHistoryPage(showHistory: true), s);

      default:
        return _fade(const SplashPage(), s);
    }
  }

  /// Returns the arguments as a Map, or an empty Map if they're missing or
  /// the wrong type — every case above reads from this instead of doing its
  /// own unguarded `s.arguments as Map<String, dynamic>`, which previously
  /// threw an uncaught TypeError if a caller ever forgot to pass arguments
  /// (or a notification/deep-link path supplied something unexpected).
  static Map<String, dynamic> _args(RouteSettings s) {
    final raw = s.arguments;
    return raw is Map<String, dynamic> ? raw : <String, dynamic>{};
  }

  /// Blocks unauthenticated access to any non-public route, and blocks a
  /// citizen from an /ambulance/* route or an ambulance user from a
  /// /citizen/* route (silently redirecting to their own home instead of
  /// letting the mismatched page build). Previously nothing re-checked
  /// auth/role on every navigation — only the splash screen decided the
  /// *initial* route, so anything with a BuildContext could successfully
  /// pushNamed() an ambulance screen from the citizen app or vice versa.
  static Route<dynamic>? _applyRoleGuard(RouteSettings s) {
    final name = s.name;
    if (name == null || AppRoutes.publicRoutes.contains(name)) return null;

    final context = navigatorKey.currentContext;
    if (context == null) return null; // nothing to check against yet

    AuthState authState;
    try {
      authState = context.read<AuthCubit>().state;
    } catch (_) {
      return null; // AuthCubit not mounted yet (shouldn't normally happen)
    }

    if (authState is! AuthAuthenticated) {
      return name == AppRoutes.login ? null : _fade(const LoginPage(), const RouteSettings(name: AppRoutes.login));
    }

    final isAmbulanceUser = authState.user.isAmbulances;
    final isAmbulanceRoute = name.startsWith('/ambulance');
    final isCitizenRoute = name.startsWith('/citizen') ||
        name.startsWith('/settings') ||
        name == AppRoutes.aiChat;

    if (isAmbulanceRoute && !isAmbulanceUser) {
      return _fade(const CitizenHomePage(), const RouteSettings(name: AppRoutes.citizenHome));
    }
    if (isCitizenRoute && isAmbulanceUser) {
      return _fade(const AmbulanceMainScaffold(), const RouteSettings(name: AppRoutes.ambulanceHome));
    }
    return null;
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
