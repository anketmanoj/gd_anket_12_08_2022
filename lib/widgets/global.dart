import 'dart:collection';
import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:diamon_rose_app/constants/Constantcolors.dart';
import 'package:diamon_rose_app/screens/PurchaseHistory/purchaseHistroy.dart';
import 'package:diamon_rose_app/screens/mainPage/mainpage.dart';
import 'package:diamon_rose_app/services/FirebaseOperations.dart';
import 'package:diamon_rose_app/services/GoogleSheetsAPI/controller.dart';
import 'package:diamon_rose_app/services/GoogleSheetsAPI/form.dart';
import 'package:diamon_rose_app/services/authentication.dart';
import 'package:diamon_rose_app/services/video.dart';
import 'package:diamon_rose_app/widgets/apple_pay.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sizer/sizer.dart';

ConstantColors constantColors = ConstantColors();

InAppWebViewController? webViewController;
InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
    crossPlatform: InAppWebViewOptions(
        useShouldOverrideUrlLoading: true,
        mediaPlaybackRequiresUserGesture: false),
    android: AndroidInAppWebViewOptions(
      useHybridComposition: true,
    ),
    ios: IOSInAppWebViewOptions(
      allowsInlineMediaPlayback: true,
    ));
final urlController = TextEditingController();
ValueNotifier<String> urlValue = ValueNotifier<String>("");
ValueNotifier<double> progressValue = ValueNotifier<double>(0);

