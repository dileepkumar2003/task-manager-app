import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final notifications = FlutterLocalNotificationsPlugin();

Future<void> initNotification() async {
  const android = AndroidInitializationSettings('@mipmap/ic_launcher');
  const settings = InitializationSettings(android: android);
  await notifications.initialize(settings);
}

Future<void> showNotification() async {
  const android = AndroidNotificationDetails(
    'task_channel',
    'Task Reminder',
    importance: Importance.high,
  );

  await notifications.show(
    0,
    "Task Added",
    "Your task was saved successfully",
    const NotificationDetails(android: android),
  );
}
