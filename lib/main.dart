import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// import 'firebase_options.dart';

import 'core/route/app_routes.dart';
import 'core/l10n/generated/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_colors.dart';
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
    // options: DefaultFirebaseOptions.currentPlatform,
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
            theme: AppTheme.light,
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
                  // Draggable AI button — visible for both citizen and paramedic
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
