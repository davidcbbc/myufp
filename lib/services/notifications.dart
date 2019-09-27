


import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future _showNotification(FlutterLocalNotificationsPlugin notifications , {
  @required String title,
  @required String body,
  @required NotificationDetails type,
  int id = 0,
}) => notifications.show(id, title, body, type);

Future showOnGoingNotification(FlutterLocalNotificationsPlugin notifications , {
  @required String title,
  @required String body,
  int id = 0,
}) => _showNotification(notifications , title: title, body: body , id: id , type: _ongoing);

NotificationDetails get _ongoing {
  final androidChannelSpecifics = AndroidNotificationDetails(
    'your channel id', 
    'your channel name', 
    'your channel description',
    importance: Importance.Max,
    priority: Priority.High,
    ongoing: true,
    autoCancel: true,
  );
  final iOSChannelSpecifics = IOSNotificationDetails();
  return NotificationDetails(androidChannelSpecifics, iOSChannelSpecifics);

}