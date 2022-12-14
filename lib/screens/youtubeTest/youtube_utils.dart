import 'dart:developer';
import 'dart:io';
import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_kit.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class YoutubeUtil {
  late final _yt;
  late final FFmpegKit _flutterFFmpeg;
  late String url;
  var video;
  bool videoLoaded = false;

  YoutubeUtil() {
    this._yt = new YoutubeExplode();
    _flutterFFmpeg = new FFmpegKit();
  }

  void cleanUp() {
    this._yt.close();
  }

  Future<bool> loadVideo(String url) async {
    try {
      this.url = url;
      this.video = await _yt.videos.get(url);
      videoLoaded = true;
      return true;
    } catch (e) {
      print("Error occurred: " + e.toString());
      return false;
    }
  }

  String getVideoAuthor() {
    if (videoLoaded)
      return this.video.author;
    else
      return "No video loaded";
  }

  String getVideoTitle() {
    if (videoLoaded)
      return this.video.title;
    else
      return "No video loaded";
  }

  String getVideoThumbnailUrl() {
    if (videoLoaded) {
      try {
        return this.video.thumbnails.highResUrl;
      } catch (e) {
        return "";
      }
    } else
      return "No video loaded";
  }

  Future<String> getSaveLocation() async {
    final downloadsDirectory = await getApplicationDocumentsDirectory();
    return downloadsDirectory.toString();
  }

  Future<bool> downloadMP3() async {
    try {
      // Get the video manifest and audio streams
      final manifest = await _yt.videos.streamsClient.getManifest(url);
      log("Here now?");
      print(manifest.audioOnly);
      final audioStream = manifest.audioOnly.last;

      // Build the directory.
      final downloadsDirectory = await getApplicationDocumentsDirectory();

      var filePath = path.join(downloadsDirectory!.path,
          '${video.title}.${audioStream.container.name}');

      filePath = filePath.replaceAll(' ', '');
      filePath = filePath.replaceAll("'", '');
      filePath = filePath.replaceAll('"', '');
      print(filePath);

      // Open the file to write.
      final file = File(filePath);
      final fileStream = file.openWrite();

      // Pipe all the content of the stream into our file.
      await _yt.videos.streamsClient.get(audioStream).pipe(fileStream);

      // Close the file.
      await fileStream.flush();
      await fileStream.close();

      // Convert webm or mp4 format to mp3
      print("starting convertion");
      List<String> arguments = [];
      if (filePath.endsWith('.mp4')) {
        arguments = ["-i", filePath, filePath.replaceAll('.mp4', '.mp3')];
      } else if (filePath.endsWith('.webm')) {
        arguments = ["-i", filePath, filePath.replaceAll('.webm', '.mp3')];
      } else if (filePath.endsWith('.mp3')) {
        print('Already .mp3');
        return true;
      } else {
        print('Unknown format to convert.');
        return false;
      }
      await FFmpegKit.executeWithArguments(arguments)
          .then((rc) => print("FFmpeg process exited with rc $rc"));

      //delete webm format
      if (filePath.endsWith('.webm') || filePath.endsWith('.mp4')) {
        file.delete();
      }

      print("Everything is fine!");
      return true;
    } catch (e) {
      print("Something went wrong.");
      return false;
    }
  }

  Future<File?> downloadMP3File() async {
    try {
      // Get the video manifest and audio streams
      final manifest = await _yt.videos.streamsClient.getManifest(url);
      log("Here now?");
      print(manifest.audioOnly);
      final audioStream = manifest.audioOnly.last;

      // Build the directory.
      final downloadsDirectory = await getApplicationDocumentsDirectory();

      var filePath = path.join(downloadsDirectory!.path,
          '${video.title}.${audioStream.container.name}');

      filePath = filePath.replaceAll(' ', '');
      filePath = filePath.replaceAll("'", '');
      filePath = filePath.replaceAll('"', '');
      print(filePath);

      // Open the file to write.
      final file = File(filePath);
      final fileStream = file.openWrite();
      late String outputFilePath;

      // Pipe all the content of the stream into our file.
      await _yt.videos.streamsClient.get(audioStream).pipe(fileStream);

      // Close the file.
      await fileStream.flush();
      await fileStream.close();

      // Convert webm or mp4 format to mp3
      print("starting convertion");
      List<String> arguments = [];
      if (filePath.endsWith('.mp4')) {
        arguments = ["-i", filePath, filePath.replaceAll('.mp4', '.mp3')];
        outputFilePath = filePath.replaceAll('.mp4', '.mp3');
      } else if (filePath.endsWith('.webm')) {
        arguments = ["-i", filePath, filePath.replaceAll('.webm', '.mp3')];
        outputFilePath = filePath.replaceAll('.webm', '.mp3');
      } else if (filePath.endsWith('.mp3')) {
        print('Already .mp3');
        outputFilePath = filePath;
        return File(outputFilePath);
      } else {
        print('Unknown format to convert.');
        return null;
      }
      await FFmpegKit.executeWithArguments(arguments).then((rc) {
        print("FFmpeg process exited with rc $rc");
        log("command : ${rc.getCommand()!}");
      });

      //delete webm format
      if (filePath.endsWith('.webm') || filePath.endsWith('.mp4')) {
        file.delete();
      }

      print("Everything is fine!");
      return File(outputFilePath);
    } catch (e) {
      print("Something went wrong");
      return null;
    }
  }
}
