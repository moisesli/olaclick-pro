import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PushNotificationService {
  static FirebaseMessaging messaging = FirebaseMessaging.instance;
  static String? token;
  static String? tokenIOS;
  static StreamController<String> _messageStream =
      new StreamController.broadcast();

  static Stream<String> get messagesStream => _messageStream.stream;

  static Future _backgroundHandler(RemoteMessage message) async {
    print("_backgroundHandler ${message.data}");
    _messageStream.add(message.notification!.body ?? '');
  }

  static Future _onMessageHandler(RemoteMessage message) async {
    print("app abierta ${message.data}");

    _messageStream.add(message.notification!.body ?? '');
  }

  static Future _onMessageOpenApp(RemoteMessage message) async {
    print("_onMessageOpenApp ${message.messageId}");
    _messageStream.add(message.notification!.body ?? '');
  }

  static Future initializeApp() async {
    await Firebase.initializeApp();
    var appo = Firebase.app();
    print(appo);

    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (Platform.isAndroid) {
      messaging.getToken().then((token) {
        print('[getToken] token: $token');
        prefs.setString('tokenPush', token!);
      }).catchError((onError) {
        print('[getToken] onError: $onError');
      });
    } else if (Platform.isIOS) {
      await messaging.requestPermission();
      tokenIOS = await messaging.getAPNSToken();
      prefs.setString('tokenIOS', tokenIOS!);
      print(
        '[getTokeniOS] APNS: $tokenIOS',
      );
    }

    FirebaseMessaging.onBackgroundMessage(_backgroundHandler);
    FirebaseMessaging.onMessage.listen(_onMessageHandler);
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenApp);
  }

  static closeStreams() {
    _messageStream.close();
  }
}
