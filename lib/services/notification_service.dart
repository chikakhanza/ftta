import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> scheduleCheckInReminder(DateTime checkIn, String homestayName) async {
    tz.initializeTimeZones();
    final scheduledDate = tz.TZDateTime.from(checkIn.subtract(const Duration(days: 1)), tz.local);
    await _plugin.zonedSchedule(
      checkIn.millisecondsSinceEpoch ~/ 1000, // unique id
      'Pengingat Check-in',
      'Besok Anda akan check-in di $homestayName',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails('checkin_channel', 'Check-in Reminder', importance: Importance.max, priority: Priority.high),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
} 