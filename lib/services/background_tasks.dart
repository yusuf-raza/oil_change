import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import 'notification_service.dart';
import 'oil_storage.dart';

const String oilChangeTaskName = AppStrings.oilChangeTaskName;

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();

    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(OilStorageKeys.currentMileage);
    final interval = prefs.getInt(OilStorageKeys.intervalKm);
    final lastChange = prefs.getInt(OilStorageKeys.lastChangeMileage);
    final lastNotified = prefs.getInt(OilStorageKeys.lastNotifiedDueMileage);
    final lastThreshold = prefs.getInt(OilStorageKeys.lastNotifiedThreshold);
    final unit = prefs.getString(OilStorageKeys.unit);
    final notificationsEnabled =
        prefs.getBool(OilStorageKeys.notificationsEnabled) ?? true;

    if (current == null || interval == null || lastChange == null) {
      return Future.value(true);
    }

    if (!notificationsEnabled) {
      return Future.value(true);
    }

    final dueMileage = lastChange + interval;
    if (lastNotified != null && lastNotified != dueMileage) {
      await prefs.remove(OilStorageKeys.lastNotifiedThreshold);
    }

    final notifications = NotificationService();
    await notifications.initialize();
    final unitLabel = unit == AppStrings.unitMilesStorage
        ? AppStrings.unitMiShort
        : AppStrings.unitKmShort;
    final remaining = dueMileage - current;

    int? threshold;
    String? title;
    String? body;
    int? color;

    if (remaining <= 0) {
      threshold = 0;
      title = AppStrings.notificationDueTitle;
      body =
          '${AppStrings.notificationDueBody} $interval $unitLabel.';
      color = AppColors.danger;
    } else if (remaining <= 50) {
      threshold = 50;
      title = AppStrings.notificationSoonTitle;
      body =
          '${AppStrings.notificationSoonBody50} $unitLabel ${AppStrings.notificationSoonSuffix}';
      color = AppColors.warning;
    } else if (remaining <= 100) {
      threshold = 100;
      title = AppStrings.notificationSoonTitle;
      body =
          '${AppStrings.notificationSoonBody100} $unitLabel ${AppStrings.notificationSoonSuffix}';
      color = AppColors.warning;
    } else if (remaining <= 150) {
      threshold = 150;
      title = AppStrings.notificationSoonTitle;
      body =
          '${AppStrings.notificationSoonBody150} $unitLabel ${AppStrings.notificationSoonSuffix}';
      color = AppColors.warning;
    }

    if (threshold == null || color == null) {
      return Future.value(true);
    }

    if (lastNotified == dueMileage && lastThreshold == threshold) {
      return Future.value(true);
    }

    await notifications.showReminderNotification(
      title: title!,
      body: body!,
      color: color,
    );

    await prefs.setInt(OilStorageKeys.lastNotifiedDueMileage, dueMileage);
    await prefs.setInt(OilStorageKeys.lastNotifiedThreshold, threshold);
    return Future.value(true);
  });
}
