ダイアモンドローズアプリ

## 開発環境

### Version

- Flutter: `2.2.0`
- Dart: `2.13.3`

### BuildMode と Flavor

| 種類   | Flavor      | ビルドモード | Configurations or BuildType |
| :----- | :---------- | :----------- | :-------------------------- |
| 開発   | Development | Debug        | Development                 |
| テスト | Staging     | Production   | Production                  |

### Prepare to Build iOS

run `sh ./bin/build_ios.sh`

## Freezed: Running the code generator

run command `flutter pub run build_runner build`
(use param `--delete-conflicting-outputs` if needed)

## Generate strings:

1. Open gitbash.

2. run command `sh ./bin/translate.sh`

## Firebase Messaging Plugin for Flutter

1. Add dependency

```dart
dependencies:
  firebase_core: ^1.6.0
  firebase_messaging: ^10.0.7
```

2. Download dependency

```dart
 flutter pub get
```

3. Integration

- main.dart add Firebase initializeApp and requesting permission

```dart
Future<void> main() async {
  // Add this line
  await Firebase.initializeApp();

  // Add this line
  await FirebaseMessaging.instance.requestPermission();

  runApp(Application());
}
```

- app.dart

```dart
Future<void> _asyncMethod(BuildContext context) async {
    await FirebaseCloudMessagingHandler(
      localy: Localy.of(context)!,
      onTapMessage: () {},
    ).init();
  }

@override
  Widget build(BuildContext context) {
    ...
    builder: (context, child) {
        _asyncMethod(context);
    },
    ...
  }
```

- create file firebase_cloud_messaging_handler.dart to initMessaging

```dart
Future<void> initMessaging() async {
    FirebaseMessaging.onMessage.listen((message) async {
      debugPrint('onMessage: ${message.notification} >>> ${message.data}');
      await _handleForegroundMessage(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) async {
      debugPrint('onMessageOpenedApp: ${message.data}');

      ///Todo(param): yet undetermined
      onTapMessage();
    });

    await _flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(
        android:
            AndroidInitializationSettings('mipmap/ic_notification_default'),
        iOS: IOSInitializationSettings(),
        macOS: MacOSInitializationSettings(),
      ),
      onSelectNotification: (String? payload) async {
        if (payload == null) {
          return;
        }
        debugPrint('selectNotification! >> $payload');

        ///Todo(param): yet undetermined
        onTapMessage();
      },
    );

    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      debugPrint('initialMessage: ${initialMessage.data}');

      ///Todo(param): yet undetermined
      onTapMessage();
    }
  }
```

| State      |                                                                                                                         Description                                                                                                                          |
| ---------- | :----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------: |
| Foreground |                                                                                                       When the application is open, in view & in use.                                                                                                        |
| Background | When the application is open, however in the background (minimised). This typically occurs when the user has pressed the "home" button on the device, has switched to another app via the app switcher or has the application open on a different tab (web). |
| Terminated |                                        When the device is locked or the application is not running. The user can terminate an app by "swiping it away" via the app switcher UI on the device or closing a tab (web).                                         |

4. Create a Firebase project

5. Add Firebase to your Android app and Debug signing certificate SHA-1 (optional)

6. Download google-services.json and add a file into env development folder

7. Test

## Build and release an Android app

### 1. APK

1. build development

```
flutter build apk --flavor development --release
```

2. build production

```
flutter build apk --flavor production --release
```

### 2. AppBundle

1. build development

```
flutter build appbundle --flavor development --release
```

2. build production

```
flutter build appbundle --flavor production --release
```

## How to build for Android with VSCode

1. Open VS Code and choose Open a project or file
2. On .vscode\launch.json
3. Add line "args": [
   "--flavor",
   "development" //development or staging or production
   ]
   in `configurations`
4. Run project

## Build and release an IOS app

1. Open Xcode and choose Open a project or file
2. Open folder IOS on Project Flutter
3. Open Terminal and go to folder IOS
4. Run `flutter build ios`
5. On Xcode Click Build
   > - Wait until the process is complete
   > - If you run it wrong for the first time, please clean build folder
   > - In Xcode: `Click Product` -> `Clean Build Folder`
   > - After Build Again

## System architecture (Clean Architecture)

This project build on Clean Architecture includes 5 layers:

- Data
- Domain
- Presentation
- Share
- main.dart

## Details of System Architecture

### Data layer

- [config] - contain specific values of service server.
- [repository] - define repository interfaces repository.
- [validation] - contain common handle validate.

### Domain layer

- [cache] - contains cache manager common project.
- [entities] - contains object in the project.
- [rest-client] - Constant data handling methods
- [fcm] - handle the server's firebase message in the project
- [http] - where to handle each instance of http services returned
- [local_storage] - contains local storage common project.

### Presentation layer

- [navigation] - Provide a navigation widgets to manage and manipulate the stack when navigating the screens
- [screens] - contains the screens of the application

### Share layer

- [constants] - Constant values for sharing among the directory projects.
- [images] - Constant string link of image profile
- [localizations] - Contains common localization, support multi-language function
- [style] - The values declared for the application, they used in the layer of the screens and related to displaying on the interface such as colors, characters, etc...
- [utils] - provice the functions common.
- [widgets] - Declaring and building UI components.
