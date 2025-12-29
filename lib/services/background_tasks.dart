import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
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
    await Firebase.initializeApp();
    FirebaseFirestore.instance.settings =
        const Settings(persistenceEnabled: true);

    final auth = FirebaseAuth.instance;
    final user = auth.currentUser;
    if (user == null || user.isAnonymous) {
      return Future.value(true);
    }
    final uid = user.uid;

    final docRef = FirebaseFirestore.instance
        .collection(AppStrings.firestoreUsersCollection)
        .doc(uid)
        .collection(AppStrings.firestoreOilStateCollection)
        .doc(AppStrings.firestoreOilStateDoc);

    DocumentSnapshot<Map<String, dynamic>> snapshot;
    try {
      snapshot = await docRef.get(const GetOptions(source: Source.cache));
    } catch (_) {
      try {
        snapshot = await docRef.get();
      } catch (_) {
        return Future.value(true);
      }
    }

    if (!snapshot.exists) {
      return Future.value(true);
    }

    final data = snapshot.data();
    final current = _readInt(data, OilStorageKeys.currentMileage);
    final interval = _readInt(data, OilStorageKeys.intervalKm);
    final lastChange = _readInt(data, OilStorageKeys.lastChangeMileage);
    final lastNotified = _readInt(data, OilStorageKeys.lastNotifiedDueMileage);
    final lastThreshold = _readInt(data, OilStorageKeys.lastNotifiedThreshold);
    final unit = _readString(data, OilStorageKeys.unit);
    final notificationsEnabled =
        _readBool(data, OilStorageKeys.notificationsEnabled) ?? true;

    if (current == null || interval == null || lastChange == null) {
      return Future.value(true);
    }

    if (!notificationsEnabled) {
      return Future.value(true);
    }

    final dueMileage = lastChange + interval;
    if (lastNotified != null && lastNotified != dueMileage) {
      await docRef.set(
        {OilStorageKeys.lastNotifiedThreshold: FieldValue.delete()},
        SetOptions(merge: true),
      );
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

    await docRef.set(
      {
        OilStorageKeys.lastNotifiedDueMileage: dueMileage,
        OilStorageKeys.lastNotifiedThreshold: threshold,
      },
      SetOptions(merge: true),
    );
    return Future.value(true);
  });
}

int? _readInt(Map<String, dynamic>? data, String key) {
  if (data == null || !data.containsKey(key)) {
    return null;
  }
  final value = data[key];
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return null;
}

String? _readString(Map<String, dynamic>? data, String key) {
  if (data == null || !data.containsKey(key)) {
    return null;
  }
  final value = data[key];
  return value is String ? value : null;
}

bool? _readBool(Map<String, dynamic>? data, String key) {
  if (data == null || !data.containsKey(key)) {
    return null;
  }
  final value = data[key];
  return value is bool ? value : null;
}
