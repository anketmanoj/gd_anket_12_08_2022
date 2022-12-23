import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionsProvider extends ChangeNotifier {
  bool _permissionsGiven = true;
  bool get getPermissionsGive => _permissionsGiven;

  Future askForPermissions() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      late final Map<Permission, PermissionStatus> statusess;

      if (androidInfo.version.sdkInt! <= 32) {
        statusess = await [Permission.storage].request();
      } else {
        statusess = await [
          Permission.photos,
          Permission.notification,
          Permission.videos,
          Permission.audio,
          Permission.camera,
        ].request();
      }

      _permissionsGiven = true;
      notifyListeners();

      statusess.forEach((permission, status) {
        if (status != PermissionStatus.granted) {
          _permissionsGiven = false;
          notifyListeners();
        }
      });
    } else if (Platform.isIOS) {
      final result = await Permission.storage.request();
      if (result.isGranted) {
        _permissionsGiven = true;
        notifyListeners();
      } else {
        _permissionsGiven = false;
        notifyListeners();
      }
    }
  }
}
