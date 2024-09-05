import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rosedine/providers/meal_provider.dart';

ProviderContainer? _container;

@pragma('vm:entry-point')
void notificationCallback(int id) async {
  print('Notification callback triggered with ID: $id');
  if (_container == null) {
    _container = ProviderContainer();
  }
  NotificationService.fetchNotifiedItems(_container!);
}

class NotificationService {
  static Future<void> scheduleNotificationService(WidgetRef ref) async {
    print('Scheduling notification service...');
    if (!kIsWeb) {
      final bool isPermissionGranted = await Permission.scheduleExactAlarm.isGranted;

      if (isPermissionGranted) {
        print('SCHEDULE_EXACT_ALARM permission granted');
        final now = DateTime.now();
        final notificationTime = DateTime(now.year, now.month, now.day, 7, 30);
        print('Current time: $now');
        print('Notification time: $notificationTime');

        if (notificationTime.isBefore(now)) {
          final tomorrowNotificationTime = notificationTime.add(Duration(days: 1));
          print('Scheduling notification for tomorrow at ${tomorrowNotificationTime.toString()}');
          await AndroidAlarmManager.oneShotAt(
            tomorrowNotificationTime,
            0,
            notificationCallback,
            exact: true,
            wakeup: true,
          );
        } else {
          print('Scheduling notification for today at ${notificationTime.toString()}');
          await AndroidAlarmManager.oneShotAt(
            notificationTime,
            0,
            notificationCallback,
            exact: true,
            wakeup: true,
          );
        }
      } else {
        print('SCHEDULE_EXACT_ALARM permission not granted, requesting permission...');
        await Permission.scheduleExactAlarm.request();
        final bool isPermissionGrantedAfterRequest = await Permission.scheduleExactAlarm.isGranted;

        if (isPermissionGrantedAfterRequest) {
          print('SCHEDULE_EXACT_ALARM permission granted after request');
          scheduleNotificationService(ref);
        } else {
          print('SCHEDULE_EXACT_ALARM permission denied after request');
        }
      }
    } else {
      print('Skipping exact alarm scheduling on the web.');
    }
  }

  @pragma('vm:entry-point')
  static Future<void> fetchNotifiedItems(ProviderContainer container) async {
    print('Fetching notified items...');
    await container.read(recommendationsNotifierProvider.notifier).fetchNotificationFoods();
    final notifiedItems = container.read(recommendationsNotifierProvider)['notificationFoods'];
    print('Fetched Notified Items: $notifiedItems');
    showNotification(notifiedItems);
  }

  static Future<void> showNotification(List<dynamic> notifiedItems) async {
    print('Showing notification...');
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@android:drawable/ic_dialog_info');
    const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    List<String> lines = [];
    for (var item in notifiedItems) {
      lines.add('${item['name']} (${item['mealType']})');
    }

    final AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      styleInformation: InboxStyleInformation(
        lines,
        contentTitle: 'Favourites Available!',
        summaryText: 'RoseDine Favourites for today.',
      ),
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

     NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      'Notified Items',
      'You have new items',
      platformChannelSpecifics,
    );
    print('Notification shown');
  }
}
