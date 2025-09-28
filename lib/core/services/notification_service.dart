import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:logger/logger.dart';

class NotificationService {
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

      // Request permissions
      await _notifications
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions();
      await _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();

      _logger.i('Notifications initialized successfully');
    } catch (e, stackTrace) {
      _logger.e('Notification init error: $e', stackTrace: stackTrace);
      rethrow;
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
      final tz.TZDateTime scheduledDate = tz.TZDateTime.from(
        deadline.subtract(const Duration(days: 1)),
        tz.local,
      );
      if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) return;

      await _notifications.zonedSchedule(
        id.hashCode,
        'Task Reminder: $title',
        'Deadline approaching tomorrow!',
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'task_channel',
            'Task Reminders',
            importance: Importance.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
      _logger.i('Notification scheduled for task: $title');
    } catch (e, stackTrace) {
      _logger.e('Notification schedule error: $e', stackTrace: stackTrace);
    }
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
}
