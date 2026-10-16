import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../data/models/task_model.dart';

class LocalNotificationService {
  LocalNotificationService._();

  static final LocalNotificationService instance = LocalNotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const macosSettings = DarwinInitializationSettings();

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
      macOS: macosSettings,
    );

    await _plugin.initialize(initSettings);
  }

  Future<void> scheduleTaskReminders(Task task) async {
    if (task.status == TaskStatus.selesai) {
      await cancelTaskReminders(task);
      return;
    }

    await cancelTaskReminders(task);

    final reminderOffsets = <Duration>[
      const Duration(days: 1),
      const Duration(hours: 12),
      const Duration(hours: 1),
    ];

    final now = tz.TZDateTime.now(tz.local);

    for (final offset in reminderOffsets) {
      final scheduledDateTime = tz.TZDateTime.from(task.deadline, tz.local).subtract(offset);
      if (scheduledDateTime.isBefore(now)) {
        continue;
      }

      await _plugin.zonedSchedule(
        _notificationIdForTask(task, offset),
        'Deadline Tugas Mendekat',
        '${task.title} harus dikumpulkan ${_reminderLabel(offset)}.',
        scheduledDateTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'task_deadline_channel',
            'Deadline tugas',
            channelDescription: 'Peringatan deadline tugas kuliah',
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
          macOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: null,
      );
    }
  }

  Future<void> cancelTaskReminders(Task task) async {
    final taskId = task.id ?? 0;
    final reminderOffsets = <Duration>[
      const Duration(days: 1),
      const Duration(hours: 12),
      const Duration(hours: 1),
    ];

    for (final offset in reminderOffsets) {
      await _plugin.cancel(_notificationIdForTaskId(taskId, offset));
    }
  }

  int _notificationIdForTaskId(int taskId, Duration reminder) {
    return (taskId * 1000) + reminder.inHours;
  }

  int _notificationIdForTask(Task task, Duration reminder) {
    return _notificationIdForTaskId(task.id ?? task.createdAt.millisecondsSinceEpoch, reminder);
  }

  String _reminderLabel(Duration duration) {
    if (duration == const Duration(days: 1)) return 'besok';
    if (duration == const Duration(hours: 12)) return '12 jam lagi';
    return '1 jam lagi';
  }
}
