import 'dart:developer';

import 'package:hotkey_manager/hotkey_manager.dart';

class HotKeys {
  /// [HotKeys] object instance. Must call [HotKeys.initialize].
  static HotKeys instance = HotKeys();

  static Future<void> initialize() async {
    await Future.wait(
      [
        HotKeyManager.instance.register(
          _spaceHotkey,
          keyDownHandler: (_) {
            log("enableSpaceHotKey initialize");
          },
        ),
      ],
    );
  }

  Future<void> disableSpaceHotKey() async {
    await HotKeyManager.instance.unregister(_spaceHotkey);
  }

  Future<void> enableSpaceHotKey() async {
    await HotKeyManager.instance.register(
      _spaceHotkey,
      keyDownHandler: (_) {
        log("enableSpaceHotKey");
      },
    );
  }
}

final _spaceHotkey = HotKey(
  KeyCode.space,
  scope: HotKeyScope.inapp,
);
