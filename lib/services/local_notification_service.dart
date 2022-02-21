import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  static void initialize(BuildContext context) {
    final InitializationSettings initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/you_icon_2'),
    );
    _notificationsPlugin.initialize(initializationSettings, onSelectNotification: (String? route) async {
      if (route != null) {
        Navigator.of(context).pushNamed(route);
      }
    });
  }

  static void display(RemoteMessage message) async {

    try {
      final id = DateTime.now().millisecondsSinceEpoch ~/1000;
      
      final NotificationDetails notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          'my_firebase_notification_id',
          'my_firebase_notification_channel',
          channelDescription: 'This is my channel',
          importance: Importance.max,
          priority: Priority.max,
        ),
      );
      
      await _notificationsPlugin.show(
          id,
          message.notification!.title,
          message.notification!.body,
          notificationDetails,
          payload: message.data['route'],
      );
    } on Exception catch (e) {
      print(e);
    }
  }

}