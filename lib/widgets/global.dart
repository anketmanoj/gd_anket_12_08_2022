import 'dart:collection';
import 'dart:developer';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:diamon_rose_app/constants/Constantcolors.dart';
import 'package:diamon_rose_app/providers/caratsProvider.dart';
import 'package:diamon_rose_app/screens/PostPage/PostDetailScreen.dart';
import 'package:diamon_rose_app/screens/ProfilePage/update_email_screen.dart';
import 'package:diamon_rose_app/screens/ProfilePage/update_password_screen.dart';
import 'package:diamon_rose_app/screens/PurchaseHistory/purchaseHistroy.dart';
import 'package:diamon_rose_app/screens/closeAccount/closeAccountScreen.dart';
import 'package:diamon_rose_app/screens/mainPage/mainpage.dart';
import 'package:diamon_rose_app/screens/testVideoEditor/imgseqanimation.dart';
import 'package:diamon_rose_app/services/FirebaseOperations.dart';
import 'package:diamon_rose_app/services/GoogleSheetsAPI/controller.dart';
import 'package:diamon_rose_app/services/GoogleSheetsAPI/form.dart';
import 'package:diamon_rose_app/services/authentication.dart';
import 'package:diamon_rose_app/services/dbService.dart';
import 'package:diamon_rose_app/services/dynamic_link_service.dart';
import 'package:diamon_rose_app/services/myArCollectionClass.dart';
import 'package:diamon_rose_app/services/shared_preferences_helper.dart';
import 'package:diamon_rose_app/services/video.dart';
import 'package:diamon_rose_app/translations/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart' hide Trans;
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sizer/sizer.dart';

ConstantColors constantColors = ConstantColors();

String formatHHMMSS(double seconds) {
  if (seconds != null && seconds != 0) {
    double hours = (seconds / 3600);
    seconds = (seconds % 3600);
    double minutes = (seconds / 60);

    String hoursStr = (hours).toString().padLeft(2, '0');
    String minutesStr = (minutes).toString().padLeft(2, '0');
    String secondsStr = (seconds % 60).toString().padLeft(2, '0');

    if (hours == 0) {
      return "00:$minutesStr:$secondsStr";
    }
    return "$hoursStr:$minutesStr:$secondsStr";
  } else {
    return "";
  }
}

const String kConsumableId0 = 'gd_carats_1';
const String kConsumableId1 = 'gd_carats_5';
const String kConsumableId2 = 'gd_carats_10';
const String kConsumableId3 = 'gd_carats_30';
const String kConsumableId4 = 'gd_carats_55';
const String kConsumableId5 = 'gd_carats_80';
// const String _kConsumableId6 = 'gd_carats_222';
// const String _kConsumableId7 = 'gd_carats_312';
// const String _kConsumableId8 = 'gd_carats_555';

const Set<String> kProductIdiOS = {
  'gd_caratval_1',
  'gd_carat_5',
  'gd_carat_10',
  'gd_carat_30',
  'gd_carat_55',
  'gd_carat_80',
};

const List<String> kProductIdAndroid = <String>[
  kConsumableId0,
  kConsumableId1,
  kConsumableId2,
  kConsumableId3,
  kConsumableId4,
  kConsumableId5,
];
// Auto-consume must be true on iOS.
// To try without auto-consume on another platform, change `true` to `false` here.
final bool kAutoConsume = Platform.isIOS || true;

