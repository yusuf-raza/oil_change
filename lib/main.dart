import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:workmanager/workmanager.dart';

import 'constants/app_colors.dart';
import 'constants/app_strings.dart';
import 'models/enums.dart';
import 'services/background_tasks.dart';
import 'data/local/app_database.dart';
import 'data/local/local_oil_repository.dart';
import 'data/local/local_tour_draft_repository.dart';
import 'data/local/local_tour_repository.dart';
import 'services/notification_service.dart';
import 'services/offline_oil_repository.dart';
import 'services/offline_sync_service.dart';
import 'services/offline_tour_repository.dart';
import 'services/oil_repository.dart';
import 'services/tour_repository.dart';
import 'services/theme_storage.dart';
import 'viewmodels/oil_view_model.dart';
import 'views/home/home_screen.dart';
import 'views/sign_in/sign_in_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true);

  Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
  Workmanager().registerPeriodicTask(
    oilChangeTaskName,
    oilChangeTaskName,
    frequency: const Duration(hours: 24),
    initialDelay: _delayUntilNext10am(),
    existingWorkPolicy: ExistingWorkPolicy.keep,
  );

  AppThemeMode? initialThemeMode;
  try {
    initialThemeMode = await ThemeStorage().readThemeMode();
  } catch (_) {
    initialThemeMode = null;
  }
  initialThemeMode ??= AppThemeMode.dark;

  final appDb = AppDatabase();
  final localOilRepo = LocalOilRepository(appDb);
  final localTourRepo = LocalTourRepository(appDb);
  final localTourDraftRepo = LocalTourDraftRepository(appDb);
  final remoteOilRepo =
      OilRepository(FirebaseFirestore.instance, FirebaseAuth.instance);
  final remoteTourRepo =
      TourRepository(FirebaseFirestore.instance, FirebaseAuth.instance);
  final offlineOilRepo = OfflineOilRepository(localOilRepo, remoteOilRepo);
  final offlineTourRepo = OfflineTourRepository(localTourRepo, remoteTourRepo);
  final syncService = OfflineSyncService(
    oilRepository: offlineOilRepo,
    tourRepository: offlineTourRepo,
  );

  runApp(
    OilChangeApp(
      initialThemeMode: initialThemeMode,
      database: appDb,
      oilRepository: offlineOilRepo,
      tourRepository: offlineTourRepo,
      tourDraftRepository: localTourDraftRepo,
      syncService: syncService,
    ),
  );
}

class OilChangeApp extends StatelessWidget {
  const OilChangeApp({
    super.key,
    this.initialThemeMode,
    required this.database,
    required this.oilRepository,
    required this.tourRepository,
    required this.tourDraftRepository,
    required this.syncService,
  });

  final AppThemeMode? initialThemeMode;
  final AppDatabase database;
  final OfflineOilRepository oilRepository;
  final OfflineTourRepository tourRepository;
  final LocalTourDraftRepository tourDraftRepository;
  final OfflineSyncService syncService;

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
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(AppColors.darkSeed), brightness: Brightness.dark),
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(AppColors.transparent),
      textTheme: GoogleFonts.spaceGroteskTextTheme(ThemeData(brightness: Brightness.dark).textTheme),
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

        return MultiProvider(
          providers: [
            Provider<AppDatabase>.value(value: database),
            Provider<LocalTourDraftRepository>.value(value: tourDraftRepository),
            ChangeNotifierProvider<OfflineSyncService>.value(value: syncService),
            Provider<TourRepositoryBase>.value(value: tourRepository),
            ChangeNotifierProvider(
              create: (_) => OilViewModel(
                NotificationService(),
                oilRepository,
                initialThemeMode: initialThemeMode,
              ),
            ),
          ],
          child: Consumer<OilViewModel>(
            builder: (context, viewModel, child) {
              final themeMode = viewModel.themeMode == AppThemeMode.dark ? ThemeMode.dark : ThemeMode.light;

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
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

Duration _delayUntilNext10am() {
  final now = DateTime.now();
  var next = DateTime(now.year, now.month, now.day, 10);
  if (!now.isBefore(next)) {
    next = next.add(const Duration(days: 1));
  }
  return next.difference(now);
}
