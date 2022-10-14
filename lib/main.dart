import 'dart:async';
import 'dart:developer';
import 'dart:isolate';

import 'package:camera/camera.dart';
import 'package:diamon_rose_app/Navigation/router.dart';
import 'package:diamon_rose_app/config.dart';
import 'package:diamon_rose_app/constants/Constantcolors.dart';
import 'package:diamon_rose_app/constants/appleSignInCheck.dart';
import 'package:diamon_rose_app/providers/adminCreateVideoProvider.dart';
import 'package:diamon_rose_app/providers/caratsProvider.dart';
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
import 'package:diamon_rose_app/services/portraitMixin.dart';
import 'package:diamon_rose_app/services/video.dart';
import 'package:diamon_rose_app/translations/codegen_loader.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
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
  await runZonedGuarded(() async {
    await config();

    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

    cameras = await availableCameras();

    runApp(Provider<AppleSignInAvailable>.value(
      value: appleSignInAvailable,
      child: EasyLocalization(
        supportedLocales: [Locale('en'), Locale('ja')],
        path:
            'assets/translations', // <-- change the path of the translation files
        fallbackLocale: Locale('en'),
        saveLocale: true,
        assetLoader: CodegenLoader(),

        child: MyApp(),
      ),
    ));
  },
      (error, stack) =>
          FirebaseCrashlytics.instance.recordError(error, stack, fatal: true));
}

// Future createIsolate(int currentLen) async {
//   /// Where I listen to the message from Mike's port
//   ReceivePort myReceivePort = ReceivePort();

//   /// Spawn an isolate, passing my receivePort sendPort
//   Isolate.spawn<SendPort>(heavyComputationTask, myReceivePort.sendPort);

//   /// Mike sends a senderPort for me to enable me to send him a message via his sendPort.
//   /// I receive Mike's senderPort via my receivePort
//   SendPort mikeSendPort = await myReceivePort.first;

//   /// I set up another receivePort to receive Mike's response.
//   ReceivePort mikeResponseReceivePort = ReceivePort();

//   /// I send Mike a message using mikeSendPort. I send him a list,
//   /// which includes my message, preferred type of coffee, and finally
//   /// a sendPort from mikeResponseReceivePort that enables Mike to send a message back to me.
//   await ApiService.loadNextFreeOnly();
//   final List<Video> _urls = await ApiService.getVideos();
//   final List<Video> newList = _urls.sublist(currentLen, _urls.length);
//   mikeSendPort.send([
//     "Mike, I'm taking an Espresso coffee",
//     newList,
//     mikeResponseReceivePort.sendPort
//   ]);

//   /// I get Mike's response by listening to mikeResponseReceivePort
//   final mikeResponse = await mikeResponseReceivePort.first;
//   log("MIKE'S RESPONSE: ==== $mikeResponse");
// }

// void heavyComputationTask(SendPort mySendPort) async {
//   /// Set up a receiver port for Mike
//   ReceivePort mikeReceivePort = ReceivePort();

//   /// Send Mike receivePort sendPort via mySendPort
//   mySendPort.send(mikeReceivePort.sendPort);

//   /// Listen to messages sent to Mike's receive port
//   await for (var message in mikeReceivePort) {
//     if (message is List) {
//       final myMessage = message[0];
//       final videoList = message[1];
//       log(myMessage);

//       /// Get Mike's response sendPort
//       final SendPort mikeResponseSendPort = message[2];

//       /// Send Mike's response via mikeResponseSendPort
//       mikeResponseSendPort.send(videoList.toString());
//       getIt<PreloadBloc>()..add(PreloadEvent.updateUrls(videoList));
//     }
//   }
// }

Future createIsolate(int index) async {
  // Set loading to true
  // BlocProvider.of<PreloadBloc>(context, listen: false)
  //     .add(PreloadEvent.setLoading(true));
  // BlocProvider.of<FollowingPreloadBloc>(context, listen: false)
  //     .add(FollowingPreloadEvent.setLoading(true));

  ReceivePort mainReceivePort = ReceivePort();

  Isolate.spawn<SendPort>(getVideosTask, mainReceivePort.sendPort);

  SendPort isolateSendPort = await mainReceivePort.first;

  ReceivePort isolateResponseReceivePort = ReceivePort();

  await ApiService.loadNextFreeOnly();
  final List<Video> _urlList = await ApiService.getVideos();
  final List<Video> newList = _urlList.sublist(index, _urlList.length);
  log("index == $index | urlLen = ${_urlList.length} || new == ${newList.length}");

  isolateSendPort.send([
    index,
    isolateResponseReceivePort.sendPort,
    newList,
  ]);

  final isolateResponse = await isolateResponseReceivePort.first;
  final _urls = isolateResponse;

  // Update new urls
  BlocProvider.of<PreloadBloc>(context, listen: false)
      .add(PreloadEvent.updateUrls(_urls));
  // BlocProvider.of<FollowingPreloadBloc>(context, listen: false)
  //     .add(FollowingPreloadEvent.updateUrls(_urls));
}

void getVideosTask(SendPort mySendPort) async {
  ReceivePort isolateReceivePort = ReceivePort();

  mySendPort.send(isolateReceivePort.sendPort);

  await for (var message in isolateReceivePort) {
    if (message is List) {
      final int index = message[0];
      final SendPort isolateResponseSendPort = message[1];
      final List<Video> newList = message[2];

      isolateResponseSendPort.send(newList);
    }
  }
}

class MyApp extends StatelessWidget with PortraitModeMixin {
  MyApp({Key? key}) : super(key: key);
  final NavigationService _navigationService = getIt<NavigationService>();
  @override
  Widget build(BuildContext context) {
    super.build(context);
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
          ChangeNotifierProvider(create: (_) => AdminVideoCreator()),
          ChangeNotifierProvider(create: (_) => CaratProvider()),
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
              supportedLocales: context.supportedLocales,
              localizationsDelegates: context.localizationDelegates,
              locale: context.locale,
              themeMode: ThemeMode.light,
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
