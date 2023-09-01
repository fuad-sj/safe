import 'dart:typed_data';
import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:safe/firebase_status.dart';
import 'package:safe/models/FIREBASE_PATHS.dart';
import 'package:safe/models/MESSAGE_PAYLOAD.dart';
import 'package:safe/notification_audio.dart';
import 'package:safe/utils/pref_util.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// the pragma entry point is needed so tree shaking won't remove this apparently standalone function
@pragma('vm:entry-point')
Future<void> firebaseFCMBackgroundHandler(RemoteMessage message) async {
  notificationHandlerCallback(message, initializeFirebase: true);
}

Future<void> notificationDataCallback(Map<String, dynamic> payload,
    {bool initializeFirebase = false}) async {
  _notificationPayloadHandler_(payload, initializeFirebase: initializeFirebase);
}

Future<void> notificationHandlerCallback(RemoteMessage message,
    {bool initializeFirebase = false}) async {
  Map<String, dynamic> payload = message.data;

  print('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> payload arrived');
  print(payload);

  if (!payload.containsKey(MESSAGE_PAYLOAD.KEY_PAYLOAD_MESSAGE_TYPE)) return;

  _notificationPayloadHandler_(payload, initializeFirebase: initializeFirebase);
}

Future<void> _notificationPayloadHandler_(Map<String, dynamic> payload,
    {bool initializeFirebase = false}) async {
  if (initializeFirebase && !isGlobalFirebaseInitComplete) {
    await Firebase.initializeApp();
    isGlobalFirebaseInitComplete = true;
  }

  String messageType = payload[MESSAGE_PAYLOAD.KEY_PAYLOAD_MESSAGE_TYPE];

  String? notif_sound;

  switch (messageType) {
    case MESSAGE_PAYLOAD.MESSAGE_TYPE_TO_CUSTOMER_SHARED_RIDE_NEARBY_CREATED:
      String driver_name =
          payload[MESSAGE_PAYLOAD.DATA_KEY_NEARBY_SHARED_RIDE_DRIVER_NAME];
      String place_name =
          payload[MESSAGE_PAYLOAD.DATA_KEY_NEARBY_SHARED_RIDE_PLACE_NAME];
      String est_price =
          payload[MESSAGE_PAYLOAD.DATA_KEY_NEARBY_SHARED_RIDE_EST_PRICE];

      NotificationService.showMessageNotification("የ${place_name} የጋራ ጉዞ ጥሪ",
          'ከነበሩበት ቦታ ወደ ${place_name}, ${driver_name} በ${est_price} ብር እየጫነ ይገኛል። አኘሊኬሽን ዉስጥ ገብተው ያግኙት!',
          payload: driver_name);
      notif_sound = 'notif_arrived_sound';
      break;
  }

  if (notif_sound != null) {
    AudioPlayer player = (await NotifAudio.getInstance()).getAudioPlayer();
    AssetSource source = new AssetSource('$notif_sound.mp3');

    await player.stop();
    await player.play(source);
  }
}

class NotificationService {
  static const ORDER_NOTIF_CHANNEL_ID = 'safe_passenger_high_importance_channel';
  static const MSG_NOTIF_CHANNEL_ID = 'safe_passenger_notif_channel_id';

  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static const AndroidNotificationChannel androidNotificationChannel =
      const AndroidNotificationChannel(
    ORDER_NOTIF_CHANNEL_ID, // id
    'High Importance Notifications', // title
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
  );

  static Future<void> configureLocalTimeZone() async {
    tz.initializeTimeZones();
    final String? timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName!));
  }

  static Future<void> init() async {
    await configureLocalTimeZone();

    final AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    IOSInitializationSettings iosInitializationSettings =
    IOSInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification: null,
    );

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
          iOS: iosInitializationSettings,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  static void showMessageNotification(String title, String body,
      {String? payload}) async {
    final Int64List vibrationPattern = Int64List(5);
    vibrationPattern[0] = 0;
    vibrationPattern[1] = 1000;
    vibrationPattern[2] = 2500;
    vibrationPattern[3] = 1000;
    vibrationPattern[2] = 3500;

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          MSG_NOTIF_CHANNEL_ID,
          'Channel for Consuming Message Notifications',
          icon: 'ic_launcher',
          playSound: true,
          enableVibration: true,
          vibrationPattern: vibrationPattern,
          color: const Color.fromARGB(255, 191, 36, 74),
          importance: Importance.max,
          priority: Priority.max,
        ),
      ),
      payload: payload,
    );
  }
}
