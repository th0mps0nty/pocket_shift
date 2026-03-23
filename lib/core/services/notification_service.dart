import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../features/settings/domain/app_settings.dart';
import '../constants/app_constants.dart';

final notificationServiceProvider = Provider<NotificationService>(
  (ref) => NotificationService(),
);

class NotificationService {
  NotificationService({FlutterLocalNotificationsPlugin? plugin})
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;
  bool _timeZoneReady = false;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    try {
      const settings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
        macOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      );

      await _plugin.initialize(settings);
      await _configureLocalTimeZone();
      _initialized = true;
    } catch (_) {
      _initialized = false;
    }
  }

  Future<void> syncDailyReminder(AppSettings settings) async {
    try {
      await initialize();
      if (!_initialized) {
        return;
      }

      if (!settings.remindersEnabled) {
        await cancelDailyReminder();
        return;
      }

      final permissionsGranted = await _requestPermissions();
      if (!permissionsGranted) {
        return;
      }

      final scheduledDate = _nextInstanceOfTime(
        settings.reminderHour,
        settings.reminderMinute,
      );

      const details = NotificationDetails(
        android: AndroidNotificationDetails(
          AppConstants.reminderChannelId,
          AppConstants.reminderChannelName,
          channelDescription: AppConstants.reminderChannelDescription,
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
        macOS: DarwinNotificationDetails(),
      );

      await _plugin.zonedSchedule(
        AppConstants.reminderNotificationId,
        'Pocket Shift',
        'Pause for a breath and notice what pocket today is in.',
        scheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (_) {
      // Quiet failure keeps reminder setup from becoming disruptive.
    }
  }

  Future<void> cancelDailyReminder() async {
    try {
      await _plugin.cancel(AppConstants.reminderNotificationId);
    } catch (_) {
      // Quiet failure keeps the app usable even when notifications are unavailable.
    }
  }

  Future<void> _configureLocalTimeZone() async {
    if (_timeZoneReady) {
      return;
    }

    tz.initializeTimeZones();
    try {
      final timezoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezoneName));
    } catch (_) {
      // Keep the library default if a named timezone is unavailable.
    }
    _timeZoneReady = true;
  }

  Future<bool> _requestPermissions() async {
    try {
      final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      final iosPlugin = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      final macPlugin = _plugin.resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin>();

      final androidGranted = await androidPlugin?.requestNotificationsPermission();
      final iosGranted = await iosPlugin?.requestPermissions(
        alert: true,
        badge: false,
        sound: true,
      );
      final macGranted = await macPlugin?.requestPermissions(
        alert: true,
        badge: false,
        sound: true,
      );

      return [androidGranted, iosGranted, macGranted]
          .whereType<bool>()
          .fold<bool>(true, (value, next) => value && next);
    } catch (_) {
      return false;
    }
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    return scheduled;
  }
}
