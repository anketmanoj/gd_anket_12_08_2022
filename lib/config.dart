import 'package:diamon_rose_app/constants/appleSignInCheck.dart';
import 'package:diamon_rose_app/controllers/global_messages_controller.dart';
import 'package:diamon_rose_app/services/get_http_client.dart';
import 'package:diamon_rose_app/services/shared_preferences_helper.dart';
import 'package:dio/dio.dart';
// import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';

// import 'package:mared_social/constants/appleSignInCheck.dart';
// import 'package:mared_social/controllers/global_messages_controller.dart';
// import 'package:mared_social/services/get_http_client.dart';
// import 'package:mared_social/services/shared_preferences_helper.dart';

late final appleSignInAvailable;
final getIt = GetIt.instance;

config() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SystemChrome.setEnabledSystemUIOverlays([]);
  Stripe.publishableKey =
      "pk_test_51JaczJFX9V9rzaGSZhdkhBZ9btHj8Kp0GuggSluKf0lvIKqzpvJrTKjAVBz07t2Nk8TBBB2ukntbKZJk026M3n8t00aWAldRZJ";
  Stripe.merchantIdentifier = 'merchant.com.diamant.jp.diamond-app';
  await Stripe.instance.applySettings();
  await Firebase.initializeApp();
  // await FirebaseAppCheck.instance.activate(
  //   webRecaptchaSiteKey: 'recaptcha-v3-site-key',
  // );
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title

    importance: Importance.max,
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true, // Required to display a heads up notification
    badge: true,
    sound: true,
  );
  appleSignInAvailable = await AppleSignInAvailable.check();
  getIt.registerSingleton<Dio>(getHttpClient());
  SharedPreferencesHelper.initSharedPrefs();
  _defineGetxControllers();
}

_defineGetxControllers() {
  Get.put(GlobalMessagesController());
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
}
