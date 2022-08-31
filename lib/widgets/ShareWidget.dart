import 'package:diamon_rose_app/services/ShareButtons.dart';
import 'package:diamon_rose_app/widgets/global.dart';
import 'package:flutter/material.dart';
import 'package:flutter_share_me/flutter_share_me.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sizer/sizer.dart';

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

class ShareWidget extends StatelessWidget {
  ShareWidget({Key? key, required this.msg, required this.urlPath})
      : super(key: key);
  final String msg;
  final String urlPath;
  final bool videoEnable = true;

  @override
  Widget build(BuildContext context) {
    final List<ShareButtons> listOfShares = [
      ShareButtons(
        iconData: FontAwesomeIcons.facebook,
        onButtonTop: () => onButtonTap(Share.facebook),
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
        iconData: FontAwesomeIcons.facebookMessenger,
        onButtonTop: () => onButtonTap(Share.messenger),
      ),
      ShareButtons(
        iconData: FontAwesomeIcons.mobileScreenButton,
        onButtonTop: () => onButtonTap(Share.share_system),
      ),
    ];

    return Container(
      height: 50.h,
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
                    msg,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
              ),
              itemCount: listOfShares.length,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: listOfShares[index].onButtonTop,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: constantColors.navButton,
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      listOfShares[index].iconData,
                      size: 40,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> onButtonTap(Share share) async {
    String? response;
    final FlutterShareMe flutterShareMe = FlutterShareMe();
    switch (share) {
      case Share.facebook:
        response = await flutterShareMe.shareToFacebook(url: urlPath, msg: msg);
        break;
      case Share.messenger:
        response =
            await flutterShareMe.shareToMessenger(url: urlPath, msg: msg);
        break;
      case Share.twitter:
        response = await flutterShareMe.shareToTwitter(url: urlPath, msg: msg);
        break;
      case Share.whatsapp:
        if (urlPath != null) {
          response = await flutterShareMe.shareToWhatsApp(
              imagePath: urlPath,
              fileType: videoEnable ? FileType.video : FileType.image);
        } else {
          response = await flutterShareMe.shareToWhatsApp(msg: msg);
        }
        break;
      case Share.whatsapp_business:
        response = await flutterShareMe.shareToWhatsApp(msg: msg);
        break;
      case Share.share_system:
        response = await flutterShareMe.shareToSystem(msg: msg);
        break;
      case Share.whatsapp_personal:
        response = await flutterShareMe.shareWhatsAppPersonalMessage(
            message: msg, phoneNumber: 'phone-number-with-country-code');
        break;
      case Share.share_instagram:
        response = await flutterShareMe.shareToInstagram(
            filePath: urlPath, fileType: FileType.video);
        break;
      case Share.share_telegram:
        response = await flutterShareMe.shareToTelegram(msg: msg);
        break;
    }
    debugPrint(response);
  }
}