showScreenshotWarningMsg() async {
  final bool showMessage = SharedPreferencesHelper.getBool("screenshotWarning");

  if (showMessage == false) {
    final ValueNotifier<bool> dontShowMessage = ValueNotifier<bool>(false);
    await Get.dialog(
      SimpleDialog(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              "Screenshot detected",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: constantColors.navButton,
                fontSize: 16,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              "Abusing the creators content by illegally sharing this content is a breach of the terms and conditions of Glamorous Diastation",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: constantColors.navButton,
                fontSize: 16,
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          ValueListenableBuilder<bool>(
              valueListenable: dontShowMessage,
              builder: (context, messageOpt, _) {
                return ListTile(
                  title: Text("Dont show message again"),
                  trailing: Checkbox(
                    value: dontShowMessage.value,
                    onChanged: (v) {
                      dontShowMessage.value = !dontShowMessage.value;
                    },
                  ),
                );
              }),
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: ElevatedButton(
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                backgroundColor:
                    MaterialStateProperty.all<Color>(constantColors.navButton),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              onPressed: () {
                SharedPreferencesHelper.setBool(
                    "screenshotWarning", dontShowMessage.value);
                Get.back();
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check,
                    color: Colors.white,
                  ),
                  Text(
                    LocaleKeys.understood.tr(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

showScreenrecordWarningMsg() async {
  final bool showMessage =
      SharedPreferencesHelper.getBool("screenrecordWarning");

  if (showMessage == false) {
    final ValueNotifier<bool> dontShowMessage = ValueNotifier<bool>(false);
    await Get.dialog(
      SimpleDialog(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              "Screenrecord detected",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: constantColors.navButton,
                fontSize: 16,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              "Abusing the creators content by illegally sharing this content is a breach of the terms and conditions of Glamorous Diastation",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: constantColors.navButton,
                fontSize: 16,
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          ValueListenableBuilder<bool>(
              valueListenable: dontShowMessage,
              builder: (context, messageOpt, _) {
                return ListTile(
                  title: Text("Dont show message again"),
                  trailing: Checkbox(
                    value: dontShowMessage.value,
                    onChanged: (v) {
                      dontShowMessage.value = !dontShowMessage.value;
                    },
                  ),
                );
              }),
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: ElevatedButton(
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                backgroundColor:
                    MaterialStateProperty.all<Color>(constantColors.navButton),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              onPressed: () {
                SharedPreferencesHelper.setBool(
                    "screenrecordWarning", dontShowMessage.value);
                Get.back();
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check,
                    color: Colors.white,
                  ),
                  Text(
                    LocaleKeys.understood.tr(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

List<Shadow> outlinedText(
    {double strokeWidth = 0.75,
    Color strokeColor = Colors.black,
    int precision = 5}) {
  Set<Shadow> result = HashSet();
  for (int x = 1; x < strokeWidth + precision; x++) {
    for (int y = 1; y < strokeWidth + precision; y++) {
      double offsetX = x.toDouble();
      double offsetY = y.toDouble();
      result.add(Shadow(
          offset: Offset(-strokeWidth / offsetX, -strokeWidth / offsetY),
          color: strokeColor));
      result.add(Shadow(
          offset: Offset(-strokeWidth / offsetX, strokeWidth / offsetY),
          color: strokeColor));
      result.add(Shadow(
          offset: Offset(strokeWidth / offsetX, -strokeWidth / offsetY),
          color: strokeColor));
      result.add(Shadow(
          offset: Offset(strokeWidth / offsetX, strokeWidth / offsetY),
          color: strokeColor));
    }
  }
  return result.toList();
}

final urlController = TextEditingController();
ValueNotifier<String> urlValue = ValueNotifier<String>("");
ValueNotifier<double> progressValue = ValueNotifier<double>(0);

void runARCommand({required MyArCollection myAr}) {
  final String audioFile = myAr.audioFile;

  // ignore: cascade_invocations
  final String folderName = audioFile.split(myAr.id).toList()[0];
  final String fileName = "${myAr.id}imgSeq";

  Get.to(() => ImageSeqAniScreen(
        folderName: folderName,
        fileName: fileName,
        MyAR: myAr,
      ));
}

dynamic logOutDialog(
    {required BuildContext context, required Authentication auth}) {
  return CoolAlert.show(
    context: context,
    backgroundColor: constantColors.darkColor,
    type: CoolAlertType.info,
    showCancelBtn: true,
    title: LocaleKeys.areyousureyouwanttologout.tr(),
    confirmBtnText: "Log Out",
    onConfirmBtnTap: () {
      auth.facebookLogOut();
      auth.signOutWithGoogle();
      auth.logOutViaEmail().whenComplete(() {
        Get.offAll(() => MainPage());
      });
    },
    confirmBtnTextStyle: TextStyle(
      color: constantColors.whiteColor,
      fontWeight: FontWeight.bold,
      fontSize: 18,
    ),
    cancelBtnText: "No",
    cancelBtnTextStyle: TextStyle(
      color: constantColors.redColor,
      fontWeight: FontWeight.bold,
      fontSize: 18,
      decoration: TextDecoration.underline,
      decorationColor: constantColors.redColor,
    ),
    onCancelBtnTap: () => Navigator.pop(context),
  );
}

Widget ImageNetworkLoader(
    {required String imageUrl,
    bool hide = false,
    BoxFit fit = BoxFit.cover,
    int? cachedHeight,
    int? cachedWidth}) {
  return Stack(
    children: [
      Container(
        height: 100.h,
        width: 100.w,
        child: Image.network(
          imageUrl,
          fit: fit,
          cacheHeight: cachedHeight,
          gaplessPlayback: true,
          cacheWidth: cachedWidth,
          filterQuality: FilterQuality.low,
          isAntiAlias: false,
          loadingBuilder: (BuildContext context, Widget child,
              ImageChunkEvent? loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
          errorBuilder: (BuildContext context, val, _) {
            return Center(
              child: Icon(Icons.error),
            );
          },
        ),
      ),
      Visibility(
        visible: hide,
        child: Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              color: constantColors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(30),
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.lock_outline,
              color: constantColors.whiteColor,
              size: 30,
            ),
          ),
        ),
      )
    ],
  );
}

Widget ImageFileLoader(
    {required File imageUrl, bool hide = false, BoxFit fit = BoxFit.cover}) {
  return Stack(
    children: [
      Container(
        height: 100.h,
        width: 100.w,
        child: Image.file(
          imageUrl,
          fit: fit,
          cacheWidth: 0,
          cacheHeight: 0,
          gaplessPlayback: true,
          isAntiAlias: false,
          errorBuilder: (BuildContext context, val, _) {
            return Center(
              child: Icon(Icons.error),
            );
          },
        ),
      ),
      Visibility(
        visible: hide,
        child: Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              color: constantColors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(30),
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.lock_outline,
              color: constantColors.whiteColor,
              size: 30,
            ),
          ),
        ),
      )
    ],
  );
}

Widget privacyPolicyLinkAndTermsOfService() {
  return Container(
    alignment: Alignment.center,
    padding: EdgeInsets.all(10),
    child: Center(
      child: Text.rich(
        TextSpan(
          text: 'By continuing, you agree to our ',
          style: TextStyle(fontSize: 14, color: Colors.black),
          children: <TextSpan>[
            TextSpan(
              text: 'Terms of Service',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black,
                decoration: TextDecoration.underline,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () async {
                  final url =
                      'https://diamantrose.co.jp/en/works/glamorous-diastation/terms-en/termsofusegd/';
                  if (await canLaunch(url)) {
                    await launch(
                      url,
                      forceSafariVC: false,
                    );
                  }
                },
            ),
            TextSpan(
              text: ' and ',
              style: TextStyle(fontSize: 14, color: Colors.black),
              children: <TextSpan>[
                TextSpan(
                  text: 'Privacy Policy',
                  style: TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                      decoration: TextDecoration.underline),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () async {
                      final url =
                          'https://diamantrose.co.jp/en/works/glamorous-diastation/terms-en/privacypolicy/';
                      if (await canLaunch(url)) {
                        await launch(
                          url,
                          forceSafariVC: false,
                        );
                      }
                    },
                )
              ],
            )
          ],
        ),
        textAlign: TextAlign.center,
      ),
    ),
  );
}

class HeartAnimationwidget extends StatefulWidget {
  const HeartAnimationwidget(
      {Key? key,
      required this.child,
      required this.isAnimating,
      this.duration = const Duration(milliseconds: 300),
      this.onEnd})
      : super(key: key);
  final Widget child;
  final bool isAnimating;
  final Duration duration;
  final VoidCallback? onEnd;

  @override
  State<HeartAnimationwidget> createState() => _HeartAnimationwidgetState();
}

class _HeartAnimationwidgetState extends State<HeartAnimationwidget>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> scale;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.duration.inMilliseconds),
    );

    scale = Tween<double>(begin: 1.0, end: 1.2).animate(controller);
  }

  @override
  void didUpdateWidget(covariant HeartAnimationwidget oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);

    if (widget.isAnimating != oldWidget.isAnimating) {
      doAnimation();
    }
  }

  Future doAnimation() async {
    await controller.forward();

    if (widget.onEnd != null) {
      widget.onEnd!();
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ScaleTransition(
        scale: scale,
        child: widget.child,
      );
}

PreferredSizeWidget AppBarWidget(
    {required String text,
    required BuildContext context,
    bool? goBack,
    List<Widget>? actions,
    Widget? leadingWidget}) {
  final Size size = MediaQuery.of(context).size;
  return AppBar(
    automaticallyImplyLeading: goBack ?? true,
    backgroundColor: Colors.black,
    toolbarHeight: size.height * 0.12,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(80),
      ),
    ),
    leading: leadingWidget,
    centerTitle: true,
    actions: actions,
    title: Text(
      text,
      style: TextStyle(
        color: Colors.white,
      ),
    ),
  );
}

class ProfileUserDetails extends StatelessWidget {
  const ProfileUserDetails({
    Key? key,
    required this.controller,
    required this.labelText,
    this.validator,
    this.lines,
    required this.onSubmit,
    this.prefixIcon,
    this.hide,
    this.suffixIcon,
    this.showPrefixText,
    this.showHintText,
    this.keyboardTypeVal,
  }) : super(key: key);

  final TextEditingController controller;
  final String labelText;
  final String? Function(String?)? validator;
  final int? lines;
  final Function(String) onSubmit;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool? hide;
  final String? showPrefixText;
  final String? showHintText;
  final TextInputType? keyboardTypeVal;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      onChanged: onSubmit,
      obscureText: hide ?? false,
      maxLines: lines ?? 1,
      textAlign: TextAlign.start,
      keyboardType: keyboardTypeVal ?? TextInputType.text,
      decoration: InputDecoration(
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        labelText: labelText,
        prefixText: showPrefixText,
        hintText: showHintText,
        hintStyle: TextStyle(
          fontSize: 10,
        ),
        labelStyle: TextStyle(color: Colors.black),
        border: OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black),
          borderRadius: BorderRadius.circular(30),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black),
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      style: TextStyle(color: Colors.black),
      validator: validator ??
          (val) {
            return null;
          },
    );
  }
}

