import 'package:cool_alert/cool_alert.dart';
import 'package:diamon_rose_app/providers/social_media_links_provider.dart';
import 'package:diamon_rose_app/services/FirebaseOperations.dart';
import 'package:diamon_rose_app/services/authentication.dart';
import 'package:diamon_rose_app/widgets/global.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class SocialMediaLinks extends StatefulWidget {
  const SocialMediaLinks({Key? key}) : super(key: key);

  @override
  State<SocialMediaLinks> createState() => _SocialMediaLinksState();
}

class _SocialMediaLinksState extends State<SocialMediaLinks> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    final socialMediaLinks =
        Provider.of<SocialMediaLinksProvider>(context, listen: false);

    final TextEditingController _instagramController =
        TextEditingController(text: socialMediaLinks.instagramUrl);
    final TextEditingController _twitterController =
        TextEditingController(text: socialMediaLinks.twitterUrl);
    final TextEditingController _youtubeController =
        TextEditingController(text: socialMediaLinks.youtubeUrl);
    final TextEditingController _urlController =
        TextEditingController(text: socialMediaLinks.url);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBarWidget(text: "Social Media Links", context: context),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: ProfileUserDetails(
                    prefixIcon: Icon(FontAwesomeIcons.globe),
                    onSubmit: socialMediaLinks.setUrl(url: _urlController.text),
                    controller: _urlController,
                    showHintText: "Start with http:// or https://",
                    labelText: "Your Website",
                    validator: (value) {
                      if (value!.isNotEmpty) {
                        String pattern =
                            r'(http|https)://[\w-]+(\.[\w-]+)+([\w.,@?^=%&amp;:/~+#-]*[\w@?^=%&amp;/~+#-])?';
                        RegExp regExp = new RegExp(pattern);
                        if (!regExp.hasMatch(value)) {
                          return 'Url must start with http:// or https://';
                        } else {
                          return null;
                        }
                      }

                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: ProfileUserDetails(
                    prefixIcon: Icon(
                      FontAwesomeIcons.youtube,
                      color: Colors.red,
                    ),
                    showPrefixText: "www.youtube.com/c/",
                    onSubmit: socialMediaLinks.setYoutubeUrl(
                        youtubeUrl: _youtubeController.text),
                    controller: _youtubeController,
                    labelText: "Youtube Channel",
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: ProfileUserDetails(
                    prefixIcon: GradientIcon(
                      FontAwesomeIcons.instagram,
                      30.0,
                      LinearGradient(
                        colors: <Color>[
                          Colors.yellow,
                          Colors.red,
                          Colors.blue,
                        ],
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      ),
                    ),
                    onSubmit: socialMediaLinks.setInstagramUrl(
                        instagramUrl: _instagramController.text),
                    controller: _instagramController,
                    labelText: "Instagram Id",
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: ProfileUserDetails(
                    prefixIcon: Icon(
                      FontAwesomeIcons.twitter,
                      color: Colors.blue,
                    ),
                    onSubmit: socialMediaLinks.setTwitterUrl(
                        twitterUrl: _twitterController.text),
                    controller: _twitterController,
                    labelText: "Twitter Id",
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                SubmitButton(function: () async {
                  if (_formKey.currentState!.validate()) {
                    // ignore: unawaited_futures
                    showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text("Updating Links"),
                        content: Text("Please wait while we update your data"),
                      ),
                    );
                    try {
                      await Provider.of<FirebaseOperations>(context,
                              listen: false)
                          .updateSocialMediaLinks(
                        uid: Provider.of<Authentication>(context, listen: false)
                            .getUserId,
                        instagramUrl:
                            _instagramController.text.replaceAll(' ', ''),
                        twitterUrl: _twitterController.text.replaceAll(' ', ''),
                        youtubeUrl: _youtubeController.text.replaceAll(' ', ''),
                        url: _urlController.text.replaceAll(' ', ''),
                      );

                      socialMediaLinks.setSocialMediaLinks(
                          instagramUrl:
                              _instagramController.text.replaceAll(' ', ''),
                          twitterUrl:
                              _twitterController.text.replaceAll(' ', ''),
                          youtubeUrl:
                              _youtubeController.text.replaceAll(' ', ''),
                          url: _urlController.text.replaceAll(' ', ''));

                      Navigator.pop(context);

                      showTopSnackBar(
                        context,
                        CustomSnackBar.success(
                          message: "Your links have been updated!",
                        ),
                      );
                      // ignore: avoid_catches_without_on_clauses
                    } catch (e) {
                      Navigator.pop(context);
                      // ignore: unawaited_futures
                      CoolAlert.show(
                        context: context,
                        type: CoolAlertType.error,
                        title: "Sign In Failed",
                        text: e.toString(),
                      );
                    }
                  }
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
