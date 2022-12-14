import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:diamon_rose_app/services/ShareButtons.dart';
import 'package:diamon_rose_app/widgets/global.dart';
import 'package:dio/dio.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_kit_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_share_me/flutter_share_me.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart' as getF;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';
import 'package:path/path.dart';
import 'package:social_share/social_share.dart';
import 'package:screenshot/screenshot.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

///sharing platform
enum Share {
  facebook,
  messenger,
  twitter,
  whatsapp,
  whatsapp_personal,
  whatsapp_business,
  share_system,
  share_instagram,
  share_telegram
}

class ShareWidget extends StatefulWidget {
  ShareWidget({
    Key? key,
    required this.msg,
    required this.urlPath,
    required this.videoOwnerName,
    required this.canShareToSocialMedia,
  }) : super(key: key);
  final String msg;
  final String urlPath;
  final String videoOwnerName;
  final bool canShareToSocialMedia;

  @override
  State<ShareWidget> createState() => _ShareWidgetState();
}

class _ShareWidgetState extends State<ShareWidget> {
  final bool videoEnable = true;
  File? videoFile;
  late File thumbnailFile;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      if (widget.canShareToSocialMedia == true)
        await getImage(url: widget.urlPath);
    });
  }

  Future<void> getImage({required String url}) async {
    /// Get Image from server
    final Response res = await Dio().get<List<int>>(
      url,
      options: Options(
        responseType: ResponseType.bytes,
      ),
    );

    /// Get App local storage
    final Directory appDir = await getApplicationDocumentsDirectory();

    /// Generate Image Name
    final String imageName = url.split('/').last;

    /// Create Empty File in app dir & fill with new image
    final File file = File(join(appDir.path, imageName));
    file.writeAsBytesSync(res.data as List<int>);

    final response = await rootBundle.load('assets/images/GDlogo.png');
    final gdLogoFile = File(join(appDir.path, "GDlogo.png"));
    gdLogoFile.writeAsBytesSync(response.buffer.asUint8List());

    final String command =
        "-i ${file.path} -i ${gdLogoFile.path} -filter_complex \"[1]colorchannelmixer=aa=1,scale=iw*0.1:-1[a];[0:v][a]overlay=x=(main_w-overlay_w):y=(main_h-overlay_h)/(main_h-overlay_h)${Platform.isIOS ? ",drawtext=text='@${widget.videoOwnerName.trim()}':x=w*0.65:y=(h*0.115):fontsize=40:fontcolor=white:fix_bounds=True:borderw=2:bordercolor=black" : ""};[0:a]volume=1.0[a1]\" -map ''[a1]'' -crf 30 -preset faster -y -c:v libx264 ${appDir.path}/shareVideo.mp4";

    await FFmpegKit.execute(command).then((value) async {
      final String? output = await value.getOutput();

      log("output is ${output}");
    });

    final Uint8List? _thumbData = await VideoThumbnail.thumbnailData(
      imageFormat: ImageFormat.PNG,
      video: "${appDir.path}/shareVideo.mp4",
      maxHeight: 10,
      maxWidth: 10,
    );

    final videoThumbnailFile = File(join(appDir.path, "videoThumbnail.png"));
    videoThumbnailFile.writeAsBytesSync(_thumbData!);

    setState(() {
      videoFile = File("${appDir.path}/shareVideo.mp4");
      thumbnailFile = videoThumbnailFile;
    });

    log("video Url = ${videoFile!.path}");
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.canShareToSocialMedia) {
      case true:
        final List<ShareButtons> listOfShares = [
          ShareButtons(
            iconData: FontAwesomeIcons.facebook,
            onButtonTop: () {
              getF.Get.bottomSheet(
                Container(
                  height: 25.h,
                  decoration: BoxDecoration(
                    color: constantColors.whiteColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 150),
                        child: Divider(
                          thickness: 4,
                          color: constantColors.greyColor,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                String? response;
                                final FlutterShareMe flutterShareMe =
                                    FlutterShareMe();

                                await flutterShareMe.shareToFacebook(
                                    url: widget.msg, msg: widget.msg);
                              },
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.post_add_rounded,
                                    color: constantColors.navButton,
                                    size: 50,
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text("Facebook Post")
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                await SocialShare.shareFacebookStory(
                                  appId: "264465402552974",
                                  imagePath: thumbnailFile.path,
                                  backgroundResourcePath: videoFile!.path,
                                  attributionURL: widget.urlPath,
                                ).then((data) {
                                  log(data!);
                                });
                              },
                              child: Column(
                                children: [
                                  Icon(
                                    FontAwesomeIcons.video,
                                    color: constantColors.navButton,
                                    size: 50,
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text("Facebook Story")
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              );
              // onButtonTap(Share.facebook);
            },
          ),
          ShareButtons(
            iconData: FontAwesomeIcons.twitter,
            onButtonTop: () => onButtonTap(Share.twitter),
          ),
          ShareButtons(
            iconData: FontAwesomeIcons.whatsapp,
            onButtonTop: () => onButtonTap(Share.whatsapp),
          ),
          ShareButtons(
            iconData: FontAwesomeIcons.instagram,
            onButtonTop: () => onButtonTap(Share.share_instagram),
          ),
          ShareButtons(
            iconData: FontAwesomeIcons.mobileScreenButton,
            onButtonTop: () => onButtonTap(Share.share_system),
          ),
        ];

        return Container(
          height: 40.h,
          width: 100.w,
          decoration: BoxDecoration(
            color: constantColors.bioBg,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 150),
                  child: Divider(
                    thickness: 4,
                    color: constantColors.greyColor,
                  ),
                ),
                InkWell(
                  onTap: () => onButtonTap(Share.share_system),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Container(
                      alignment: Alignment.center,
                      height: 60,
                      width: 100.w,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        widget.msg,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                videoFile != null
                    ? Wrap(
                        spacing: (10 / 100.w * 100).w, //vertical spacing
                        runSpacing: 2.h, //horizontal spacing
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: listOfShares.map((shareVal) {
                          return InkWell(
                            onTap: shareVal.onButtonTop,
                            child: Container(
                              height: 10.h,
                              width: 20.w,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: constantColors.navButton,
                                  width: 1,
                                ),
                              ),
                              child: Icon(
                                shareVal.iconData,
                                size: 40,
                              ),
                            ),
                          );
                        }).toList(),
                      )
                    // GridView.builder(
                    //     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    //       crossAxisCount: 3,
                    //       crossAxisSpacing: 5,
                    //       mainAxisSpacing: 5,
                    //     ),
                    //     itemCount: listOfShares.length,
                    //     shrinkWrap: true,
                    //     physics: NeverScrollableScrollPhysics(),
                    //     itemBuilder: (context, index) {
                    //       return InkWell(
                    //         onTap: listOfShares[index].onButtonTop,
                    //         child: Container(
                    //           decoration: BoxDecoration(
                    //             border: Border.all(
                    //               color: constantColors.navButton,
                    //               width: 1,
                    //             ),
                    //           ),
                    //           child: Icon(
                    //             listOfShares[index].iconData,
                    //             size: 40,
                    //           ),
                    //         ),
                    //       );
                    //     },
                    //   )
                    : Expanded(
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
              ],
            ),
          ),
        );

      case false:
        return Container(
          height: 25.h,
          width: 100.w,
          decoration: BoxDecoration(
            color: constantColors.bioBg,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 150),
                  child: Divider(
                    thickness: 4,
                    color: constantColors.greyColor,
                  ),
                ),
                InkWell(
                  onTap: () => onButtonTap(Share.share_system),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Container(
                      alignment: Alignment.center,
                      height: 60,
                      width: 100.w,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        widget.msg,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );

      default:
        return Container(
          height: 25.h,
          width: 100.w,
          decoration: BoxDecoration(
            color: constantColors.bioBg,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
    }
  }

  Future<String?> screenshot() async {
    var data = await screenshotController.capture();
    if (data == null) {
      return null;
    }
    final tempDir = await getTemporaryDirectory();
    final assetPath = '${tempDir.path}/temp.png';
    File file = await File(assetPath).create();
    await file.writeAsBytes(data);
    return file.path;
  }

  ScreenshotController screenshotController = ScreenshotController();

  Future<void> onButtonTap(Share share) async {
    String? response;
    final FlutterShareMe flutterShareMe = FlutterShareMe();
    switch (share) {
      case Share.facebook:
        log("social share now!");

        await SocialShare.shareFacebookStory(
          appId: "264465402552974",
          imagePath: thumbnailFile.path,
          backgroundResourcePath: videoFile!.path,
          attributionURL: widget.urlPath,
        ).then((data) {
          print(data);
        });

        break;

      case Share.twitter:
        response = await flutterShareMe.shareToTwitter(
            url: widget.msg,
            msg: "Check out this video on Glamorous Diastation!");
        break;
      case Share.whatsapp:
        if (videoFile != null) {
          response = await flutterShareMe.shareToWhatsApp(
              imagePath: videoFile!.path, fileType: FileType.video);
        } else {
          response = await flutterShareMe.shareToWhatsApp(msg: widget.msg);
        }
        break;
      case Share.whatsapp_business:
        response = await flutterShareMe.shareToWhatsApp(msg: widget.msg);
        break;
      case Share.share_system:
        response = await flutterShareMe.shareToSystem(msg: widget.msg);
        break;
      case Share.whatsapp_personal:
        response = await flutterShareMe.shareWhatsAppPersonalMessage(
            message: widget.msg, phoneNumber: 'phone-number-with-country-code');
        break;
      case Share.share_instagram:
        response = await flutterShareMe.shareToInstagram(
            filePath: videoFile!.path, fileType: FileType.video);
        break;
      case Share.share_telegram:
        response = await flutterShareMe.shareToTelegram(msg: widget.msg);
        break;
    }
    debugPrint(response);
  }
}
