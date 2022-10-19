import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:path/path.dart' as Path;
import 'package:path_provider/path_provider.dart';

///getExternalStoragePublicDirectory
enum extPublicDir {
  Music,
  PodCasts,
  Ringtones,
  Alarms,
  Notifications,
  Pictures,
  Movies,
  Download,
  DCIM,
  Documents,
  Screenshots,
  Audiobooks,
}

/// use in loop or without:
/// generation loop of a creation of the same directory in a list
/// public or shared folders by the Android system
/*
 for (var ext in extPublicDir.values) {

   ExtStorage.createFolderInPublicDir(
     type: ext,  //or without loop : extPublicDir.Download,
     folderName: "folderName",  // folder or folder/subFolder/... to create
   );

 }
*/
/// provided the ability to create folders and files within folders
/// public or shared from the Android system
///
/// /storage/emulated/0/Audiobooks
/// /storage/emulated/0/PodCasts
/// /storage/emulated/0/Ringtones
/// /storage/emulated/0/Alarms
/// /storage/emulated/0/Notifications
/// /storage/emulated/0/Pictures
/// /storage/emulated/0/Movies
/// storage/emulated/0/Download
/// /storage/emulated/0/DCIM
/// /storage/emulated/0/Documents
/// /storage/emulated/0/Screenshots  //Screenshots dropping ?
/// /storage/emulated/0/Music/

class ExtStorage {
  //According to path_provider
  static Future<String> get _directoryPathESD async {
    var directory = await getExternalStorageDirectory();
    if (directory != null) {
      log('directory:${directory.path}');

      return directory.path;
    }
    log('_directoryPathESD==null');

    return '';
  }

  /// create or not, but above all returns the created folder in a public folder
  /// official, folderName = '', only return the public folder: useful for
  /// manage a file at its root
  static Future<String> createFolderInPublicDir({
    required extPublicDir type,
    required String folderName,
  }) async {
    var _appDocDir = await _directoryPathESD;

    log("createFolderInPublicDir:_appDocDir:${_appDocDir.toString()}");

    var values = _appDocDir.split("${Platform.pathSeparator}");
    values.forEach(print);

    var dim = values.length - 4; // Android/Data/package.name/files
    _appDocDir = "";

    for (var i = 0; i < dim; i++) {
      _appDocDir += values[i];
      _appDocDir += "${Platform.pathSeparator}";
    }
    _appDocDir += "${type.toString().split('.').last}${Platform.pathSeparator}";
    _appDocDir += folderName;

    log("createFolderInPublicDir:_appDocDir:$_appDocDir");

    if (await Directory(_appDocDir).exists()) {
      log("createFolderInPublicDir:reTaken:$_appDocDir");

      return _appDocDir;
    } else {
      log("createFolderInPublicDir:toCreate:$_appDocDir");
      //if folder not exists create folder and then return its path
      final _appDocDirNewFolder =
          await Directory(_appDocDir).create(recursive: true);
      final pathNorma = Path.normalize(_appDocDirNewFolder.path);
      log("createFolderInPublicDir:ToCreate:pathNorma:$pathNorma");

      return pathNorma;
    }
  }
}