class GradientIcon extends StatelessWidget {
  GradientIcon(
    this.icon,
    this.size,
    this.gradient,
  );

  final IconData icon;
  final double size;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      child: SizedBox(
        child: Icon(
          icon,
          size: size,
          color: Colors.white,
        ),
      ),
      shaderCallback: (Rect bounds) {
        final Rect rect = Rect.fromLTRB(0, 0, size, size);
        return gradient.createShader(rect);
      },
    );
  }
}

Container bodyColor() {
  return Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: const [0.0, 0.5, 0.9],
        colors: [
          Color(0xFF760380),
          Color(0xFFE6ADFF),
          constantColors.whiteColor,
        ],
      ),
    ),
  );
}

class LoginIcon extends StatelessWidget {
  const LoginIcon({
    Key? key,
    required this.color,
    required this.icon,
    this.onTap,
  }) : super(key: key);

  final Color color;
  final IconData icon;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 40,
        decoration: BoxDecoration(
          border: Border.all(
            color: color,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color),
      ),
    );
  }
}

class VideoOptions extends StatelessWidget {
  const VideoOptions(
      {Key? key, required this.icon, required this.text, required this.onTap})
      : super(key: key);
  final IconData icon;
  final String text;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.15,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: Colors.white,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 40,
            ),
            Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NextButton extends StatelessWidget {
  void Function()? function;

  NextButton({
    Key? key,
    required this.function,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: function,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              child: Text(
                LocaleKeys.next.tr(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SubmitButton extends StatelessWidget {
  void Function()? function;
  String text;
  Color color;

  SubmitButton({
    Key? key,
    required this.function,
    this.color = Colors.black,
    this.text = "Submit",
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: function,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> deleteFile(List<String> fullPathsForFiles) async {
  for (String element in fullPathsForFiles) {
    final File file = File(element);
    try {
      // ignore: avoid_slow_async_io
      if (await file.exists()) {
        log("removeing from cni and dcm");
        await CachedNetworkImage.evictFromCache(file.path);
        await DefaultCacheManager().removeFile(file.path);
        await file.delete(recursive: true);
        log("done from cni and dcm");
      } else {
        log("############ doesnt exist ${file.path}");
      }
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      print("error deleting == $e");
    }
  }
}

class VerifiedMark extends StatelessWidget {
  const VerifiedMark({
    Key? key,
    this.height,
    this.width,
  }) : super(key: key);

  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(3),
      height: height ?? 30,
      width: width ?? 30,
      child: Image.asset(
        "assets/images/GD_mark.png",
      ),
    );
  }
}

// Method to Submit Feedback and save it in Google Sheets
void submitForm({
  required String date,
  required String username,
  required String email,
  required String paypalLink,
  required String amountToTransfer,
  required String amountGeneratedForGD,
}) {
  // If the form is valid, proceed.
  final PayoutForm payoutForm = PayoutForm(
    date,
    username,
    email,
    paypalLink,
    amountToTransfer,
    amountGeneratedForGD,
  );

  final PayoutController payoutController = PayoutController();

  // Submit 'payoutForm' and save it in Google Sheets.
  // ignore: cascade_invocations
  payoutController.submitForm(payoutForm, (String response) {
    print("Response: $response");
    if (response == PayoutController.STATUS_SUCCESS) {
      log("success!");
    } else {
      // Error Occurred while saving data in Google Sheets.
      log("error!");
    }
  });
}
