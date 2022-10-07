import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:diamon_rose_app/constants/styles/colors.dart';
import 'package:diamon_rose_app/share/localizations/l10n/localy.dart';
import 'package:diamon_rose_app/widgets/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart' hide Trans;
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

double widthScreen({int? percent}) =>
    percent != null ? (Get.width * percent) / 100 : Get.width;

// String getLocalize(String key, {List<String> args = const []}) =>
//     key.trArgs(args);

double heightScreen({double? percent}) =>
    percent != null ? (Get.height * percent) / 100 : Get.height;

Future<T?> goTo<T>(
        {required String screen,
        dynamic argument,
        int? id,
        dynamic parameter,
        bool preventDuplicates = false}) async =>
    await Get.toNamed<T>(screen,
        arguments: argument,
        id: id,
        parameters: parameter,
        preventDuplicates: preventDuplicates);

Future? goToAndRemove({
  required String screen,
  dynamic argument,
  dynamic parameter,
}) =>
    Get.offNamed(screen, arguments: argument);

Future? goToAndRemoveAll({
  required String screen,
  dynamic argument,
  dynamic parameter,
}) =>
    Get.offAllNamed(screen, arguments: argument, parameters: parameter);

// Future<void> showToast(String content) =>
//     EasyLoading.showToast(getLocalize(content));

Future<void> showLoading() => EasyLoading.show();

Future<void> dismissLoading() => EasyLoading.dismiss();

void goBack({dynamic argument}) => Get.back(result: argument);

Future<dynamic> readConfig(String filename) async {
  final assetPath = 'android/app/src/main/assets/$filename';
  final response = await rootBundle.loadString(assetPath);
  final data = await json.decode(response);

  return data;
}

Future<void> showConfirmDialog({
  required BuildContext context,
  String? message,
  String? title,
  String? negativeLabel,
  String? positiveLabel,
  bool onlyActionRight = false,
  double? textSize,
  TextAlign? textAlign,
  required Function() action,
}) async {
  return showDialog<void>(
    context: context,
    barrierColor: Colors.black.withOpacity(0.5),
    builder: (BuildContext context) {
      return ConfirmDialog(
        title: title ?? "test",
        context: context,
        action: () {
          print("okay");
        },
        message: "message",
        negativeLabel: "negativeLabel",
        positiveLabel: "positiveLabel",
        textAlign: TextAlign.center,
        textSize: 16,
        onlyActionRight: false,
      );
    },
  );
}

Future<void> showErrorConfirmDialog({
  required BuildContext context,
  required List<String> errors,
  TextAlign? textAlign,
}) {
  final stringErrorList = errors.join("\n");
  return showConfirmDialog(
      title: "Toitle",
      context: context,
      textAlign: textAlign,
      message: stringErrorList,
      action: () {},
      onlyActionRight: true);
}

Future<void> delay({required int seconds}) async {
  await Future.delayed(Duration(seconds: seconds));
}

Future<File> genThumbnailFile(String path) async {
  final fileName = await VideoThumbnail.thumbnailFile(
    video: path,
    thumbnailPath: (await getTemporaryDirectory()).path,
    imageFormat: ImageFormat.PNG,
    maxHeight: 100,
    quality: 75,
  );
  return File(fileName!);
}

Future<T?> showBottomSheetDefault<T>({
  required BuildContext context,
  required Widget widget,
  Color? barrierColor,
  Color? backgroundColor,
  bool? isScrollControlled,
  double paddingTop = 24,
  double paddingBottom = 24,
  double borderRadius = 20,
}) async {
  final result = await showModalBottomSheet<T>(
      context: context,
      barrierColor: barrierColor ?? Colors.transparent,
      backgroundColor:
          backgroundColor ?? AppColors.bottomSheetColor.withOpacity(0.3),
      isScrollControlled: isScrollControlled ?? true,
      shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(borderRadius))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
              top: paddingTop,
              bottom: MediaQuery.of(context).viewInsets.bottom + paddingBottom),
          child: widget,
        );
      });
  return result;
}

Future<String> getDirPath() async {
  final directory = await getApplicationSupportDirectory();
  return directory.path;
  // TODO(Test): Test merge video.
}

enum SnackBarType { success, danger, warning, info }

Future<void> showSnackBar({
  required String message,
  required SnackBarType snackBarType,
}) async {
  Get.snackbar(message, "",
      messageText: Container(),
      backgroundColor: _getColor(snackBarType),
      colorText: AppColors.white,
      duration: Duration(milliseconds: 2000));
}

Color _getColor(SnackBarType snackBarType) {
  switch (snackBarType) {
    case SnackBarType.success:
      return AppColors.darkPurple;
    case SnackBarType.danger:
      return AppColors.red.withOpacity(0.5);
    case SnackBarType.warning:
      return AppColors.yellow;
    case SnackBarType.info:
      return AppColors.blue;
  }
}

Future<double> getImageRatio(String url) async {
  final Completer<double> completer = Completer();
  final Image image = Image.network(url);
  image.image.resolve(ImageConfiguration()).addListener(
    ImageStreamListener(
      (ImageInfo image, bool synchronousCall) {
        final myImage = image.image;
        completer
            .complete(myImage.width.toDouble() / myImage.height.toDouble());
      },
    ),
  );
  return completer.future;
  // }
}

/// Get list days of month
List<int> listOfDates(int year, int month) =>
    new List<int>.generate(daysInMonth(DateTime(year, month)), (i) => i + 1);

int daysInMonth(DateTime date) {
  final firstDayThisMonth = new DateTime(date.year, date.month, date.day);
  final firstDayNextMonth = new DateTime(firstDayThisMonth.year,
      firstDayThisMonth.month + 1, firstDayThisMonth.day);
  return firstDayNextMonth.difference(firstDayThisMonth).inDays;
}

/// Get list years between first to last
List<String> listOfYears(int first, int last) {
  final List<String> _list = [];
  for (int i = first; i <= last; i++) {
    _list.add(i.toString());
  }
  return _list;
}
