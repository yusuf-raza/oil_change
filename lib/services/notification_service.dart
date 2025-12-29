import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../constants/app_strings.dart';

class NotificationService {
  static const _channelId = AppStrings.notificationChannelId;
  static const _channelName = AppStrings.notificationChannelName;
  static const _channelDescription = AppStrings.notificationChannelDescription;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const android = AndroidInitializationSettings(
      AppStrings.androidNotificationIcon,
    );
    const settings = InitializationSettings(android: android);
    await _plugin.initialize(settings);
  }

  Future<void> requestPermissions() async {
    final androidImpl = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidImpl?.requestNotificationsPermission();
  }

  Future<void> showReminderNotification({
    required String title,
    required String body,
    required int color,
  }) async {
    const largeIcon = DrawableResourceAndroidBitmap('oil_notification');
    final style = BigPictureStyleInformation(
      largeIcon,
      largeIcon: largeIcon,
      contentTitle: title,
      summaryText: body,
    );
    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      color: Color(color),
      colorized: true,
      largeIcon: largeIcon,
      styleInformation: style,
    );

    final details = NotificationDetails(android: androidDetails);
    await _plugin.show(
      '$title-$body'.hashCode,
      title,
      body,
      details,
    );
  }
}
