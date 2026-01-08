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
    final lastNotifiedDate = _readInt(data, OilStorageKeys.lastNotifiedDate);
    final unit = _readString(data, OilStorageKeys.unit);
    final notificationLeadKm =
        _readInt(data, OilStorageKeys.notificationLeadKm) ?? 50;
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
        {
          OilStorageKeys.lastNotifiedThreshold: FieldValue.delete(),
          OilStorageKeys.lastNotifiedDate: FieldValue.delete(),
        },
        SetOptions(merge: true),
      );
    }

    final now = DateTime.now();
    if (now.hour != 10) {
      return Future.value(true);
    }

    final notifications = NotificationService();
    await notifications.initialize();
    final unitLabel = unit == AppStrings.unitMilesStorage
        ? AppStrings.unitMiShort
        : AppStrings.unitKmShort;
    final remaining = dueMileage - current;
    final remainingDisplay = remaining < 0 ? 0 : remaining;

    int? threshold;
    String? title;
    String? body;
    int? color;

    if (remaining <= 0) {
      threshold = 0;
      title = AppStrings.notificationDueTitle;
      body = 'Remaining: $remainingDisplay $unitLabel.';
      color = AppColors.danger;
    } else if (remaining <= notificationLeadKm) {
      threshold = notificationLeadKm;
      title = AppStrings.notificationSoonTitle;
      body = 'Remaining: $remainingDisplay $unitLabel.';
      color = AppColors.warning;
    }

    if (threshold == null || color == null) {
      return Future.value(true);
    }

    final today = _todayStamp();
    if (lastNotified == dueMileage &&
        lastThreshold == threshold &&
        lastNotifiedDate == today) {
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
        OilStorageKeys.lastNotifiedDate: today,
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

int _todayStamp() {
  final now = DateTime.now();
  return now.year * 10000 + now.month * 100 + now.day;
}
