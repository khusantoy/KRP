import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:krp/controllers/quote_controller.dart';
import 'package:timezone/data/latest_all.dart' as tzl;
import 'package:timezone/timezone.dart' as tz;

class LocalNotificationsService {
  static final _localNotification = FlutterLocalNotificationsPlugin();

  static bool notificationEnabled = false;
  static Future<void> requestPermission() async {
    // Birinchi dasturimiz qaysi qurilmada run bo'layotganini tekshiramiz
    if (Platform.isIOS || Platform.isMacOS) {
      // Agar IOS bo'lsa unda shu kod orqali notification'ga ruxsat so'raymiz
      notificationEnabled = await _localNotification
              .resolvePlatformSpecificImplementation<
                  IOSFlutterLocalNotificationsPlugin>()
              ?.requestPermissions(alert: true, badge: true, sound: true) ??
          false;

      // Agar MacOS bo'lsa unda bu kod orqali notification'ga rxusat so'raymiz
      await _localNotification
          .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    } else if (Platform.isAndroid) {
      // Agar Android qurilma bo'lsa bu kod orqali android notification sozlamasini olamiz
      final androidImplementation =
          _localNotification.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      // va bu yerda darhol xabarnomasiga ruxsat so'raymiz
      final bool? grantedNotificationPermission =
          await androidImplementation?.requestNotificationsPermission();
      // bu yerda esa rejali xabarnomaga ruxsat so'raymiz
      notificationEnabled = grantedNotificationPermission ?? false;
      notificationEnabled = grantedNotificationPermission ?? false;
    }
  }

  static Future<void> start() async {
    // hozirgi joylashuv (timezone) bilan vaqtni oladi
    final currentTimeZone = await FlutterTimezone.getLocalTimezone();
    tzl.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation(currentTimeZone));

    // Android va IOS uchun sozlamalarni to'g'rilaymiz
    const androidInit = AndroidInitializationSettings(
        "mipmap/ic_launcher"); // mipmap/ic_launcher
    final iosInit = DarwinInitializationSettings(
      notificationCategories: [
        DarwinNotificationCategory(
          'demoCategory',
          actions: <DarwinNotificationAction>[
            DarwinNotificationAction.plain('id_1', 'Action 1'),
            DarwinNotificationAction.plain(
              'id_2',
              'Action 2',
              options: <DarwinNotificationActionOption>{
                DarwinNotificationActionOption.destructive,
              },
            ),
            DarwinNotificationAction.plain(
              'id_3',
              'Action 3',
              options: <DarwinNotificationActionOption>{
                DarwinNotificationActionOption.foreground,
              },
            ),
          ],
          options: <DarwinNotificationCategoryOption>{
            DarwinNotificationCategoryOption.hiddenPreviewShowTitle,
          },
        )
      ],
    );

    // Umumiy sozlamalarga e'lon qilaman
    final notificationInit = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    // va FlutterLocalNotification klassiga sozlamalrni yuborman u esa kerakli qurilma sozlamalarini to'g'rilaydi
    await _localNotification.initialize(notificationInit);
  }

  // static void showNotification() async {
  //   // Android iOS uchun qanday turdagi xabarlarni ko'rsatish kerakligini aytamiz
  //   const androidDetails = AndroidNotificationDetails(
  //     "goodChannelId",
  //     "goodChannelName",
  //     importance: Importance.max,
  //     priority: Priority.max,
  //     playSound: true,
  //     // sound: RawResourceAndroidNotificationSound("notification"),
  //     actions: [
  //       AndroidNotificationAction("id_1", "Action 1"),
  //       AndroidNotificationAction("id_2", "Action 2"),
  //       AndroidNotificationAction("id_3", "Action 3"),
  //     ],
  //   );

  //   const iosDetails = DarwinNotificationDetails(
  //     // sound: "notification.aiff",
  //     categoryIdentifier: "demoCategory",
  //   );

  //   const notificationDetails = NotificationDetails(
  //     android: androidDetails,
  //     iOS: iosDetails,
  //   );

  //   // show funksiyasi orqali xabarni ko'rsatamiz
  //   // await _localNotification.show(
  //   //   0,
  //   //   "Birinchi notification",
  //   //   "Body text",
  //   //   notificationDetails,
  //   // );

  //   await _localNotification.periodicallyShowWithDuration(
  //     0,
  //     "Birinchi NOTIFICATION",
  //     "Salom sizga \$1,000,000 pul tushdi. SMS kodni ayting!",
  //     const Duration(minutes: 1),
  //     notificationDetails,
  //     payload: "Salom",
  //   );
  // }

  static Future<void> showScheduledNotification() async {
    final quoteController = QuoteController();

    List<String> quotes = await quoteController.fetchQuotes();

    // Format the quotes as needed (e.g., join them into a single string)
    String quotesBody = quotes.join("\n");
    // android va ios uchun qanday
    // turdagi xabarlarni ko'rsatish kerakligni aytamiz
    const androidDetails = AndroidNotificationDetails(
      "goodChannelId",
      "goodChannelName",
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      // sound: RawResourceAndroidNotificationSound("notification"),
      ticker: "Ticker",
    );

    const iosDetails = DarwinNotificationDetails(
        // sound: "notification.aiff",
        );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // show funksiyasi orqali darhol xabarnoma ko'rsatamiz
    await _localNotification.zonedSchedule(
      0,
      "Daily Quote",
      quotesBody,
      getTime(),
      notificationDetails,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: "Salom",
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static tz.TZDateTime getTime() {
    tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    return tz.TZDateTime(tz.local, now.year, now.month, now.day + 1, 7, 59, 0);
  }

  static Future<void> scheduleTodoNotification(
      String id, String title, DateTime time) async {
    const androidDetails = AndroidNotificationDetails(
      "todoChannelId",
      "todoChannelName",
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails();

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotification.zonedSchedule(
      int.parse(id.hashCode.toString().substring(0, 9)),
      "Todo Reminder",
      title,
      tz.TZDateTime.from(time, tz.local),
      notificationDetails,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> cancelTodoNotification(String id) async {
    await _localNotification.cancel(int.parse(id.hashCode.toString().substring(0, 9)));
  }
}
