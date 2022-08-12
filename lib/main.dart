import 'package:camera/camera.dart';
import 'package:diamon_rose_app/Navigation/router.dart';
import 'package:diamon_rose_app/config.dart';
import 'package:diamon_rose_app/constants/Constantcolors.dart';
import 'package:diamon_rose_app/constants/appleSignInCheck.dart';
import 'package:diamon_rose_app/providers/feed_page_provider.dart';
import 'package:diamon_rose_app/providers/ffmpegProviders.dart';
import 'package:diamon_rose_app/providers/homeScreenProvider.dart';
import 'package:diamon_rose_app/providers/image_utils_provider.dart';
import 'package:diamon_rose_app/providers/recommendedProvider.dart';
import 'package:diamon_rose_app/providers/social_media_links_provider.dart';
import 'package:diamon_rose_app/providers/user_signup_provider.dart';
import 'package:diamon_rose_app/providers/video_editor_provider.dart';
import 'package:diamon_rose_app/screens/chatPage/old_chatCode/privateChatHelpers.dart';
import 'package:diamon_rose_app/screens/chatPage/old_chatCode/privateMessageHelper.dart';
import 'package:diamon_rose_app/screens/mainPage/mainpage_helpers.dart';
import 'package:diamon_rose_app/screens/searchPage/searchPageHelper.dart';
import 'package:diamon_rose_app/screens/splashscreen/splashscreen.dart';
import 'package:diamon_rose_app/services/ArVideoCreationService.dart';
import 'package:diamon_rose_app/services/FirebaseOperations.dart';
import 'package:diamon_rose_app/services/authentication.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
}

List<CameraDescription>? cameras;

// Trying the video editor out

// ignore: avoid_void_async
void main() async {
  await config();

  cameras = await availableCameras();

  runApp(Provider<AppleSignInAvailable>.value(
    value: appleSignInAvailable,
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ConstantColors constantColors = ConstantColors();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Authentication()),
        ChangeNotifierProvider(create: (_) => MainPageHelpers()),
        ChangeNotifierProvider(create: (_) => FirebaseOperations()),
        ChangeNotifierProvider(create: (_) => SignUpUser()),
        ChangeNotifierProvider(create: (_) => FeedPageHelpers()),
        ChangeNotifierProvider(create: (_) => SocialMediaLinksProvider()),
        ChangeNotifierProvider(create: (_) => ImageUtils()),
        ChangeNotifierProvider(create: (_) => PrivateChatHelpers()),
        ChangeNotifierProvider(create: (_) => PrivateMessageHelper()),
        ChangeNotifierProvider(create: (_) => SearchPageHelper()),
        ChangeNotifierProvider(create: (_) => RecommendedProvider()),
        ChangeNotifierProvider(create: (_) => FFmpegProvider()),
        ChangeNotifierProvider(create: (_) => VideoEditorProvider()),
        ChangeNotifierProvider(create: (_) => ArVideoCreation()),
        ChangeNotifierProvider(create: (_) => HomeScreenProvider()),
      ],
      child: Sizer(
        builder: (context, orientation, deviceType) {
          return GetMaterialApp(
            navigatorKey: Get.key,
            defaultTransition: Transition.fadeIn,
            home: WillPopScope(
              onWillPop: () async => false,
              child: SplashScreen(),
            ),
            builder: (context, child) {
              // Get.put(FcmViewModel(context: context));
              return FlutterEasyLoading(child: child);
            },
            getPages: Routers.route,
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              pageTransitionsTheme: PageTransitionsTheme(builders: {
                TargetPlatform.android: CupertinoPageTransitionsBuilder(),
                TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
              }),
              accentColor: constantColors.blueColor,
              fontFamily: "Poppins",
              canvasColor: Colors.transparent,
            ),
          );
        },
      ),
    );
  }
}
