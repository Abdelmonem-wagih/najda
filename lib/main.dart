import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// import 'firebase_options.dart';

import 'core/route/app_routes.dart';
import 'core/l10n/generated/app_localizations.dart';
import 'core/theme/design.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/citizen/home/draggable_ai_button.dart';

// Global route observer — tracks current route for DraggableAiButton
final _routeObserver = NajdaRouteObserver();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: NC.base,
    systemNavigationBarIconBrightness: Brightness.light,
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
      ],
      child: MaterialApp(
        navigatorKey: AppRouter.navigatorKey,
        title: 'نجدة',
        debugShowCheckedModeBanner: false,
        theme: NajdaTheme.dark,
        locale: const Locale('ar'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        builder: (context, child) => Directionality(
          textDirection: TextDirection.rtl,
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
      ),
    );
  }
}
