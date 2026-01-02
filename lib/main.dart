import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:workmanager/workmanager.dart';

import 'constants/app_colors.dart';
import 'constants/app_strings.dart';
import 'models/enums.dart';
import 'services/background_tasks.dart';
import 'services/notification_service.dart';
import 'services/oil_repository.dart';
import 'services/theme_storage.dart';
import 'viewmodels/oil_view_model.dart';
import 'views/home_screen.dart';
import 'views/sign_in_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  FirebaseFirestore.instance.settings =
      const Settings(persistenceEnabled: true);

  Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
  Workmanager().registerPeriodicTask(
    oilChangeTaskName,
    oilChangeTaskName,
    frequency: const Duration(hours: 12),
    existingWorkPolicy: ExistingWorkPolicy.keep,
  );

  AppThemeMode? initialThemeMode;
  try {
    initialThemeMode = await ThemeStorage().readThemeMode();
  } catch (_) {
    initialThemeMode = null;
  }

  runApp(OilChangeApp(initialThemeMode: initialThemeMode));
}

class OilChangeApp extends StatelessWidget {
  const OilChangeApp({super.key, this.initialThemeMode});

  final AppThemeMode? initialThemeMode;

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(AppColors.seed),
      primary: const Color(AppColors.seed),
      secondary: const Color(AppColors.accent),
      surface: const Color(AppColors.lightSurface),
      brightness: Brightness.light,
    );
    final lightTheme = ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(AppColors.transparent),
      textTheme: GoogleFonts.spaceGroteskTextTheme(),
    );
    final darkTheme = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(AppColors.darkSeed),
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(AppColors.transparent),
      textTheme: GoogleFonts.spaceGroteskTextTheme(
        ThemeData(brightness: Brightness.dark).textTheme,
      ),
    );

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(
            title: AppStrings.appTitle,
            debugShowCheckedModeBanner: false,
            theme: lightTheme,
            darkTheme: darkTheme,
            home: const _AuthLoadingScreen(),
          );
        }

        final user = snapshot.data;
        if (user == null || user.isAnonymous) {
          return MaterialApp(
            title: AppStrings.appTitle,
            debugShowCheckedModeBanner: false,
            theme: lightTheme,
            darkTheme: darkTheme,
            home: SignInScreen(),
          );
        }

        return ChangeNotifierProvider(
          create: (_) => OilViewModel(
            NotificationService(),
            OilRepository(FirebaseFirestore.instance, FirebaseAuth.instance),
            initialThemeMode: initialThemeMode,
          ),
          child: Consumer<OilViewModel>(
            builder: (context, viewModel, child) {
              final themeMode = viewModel.themeMode == AppThemeMode.dark
                  ? ThemeMode.dark
                  : ThemeMode.light;

              return MaterialApp(
                title: AppStrings.appTitle,
                debugShowCheckedModeBanner: false,
                theme: lightTheme,
                darkTheme: darkTheme,
                themeMode: themeMode,
                home: const HomeScreen(),
              );
            },
          ),
        );
      },
    );
  }
}

class _AuthLoadingScreen extends StatelessWidget {
  const _AuthLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