ViewMenuWebApp(BuildContext context, String menuUrl, Authentication auth,
    FirebaseOperations firebaseOperations, Key key) async {
  // ignore: unawaited_futures
  showModalBottomSheet(
    context: context,
    isDismissible: false,
    isScrollControlled: true,
    enableDrag: false,
    builder: (context) {
      return AnimatedBuilder(
          animation: Listenable.merge([
            urlValue,
            progressValue,
          ]),
          builder: (context, _) {
            return Container(
              height: 95.h,
              width: 100.w,
              decoration: BoxDecoration(
                color: constantColors.black,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(15, 20, 0, 10),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: Get.back,
                          child: Text(
                            "Done",
                            style: TextStyle(
                              color: constantColors.bioBg,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: InAppWebView(
                      key: key,
                      onUpdateVisitedHistory: (controller, uri, _) async {
                        if (uri!.toString().contains("success")) {
                          log("success!");
                          // Payment succesful, now iterate through each video and AddtoMycollection

                          await FirebaseFirestore.instance
                              .collection("users")
                              .doc(auth.getUserId)
                              .collection("cart")
                              .get()
                              .then((cartDocs) {
                            cartDocs.docs.forEach((cartVideos) async {
                              final Video videoModel =
                                  Video.fromJson(cartVideos.data());

                              log("here ${videoModel.timestamp}");
                              log("amount transfered == ${(double.parse("${cartVideos['price'] * (1 - cartVideos['discountamount'] / 100) * 100}") / 100).toStringAsFixed(0)}");
                              try {
                                await firebaseOperations
                                    .addToMyCollectionFromCart(
                                  auth: auth,
                                  videoOwnerId: videoModel.useruid,
                                  amount: int.parse((double.parse(
                                              "${videoModel.price * (1 - videoModel.discountAmount / 100) * 100}") /
                                          100)
                                      .toStringAsFixed(0)),
                                  videoItem: videoModel,
                                  isFree: videoModel.isFree,
                                  videoId: videoModel.id,
                                );

                                log("success added to cart!");
                              } catch (e) {
                                log("error saving cart to my collection ${e.toString()}");
                              }

                              try {
                                await FirebaseFirestore.instance
                                    .collection("users")
                                    .doc(auth.getUserId)
                                    .collection("cart")
                                    .doc(cartVideos.id)
                                    .delete();

                                log("deleted");
                              } catch (e) {
                                log("error deleting cart  ${e.toString()}");
                              }
                            });
                          }).whenComplete(() {
                            log("done");
                            Get.back();
                            Get.back();
                          });
                          Get.snackbar(
                            'Diamond Sucessful 🎉',
                            'All video purchased have been added to your purchase history',
                            overlayColor: constantColors.navButton,
                            colorText: constantColors.whiteColor,
                            snackPosition: SnackPosition.TOP,
                            forwardAnimationCurve: Curves.elasticInOut,
                            reverseAnimationCurve: Curves.easeOut,
                          );

                          // ignore: unawaited_futures, cascade_invocations
                          Get.dialog(
                            SimpleDialog(
                              backgroundColor: constantColors.whiteColor,
                              title: Text(
                                "Your purchase was successfully completed.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: constantColors.black,
                                ),
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Text(
                                    "You can enjoy the purchased contents from your purchase history. Please enjoy!",
                                    textAlign: TextAlign.center,
                                    style:
                                        TextStyle(color: constantColors.black),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton(
                                          style: ButtonStyle(
                                            foregroundColor:
                                                MaterialStateProperty.all<
                                                    Color>(Colors.white),
                                            backgroundColor:
                                                MaterialStateProperty.all<
                                                        Color>(
                                                    constantColors.navButton),
                                            shape: MaterialStateProperty.all<
                                                RoundedRectangleBorder>(
                                              RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                            ),
                                          ),
                                          onPressed: () => Get.back(),
                                          child: Text(
                                            "Understood!",
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(
                                        child: ElevatedButton(
                                          style: ButtonStyle(
                                            foregroundColor:
                                                MaterialStateProperty.all<
                                                    Color>(Colors.white),
                                            backgroundColor:
                                                MaterialStateProperty.all<
                                                        Color>(
                                                    constantColors.navButton),
                                            shape: MaterialStateProperty.all<
                                                RoundedRectangleBorder>(
                                              RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                            ),
                                          ),
                                          onPressed: () {
                                            Get.back();
                                            Get.to(PurchaseHistoryScreen());
                                          },
                                          child: Text(
                                            "View Items",
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            barrierDismissible: false,
                          );

                          //  await Provider.of<FirebaseOperations>(context,
                          //           listen: false)
                          //       .addToMyCollection(
                          //     videoOwnerId: video.useruid,
                          //     amount: int.parse((double.parse(
                          //                 "${video.price * (1 - video.discountAmount / 100) * 100}") /
                          //             100)
                          //         .toStringAsFixed(0)),
                          //     videoItem: video,
                          //     isFree: video.isFree,
                          //     ctx: context,
                          //     videoId: video.id,
                          //   );

                          // log("amount transfered == ${(double.parse("${video.price * (1 - video.discountAmount / 100) * 100}") / 100).toStringAsFixed(0)}");

                        } else if (uri.toString().contains("cancel")) {
                          Get.back();
                          Get.back();
                          Get.snackbar(
                            'Video Cart Error',
                            'Error adding video to cart',
                            overlayColor: constantColors.navButton,
                            colorText: constantColors.whiteColor,
                            snackPosition: SnackPosition.TOP,
                            forwardAnimationCurve: Curves.elasticInOut,
                            reverseAnimationCurve: Curves.easeOut,
                          );
                        } else if (uri.toString().contains("applePay")) {
                          log(uri.toString() + "this");
                          final String totalPrice =
                              uri.toString().split("/").last;
                          Get.back();
                          Get.back();
                          log("price == $totalPrice");
                          Get.bottomSheet(ApplePayWidget(
                            totalPrice: totalPrice,
                          ));
                        } else if (uri.toString().contains('/logout')) {
                          log("logout user");
                          Get.back();
                          logOutDialog(context: context, auth: auth);
                        }
                      },
                      initialUrlRequest: URLRequest(
                        url: Uri.parse(menuUrl),
                      ),
                      initialUserScripts: UnmodifiableListView<UserScript>([]),
                      initialOptions: options,
                      onWebViewCreated: (controller) {
                        webViewController = controller;
                      },
                      onLoadStart: (controller, url) {
                        urlController.text = urlValue.value;
                      },
                      androidOnPermissionRequest:
                          (controller, origin, resources) async {
                        return PermissionRequestResponse(
                            resources: resources,
                            action: PermissionRequestResponseAction.GRANT);
                      },
                      shouldOverrideUrlLoading:
                          (controller, navigationAction) async {
                        var uri = navigationAction.request.url!;

                        if (![
                          "http",
                          "https",
                          "file",
                          "chrome",
                          "data",
                          "javascript",
                          "about"
                        ].contains(uri.scheme)) {
                          if (await canLaunch(menuUrl)) {
                            // Launch the App
                            await launch(
                              menuUrl,
                            );
                            // and cancel the request
                            return NavigationActionPolicy.CANCEL;
                          }
                        }

                        return NavigationActionPolicy.ALLOW;
                      },
                      onLoadStop: (controller, url) async {
                        urlValue.value = url.toString();
                        urlController.text = urlValue.value;
                      },
                      onLoadError: (controller, url, code, message) {},
                      onProgressChanged: (controller, progress) {
                        if (progress == 100) {}

                        progressValue.value = progress / 100;
                        urlController.text = urlValue.value;
                      },
                    ),
                  ),
                ],
              ),
            );
          });
    },
  );
}

dynamic logOutDialog(
    {required BuildContext context, required Authentication auth}) {
  return CoolAlert.show(
    context: context,
    backgroundColor: constantColors.darkColor,
    type: CoolAlertType.info,
    showCancelBtn: true,
    title: "Are you sure you want to log out?",
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

Widget ImageNetworkLoader({required String imageUrl, bool hide = false}) {
  return Stack(
    children: [
      Container(
        height: 100.h,
        width: 100.w,
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
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
    {required String text, required BuildContext context, bool? goBack}) {
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
    centerTitle: true,
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
                "Next",
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

  SubmitButton({
    Key? key,
    required this.function,
    this.text = "Submit",
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
  fullPathsForFiles.forEach((element) async {
    final File file = File(element);
    try {
      // ignore: avoid_slow_async_io
      if (await file.exists()) {
        await file.delete();
      }
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      print("error deleting == $e");
    }
  });
}

class VerifiedMark extends StatelessWidget {
  const VerifiedMark({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(3),
      height: 30,
      width: 30,
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
