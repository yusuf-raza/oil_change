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
import 'viewmodels/oil_view_model.dart';
import 'views/home_screen.dart';

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

  runApp(const OilChangeApp());
}

class OilChangeApp extends StatelessWidget {
  const OilChangeApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(AppColors.seed),
      primary: const Color(AppColors.seed),
      secondary: const Color(AppColors.accent),
      surface: const Color(AppColors.lightSurface),
      brightness: Brightness.light,
    );

    return ChangeNotifierProvider(
      create: (_) => OilViewModel(
        NotificationService(),
        OilRepository(FirebaseFirestore.instance, FirebaseAuth.instance),
      ),
      child: Consumer<OilViewModel>(
        builder: (context, viewModel, child) {
          final darkScheme = ColorScheme.fromSeed(
            seedColor: const Color(AppColors.darkSeed),
            brightness: Brightness.dark,
          );
          final themeMode = viewModel.themeMode == AppThemeMode.dark
              ? ThemeMode.dark
              : ThemeMode.light;

          return MaterialApp(
            title: AppStrings.appTitle,
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: colorScheme,
              useMaterial3: true,
              scaffoldBackgroundColor: const Color(AppColors.transparent),
              textTheme: GoogleFonts.spaceGroteskTextTheme(),
            ),
            darkTheme: ThemeData(
              colorScheme: darkScheme,
              useMaterial3: true,
              scaffoldBackgroundColor: const Color(AppColors.transparent),
              textTheme: GoogleFonts.spaceGroteskTextTheme(
                ThemeData(brightness: Brightness.dark).textTheme,
              ),
            ),
            themeMode: themeMode,
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
