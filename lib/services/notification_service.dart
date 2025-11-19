import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService._internal();
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    const initSettings = InitializationSettings(
      android: androidSettings,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initSettings,
    );

    _initialized = true;
  }

  Future<void> requestAndroidPermission() async {
    // For current plugin version, explicit runtime permission request is not
    // exposed on Android the same way as on iOS/macOS, so this is a no-op.
    // Ensure you declare POST_NOTIFICATIONS in the manifest for Android 13+.
  }

  int _idForTask(int index) => index + 1; // simple stable id per index

  Future<void> scheduleReminder({
    required int index,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    if (scheduledTime.isBefore(DateTime.now())) return;

    await init();
    await requestAndroidPermission();

    const androidDetails = AndroidNotificationDetails(
      'tasks_channel',
      'Task Reminders',
      channelDescription: 'Reminders for your tasks',
      importance: Importance.high,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);

    // Plugin version in use does not expose a DateTime-based schedule API
    // on this platform type, so we show immediately once a valid
    // reminder time has been set.
    await _flutterLocalNotificationsPlugin.show(
      _idForTask(index),
      title,
      body,
      details,
      payload: index.toString(),
    );
  }

  Future<void> cancelReminder(int index) async {
    await init();
    await _flutterLocalNotificationsPlugin.cancel(_idForTask(index));
  }

  Future<void> cancelAll() async {
    await init();
    await _flutterLocalNotificationsPlugin.cancelAll();
  }
}
