import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  // Notification ID namespace (must fit in int32):
  //   service log:      10_000_000 + (serviceId * 10) + dayCode
  //   vehicle document: 20_000_000 + (docId * 10) + dayCode
  // dayCode is the H- offset (0 = today, 1 = H-1, 7 = H-7).
  static const int _serviceBase = 10000000;
  static const int _documentBase = 20000000;
  static const List<int> _dayOffsets = [7, 1, 0];
  static const int _reminderHour = 9; // fire at 09:00 local time

  static const String _channelId = 'kendaraanku_reminders';
  static const String _channelName = 'Pengingat Servis & Dokumen';
  static const String _channelDesc =
      'Pengingat servis berikutnya dan masa berlaku dokumen kendaraan.';

  Future<void> init() async {
    if (_initialized) return;

    tzdata.initializeTimeZones();
    try {
      final localTz = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(localTz));
    } catch (e) {
      debugPrint('NotificationService: timezone lookup failed: $e');
    }

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            _channelId,
            _channelName,
            description: _channelDesc,
            importance: Importance.high,
          ),
        );

    _initialized = true;
  }

  Future<bool> requestPermission() async {
    if (!_initialized) await init();

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      final granted = await androidPlugin.requestNotificationsPermission();
      return granted ?? true;
    }
    final iosPlugin = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (iosPlugin != null) {
      final granted = await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? true;
    }
    return true;
  }

  // ─── Service log reminders ───────────────────────────────────────────────

  Future<void> scheduleServiceReminder({
    required int serviceLogId,
    required String description,
    required String vehicleName,
    required DateTime nextServiceDate,
  }) async {
    await _scheduleSet(
      baseId: _serviceBase + (serviceLogId * 10),
      target: nextServiceDate,
      title: 'Saatnya servis: $description',
      body: vehicleName,
    );
  }

  Future<void> cancelServiceReminder(int serviceLogId) async {
    final base = _serviceBase + (serviceLogId * 10);
    for (final off in _dayOffsets) {
      await _plugin.cancel(base + off);
    }
  }

  // ─── Document expiry reminders ───────────────────────────────────────────

  Future<void> scheduleDocumentReminder({
    required int documentId,
    required String documentType,
    required String vehicleName,
    required DateTime expiryDate,
  }) async {
    await _scheduleSet(
      baseId: _documentBase + (documentId * 10),
      target: expiryDate,
      title: '$documentType akan habis masa berlakunya',
      body: vehicleName,
    );
  }

  Future<void> cancelDocumentReminder(int documentId) async {
    final base = _documentBase + (documentId * 10);
    for (final off in _dayOffsets) {
      await _plugin.cancel(base + off);
    }
  }

  // ─── Internal ────────────────────────────────────────────────────────────

  Future<void> _scheduleSet({
    required int baseId,
    required DateTime target,
    required String title,
    required String body,
  }) async {
    if (!_initialized) await init();
    final now = tz.TZDateTime.now(tz.local);

    for (final off in _dayOffsets) {
      final id = baseId + off;
      await _plugin.cancel(id);

      final fireDay = target.subtract(Duration(days: off));
      final fireAt = tz.TZDateTime(
        tz.local,
        fireDay.year,
        fireDay.month,
        fireDay.day,
        _reminderHour,
      );
      if (!fireAt.isAfter(now)) continue;

      final dayLabel = off == 0
          ? 'hari ini'
          : off == 1
              ? 'besok'
              : '$off hari lagi';

      try {
        await _plugin.zonedSchedule(
          id,
          title,
          '$body · jatuh tempo $dayLabel',
          fireAt,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              _channelId,
              _channelName,
              channelDescription: _channelDesc,
              importance: Importance.high,
              priority: Priority.high,
            ),
            iOS: DarwinNotificationDetails(),
          ),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      } catch (e) {
        debugPrint('NotificationService: failed to schedule $id: $e');
      }
    }
  }
}
