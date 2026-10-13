import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/design.dart';
import 'firebase_options.dart';
import 'core/route/app_routes.dart';
import 'core/l10n/generated/app_localizations.dart';
import 'core/services/notification_service.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/settings/presentation/cubit/settings_cubit.dart';
import 'features/settings/presentation/cubit/settings_state.dart';
import 'features/settings/data/repositories/settings_repository_impl.dart';
import 'features/settings/data/datasources/settings_local_datasource.dart';
import 'features/citizen/home/draggable_ai_button.dart';

// Global route observer — tracks current route for DraggableAiButton
final _routeObserver = NajdaRouteObserver();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.white,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Notifications
  await NotificationService.instance.init(AppRouter.navigatorKey);

  // Always activate App Check — debug provider in debug builds, the real
  // attestation providers in release (previously this was only inside
  // `if (kDebugMode)`, so release builds shipped with zero App Check
  // enforcement at all; see firebase/CONTRACT.md "App Check" for the
  // console-side enforcement sequencing this requires).
  await FirebaseAppCheck.instance.activate(
    androidProvider: kDebugMode ? AndroidProvider.debug : AndroidProvider.playIntegrity,
    appleProvider: kDebugMode ? AppleProvider.debug : AppleProvider.appAttest,
  );

  runApp(const NajdaApp());
}

class NajdaApp extends StatelessWidget {
  const NajdaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthCubit()),
        BlocProvider(
          create: (_) => SettingsCubit(
            repository: SettingsRepositoryImpl(
              localDataSource: SettingsLocalDataSourceImpl(),
            ),
          )..loadSettings(),
        ),
      ],
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          return MaterialApp(
            navigatorKey: AppRouter.navigatorKey,
            title: 'نجدة',
            debugShowCheckedModeBanner: false,
            theme: NajdaTheme.light,
            locale: state.locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            builder: (context, child) => Directionality(
              textDirection: state.locale.languageCode == 'ar'
                  ? TextDirection.rtl
                  : TextDirection.ltr,
              child: Stack(
                children: [
                  child!,
                  // Draggable AI button — AI is cancelled for v1 (AppConstants.aiEnabled).
                  if (AppConstants.aiEnabled)
                    BlocBuilder<AuthCubit, AuthState>(
                      builder: (ctx, state) {
                        if (state is AuthAuthenticated) {
                          return const DraggableAiButton();
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                ],
              ),
            ),
            navigatorObservers: [_routeObserver],
            initialRoute: AppRoutes.splash,
            onGenerateRoute: AppRouter.onGenerateRoute,
          );
        },
      ),
    );
  }
}
