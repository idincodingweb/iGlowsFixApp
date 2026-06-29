import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'notification_service.dart';

/// Service reminder lokal — TIDAK butuh server / FCM / Google Cloud.
///
/// Pakai `flutter_local_notifications` buat schedule notifikasi harian
/// (rutinitas pagi & malam) + weekly (skin score check). Setting
/// disimpan di SharedPreferences global (bukan per-user) supaya jadwal
/// tetap jalan walau user belum login.
///
/// Tiap fire-up juga mirror entri ke [NotificationService] (Firestore)
/// kalau user sedang login, jadi in-app inbox tetap update.
///
/// Fail-safe: semua method dibungkus try/catch dan return silent kalau
/// plugin belum tersedia / izin ditolak.
class ReminderService {
  ReminderService._();
  static final ReminderService instance = ReminderService._();

  static const _kEnabledMorning = 'reminder_morning_enabled';
  static const _kEnabledNight = 'reminder_night_enabled';
  static const _kEnabledWeekly = 'reminder_weekly_enabled';
  static const _kMorningHour = 'reminder_morning_hour';
  static const _kMorningMinute = 'reminder_morning_minute';
  static const _kNightHour = 'reminder_night_hour';
  static const _kNightMinute = 'reminder_night_minute';

  static const _idMorning = 1001;
  static const _idNight = 1002;
  static const _idWeekly = 1003;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    try {
      tzdata.initializeTimeZones();
      try {
        // Default ke WIB kalau gagal deteksi.
        tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
      } catch (_) {/* biarin default UTC */}

      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      const ios = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      await _plugin.initialize(
        const InitializationSettings(android: android, iOS: ios),
      );
      _initialized = true;
    } catch (e) {
      debugPrint('ReminderService.init error: $e');
    }
  }

  /// Request permission notifikasi (Android 13+ & iOS). Return true kalau
  /// dikasih atau gak butuh request.
  Future<bool> requestPermission() async {
    await init();
    try {
      if (Platform.isAndroid) {
        final impl = _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
        final granted = await impl?.requestNotificationsPermission();
        return granted ?? true;
      } else if (Platform.isIOS) {
        final impl = _plugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
        final granted = await impl?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? true;
      }
    } catch (e) {
      debugPrint('ReminderService.requestPermission error: $e');
    }
    return true;
  }

  // ---------- Settings ----------
  Future<ReminderSettings> loadSettings() async {
    try {
      final p = await SharedPreferences.getInstance();
      return ReminderSettings(
        morningEnabled: p.getBool(_kEnabledMorning) ?? true,
        nightEnabled: p.getBool(_kEnabledNight) ?? true,
        weeklyEnabled: p.getBool(_kEnabledWeekly) ?? true,
        morningHour: p.getInt(_kMorningHour) ?? 7,
        morningMinute: p.getInt(_kMorningMinute) ?? 0,
        nightHour: p.getInt(_kNightHour) ?? 21,
        nightMinute: p.getInt(_kNightMinute) ?? 0,
      );
    } catch (_) {
      return const ReminderSettings();
    }
  }

  Future<void> saveSettings(ReminderSettings s) async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setBool(_kEnabledMorning, s.morningEnabled);
      await p.setBool(_kEnabledNight, s.nightEnabled);
      await p.setBool(_kEnabledWeekly, s.weeklyEnabled);
      await p.setInt(_kMorningHour, s.morningHour);
      await p.setInt(_kMorningMinute, s.morningMinute);
      await p.setInt(_kNightHour, s.nightHour);
      await p.setInt(_kNightMinute, s.nightMinute);
    } catch (e) {
      debugPrint('ReminderService.saveSettings error: $e');
    }
  }

  /// Re-schedule semua reminder berdasarkan setting terbaru. Aman dipanggil
  /// berulang (cancel id yg sama dulu sebelum schedule).
  Future<void> applySchedules(ReminderSettings s) async {
    await init();
    try {
      await _plugin.cancel(_idMorning);
      await _plugin.cancel(_idNight);
      await _plugin.cancel(_idWeekly);

      if (s.morningEnabled) {
        await _scheduleDaily(
          id: _idMorning,
          hour: s.morningHour,
          minute: s.morningMinute,
          title: 'Rutinitas pagi ✨',
          body: 'Waktunya cleanser → toner → moisturizer → SPF. Glow up!',
          channelId: 'iglows_routine',
          channelName: 'Rutinitas Skincare',
        );
      }
      if (s.nightEnabled) {
        await _scheduleDaily(
          id: _idNight,
          hour: s.nightHour,
          minute: s.nightMinute,
          title: 'Rutinitas malam 🌙',
          body: 'Double cleanse + serum + night cream biar besok makin glowy.',
          channelId: 'iglows_routine',
          channelName: 'Rutinitas Skincare',
        );
      }
      if (s.weeklyEnabled) {
        await _scheduleWeekly(
          id: _idWeekly,
          weekday: DateTime.sunday,
          hour: 19,
          minute: 0,
          title: 'Cek skin score mingguan 💖',
          body: 'Yuk scan kulit kamu buat lihat progress minggu ini.',
          channelId: 'iglows_weekly',
          channelName: 'Skin Check Mingguan',
        );
      }
    } catch (e) {
      debugPrint('ReminderService.applySchedules error: $e');
    }
  }

  Future<void> cancelAll() async {
    try {
      await _plugin.cancelAll();
    } catch (_) {/* safe */}
  }

  /// Trigger manual buat user yg mau test reminder tanpa nunggu jam.
  /// Juga nge-push entri ke Firestore inbox kalau login.
  Future<void> fireTest() async {
    await init();
    try {
      await _plugin.show(
        9999,
        'Test reminder iGlows ✨',
        'Kalau kamu lihat ini, reminder lokal udah aktif.',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'iglows_test',
            'Test Reminder',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
      );
    } catch (e) {
      debugPrint('ReminderService.fireTest error: $e');
    }
    try {
      await NotificationService.instance.add(
        title: 'Test reminder ✨',
        body: 'Reminder lokal aktif. Schedule pagi/malam akan jalan otomatis.',
        kind: 'reminder',
      );
    } catch (_) {/* safe */}
  }

  // ---------- Internal ----------
  Future<void> _scheduleDaily({
    required int id,
    required int hour,
    required int minute,
    required String title,
    required String body,
    required String channelId,
    required String channelName,
  }) async {
    final when = _nextInstanceOf(hour, minute);
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      when,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> _scheduleWeekly({
    required int id,
    required int weekday,
    required int hour,
    required int minute,
    required String title,
    required String body,
    required String channelId,
    required String channelName,
  }) async {
    var when = _nextInstanceOf(hour, minute);
    while (when.weekday != weekday) {
      when = when.add(const Duration(days: 1));
    }
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      when,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  tz.TZDateTime _nextInstanceOf(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}

class ReminderSettings {
  final bool morningEnabled;
  final bool nightEnabled;
  final bool weeklyEnabled;
  final int morningHour;
  final int morningMinute;
  final int nightHour;
  final int nightMinute;

  const ReminderSettings({
    this.morningEnabled = true,
    this.nightEnabled = true,
    this.weeklyEnabled = true,
    this.morningHour = 7,
    this.morningMinute = 0,
    this.nightHour = 21,
    this.nightMinute = 0,
  });

  ReminderSettings copyWith({
    bool? morningEnabled,
    bool? nightEnabled,
    bool? weeklyEnabled,
    int? morningHour,
    int? morningMinute,
    int? nightHour,
    int? nightMinute,
  }) {
    return ReminderSettings(
      morningEnabled: morningEnabled ?? this.morningEnabled,
      nightEnabled: nightEnabled ?? this.nightEnabled,
      weeklyEnabled: weeklyEnabled ?? this.weeklyEnabled,
      morningHour: morningHour ?? this.morningHour,
      morningMinute: morningMinute ?? this.morningMinute,
      nightHour: nightHour ?? this.nightHour,
      nightMinute: nightMinute ?? this.nightMinute,
    );
  }
}
