import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart'; // FIXED PACKAGE
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._internal();
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  bool _timeZoneConfigured = false;

  Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();
    if (_initialized) return;

    await _ensureTimeZoneConfigured();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    const initSettings = InitializationSettings(
      android: androidSettings,
    );

    await _flutterLocalNotificationsPlugin.initialize(initSettings);

    // Required for notifications to work on Android 13+
    final android = _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await android?.createNotificationChannel(
      const AndroidNotificationChannel(
        'tasks_channel',
        'Task Reminders',
        description: 'Reminders for your tasks',
        importance: Importance.high,
      ),
    );

    _initialized = true;
  }

  Future<(bool canSchedule, AndroidScheduleMode? androidMode)>
      _ensurePermissions() async {
    final iosPlugin = _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();

    await iosPlugin?.requestPermissions(alert: true, badge: true, sound: true);

    AndroidScheduleMode? scheduleMode;

    final androidPlugin = _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      final notificationsGranted =
          await androidPlugin.requestNotificationsPermission();
      if (notificationsGranted == false) {
        return (false, null);
      }

      final exactGranted =
          await androidPlugin.requestExactAlarmsPermission();

      scheduleMode = exactGranted == false
          ? AndroidScheduleMode.inexactAllowWhileIdle
          : AndroidScheduleMode.exactAllowWhileIdle;
    }

    return (true, scheduleMode);
  }

  Future<void> _ensureTimeZoneConfigured() async {
    if (_timeZoneConfigured) return;

    WidgetsFlutterBinding.ensureInitialized();
    tzdata.initializeTimeZones();

    try {
      // Use correct timezone package
      final String localTz = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(localTz));
    } catch (e) {
      tz.setLocalLocation(tz.getLocation('Europe/Athens'));
    }

    _timeZoneConfigured = true;
  }

  int _idForTask(int index) => index + 1;

  Future<void> askPermissionsAtStartup() async {
    await init();
    await _ensurePermissions();
  }

  Future<void> scheduleReminder({
    required int index,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    print('Scheduling reminder: index=$index, scheduledTime=$scheduledTime, now=${DateTime.now()}');
    final now = DateTime.now();
    if (scheduledTime.isBefore(now.subtract(const Duration(seconds: 5)))) {
      return;
    }

    await init();
    // We already requested permissions at startup; avoid depending on
    // exact alarm permission here to keep behaviour more reliable.
    final (canSchedule, _) = await _ensurePermissions();
    if (!canSchedule) return;

    await _ensureTimeZoneConfigured();

    const androidDetails = AndroidNotificationDetails(
      'tasks_channel',
      'Task Reminders',
      channelDescription: 'Reminders for your tasks',
      importance: Importance.high,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);

    final scheduledDate = tz.TZDateTime.from(scheduledTime, tz.local);

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      _idForTask(index),
      title,
      body,
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: null,
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
