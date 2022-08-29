import 'dart:isolate';

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
import 'package:diamon_rose_app/screens/VideoHomeScreen/bloc/preload_bloc.dart';
import 'package:diamon_rose_app/screens/VideoHomeScreen/core/build_context.dart';
import 'package:diamon_rose_app/screens/VideoHomeScreen/core/constants.dart';
import 'package:diamon_rose_app/screens/VideoHomeScreen/following_bloc/following_preload_bloc.dart';
import 'package:diamon_rose_app/screens/VideoHomeScreen/service/api_service.dart';
import 'package:diamon_rose_app/screens/VideoHomeScreen/service/navigation_service.dart';
import 'package:diamon_rose_app/screens/chatPage/old_chatCode/privateChatHelpers.dart';
import 'package:diamon_rose_app/screens/chatPage/old_chatCode/privateMessageHelper.dart';
import 'package:diamon_rose_app/screens/mainPage/mainpage_helpers.dart';
import 'package:diamon_rose_app/screens/searchPage/searchPageHelper.dart';
import 'package:diamon_rose_app/screens/splashscreen/splashscreen.dart';
import 'package:diamon_rose_app/services/ArVideoCreationService.dart';
import 'package:diamon_rose_app/services/FirebaseOperations.dart';
import 'package:diamon_rose_app/services/authentication.dart';
import 'package:diamon_rose_app/services/video.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart'
    as getTransition;
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
    child: MyApp(),
  ));
}

Future createIsolate(int index) async {
  // Set loading to true
  BlocProvider.of<PreloadBloc>(context, listen: false)
      .add(PreloadEvent.setLoading());
  BlocProvider.of<FollowingPreloadBloc>(context, listen: false)
      .add(FollowingPreloadEvent.setLoading());

  ReceivePort mainReceivePort = ReceivePort();

  Isolate.spawn<SendPort>(getVideosTask, mainReceivePort.sendPort);

  SendPort isolateSendPort = await mainReceivePort.first;

  ReceivePort isolateResponseReceivePort = ReceivePort();

  isolateSendPort.send([index, isolateResponseReceivePort.sendPort]);

  final isolateResponse = await isolateResponseReceivePort.first;
  final _urls = isolateResponse;

  // Update new urls
  BlocProvider.of<PreloadBloc>(context, listen: false)
      .add(PreloadEvent.updateUrls(_urls));
  BlocProvider.of<FollowingPreloadBloc>(context, listen: false)
      .add(FollowingPreloadEvent.updateUrls(_urls));
}

void getVideosTask(SendPort mySendPort) async {
  ReceivePort isolateReceivePort = ReceivePort();

  mySendPort.send(isolateReceivePort.sendPort);

  await for (var message in isolateReceivePort) {
    if (message is List) {
      final int index = message[0];

      final SendPort isolateResponseSendPort = message[1];
      await ApiService.load();

      final List<Video> _urls =
          await ApiService.getVideos(id: index + kPreloadLimit);

      isolateResponseSendPort.send(_urls);
    }
  }
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);
  final NavigationService _navigationService = getIt<NavigationService>();
  @override
  Widget build(BuildContext context) {
    final ConstantColors constantColors = ConstantColors();
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              getIt<PreloadBloc>()..add(PreloadEvent.getVideosFromApi()),
        ),
        BlocProvider(
          create: (_) => getIt<FollowingPreloadBloc>()
            ..add(FollowingPreloadEvent.getVideosFromApi()),
        ),
      ],
      child: MultiProvider(
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
              navigatorKey: _navigationService.navigationKey,
              defaultTransition: getTransition.Transition.fadeIn,
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
      ),
    );
  }
}
