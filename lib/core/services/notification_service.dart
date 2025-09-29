import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:logger/logger.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  final Logger _logger = Logger();

  Future<void> init() async {
    if (kIsWeb) {
      _logger.w(
        'Notifications not supported on web. Consider using Web Push Notifications.',
      );
      return;
    }

    try {
      tz.initializeTimeZones();
      const AndroidInitializationSettings androidInit =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const DarwinInitializationSettings iosInit = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      const InitializationSettings initSettings = InitializationSettings(
        android: androidInit,
        iOS: iosInit,
      );

      await _notifications.initialize(initSettings);

      await _requestPermissions();
      await _createNotificationChannels();

      _logger.i('Notifications initialized successfully');
    } catch (e, stackTrace) {
      _logger.e('Notification init error: $e', stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> _requestPermissions() async {
    final androidImpl = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final iosImpl = _notifications
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();

    if (androidImpl != null) {
      final exactAlarmPermission = await androidImpl
          .requestExactAlarmsPermission();
      _logger.i('Android exact alarm permission: $exactAlarmPermission');

      final permissionResult = await androidImpl
          .requestNotificationsPermission();
      _logger.i(
        'Android notification permission requested, result: $permissionResult',
      );
    }

    if (iosImpl != null) {
      final permissionResult = await iosImpl.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      _logger.i(
        'iOS notification permissions requested, result: $permissionResult',
      );
    }
  }

  Future<void> _createNotificationChannels() async {
    final androidImpl = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidImpl != null) {
      await androidImpl.createNotificationChannel(
        const AndroidNotificationChannel(
          'task_channel',
          'Task Reminders',
          description: 'Notifications for task deadlines',
          importance: Importance.high,
          enableVibration: true,
          playSound: true,
        ),
      );
    }
  }

  Future<void> scheduleNotification(
    String id,
    String title,
    DateTime deadline,
  ) async {
    if (kIsWeb) {
      _logger.w('Skipping notification scheduling on web.');
      return;
    }

    try {
      final hasPermission = await _checkPermissions();
      if (!hasPermission) {
        _logger.w('No notification permissions, cannot schedule notification');
        return;
      }

      final tz.TZDateTime scheduledDate = tz.TZDateTime.from(
        deadline.subtract(const Duration(minutes: 5)),
        tz.local,
      );
      final now = tz.TZDateTime.now(tz.local);

      _logger.i(
        'Scheduling for deadline: $deadline, scheduledDate: $scheduledDate, now: $now',
      );

      await _notifications.zonedSchedule(
        id.hashCode,
        'Task Reminder: $title',
        'Deadline in 5 minutes! Don\'t forget to complete this task.',
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'task_channel',
            'Task Reminders',
            channelDescription: 'Notifications for task deadlines',
            importance: Importance.high,
            priority: Priority.high,
            enableVibration: true,
            playSound: true,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: id,
      );

      _logger.i('Notification scheduled for task: $title at $scheduledDate');
    } catch (e, stackTrace) {
      _logger.e('Notification schedule error: $e', stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<bool> _checkPermissions() async {
    final androidImpl = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidImpl != null) {
      final permission = await androidImpl.areNotificationsEnabled();
      return permission ?? false;
    }
    return true;
  }

  Future<void> cancelNotification(String id) async {
    if (kIsWeb) {
      _logger.w('Skipping notification cancellation on web.');
      return;
    }
    try {
      await _notifications.cancel(id.hashCode);
      _logger.i('Notification cancelled for task ID: $id');
    } catch (e, stackTrace) {
      _logger.e('Notification cancel error: $e', stackTrace: stackTrace);
    }
  }

  Future<void> cancelAllNotifications() async {
    if (kIsWeb) return;
    try {
      await _notifications.cancelAll();
      _logger.i('All notifications cancelled');
    } catch (e, stackTrace) {
      _logger.e('Cancel all notifications error: $e', stackTrace: stackTrace);
    }
  }
}
