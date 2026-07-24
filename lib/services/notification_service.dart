import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin
  flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings =
    InitializationSettings(
      android: androidSettings,
    );

    await flutterLocalNotificationsPlugin.initialize(settings);

    final androidPlugin =
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    final granted =
    await androidPlugin?.requestNotificationsPermission();

    print("Notification Permission = $granted");
  }

  static Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    print("Notification function called");

    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'finance_channel',
      'Finance Notifications',
      channelDescription: 'Finance App Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails details =
    NotificationDetails(
      android: androidDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      details,
    );

    print("Notification sent");
  }
}