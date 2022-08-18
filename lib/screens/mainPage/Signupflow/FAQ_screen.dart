import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:diamon_rose_app/constants/Constantcolors.dart';
import 'package:diamon_rose_app/screens/feedPages/feedPage.dart';
import 'package:diamon_rose_app/services/FirebaseOperations.dart';
import 'package:diamon_rose_app/services/authentication.dart';
import 'package:diamon_rose_app/services/shared_preferences_helper.dart';
import 'package:diamon_rose_app/widgets/global.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

class FAQScreen extends StatelessWidget {
  FAQScreen({Key? key}) : super(key: key);

  final ConstantColors constantColors = ConstantColors();
  ValueNotifier<bool> _openQ1 = ValueNotifier<bool>(false);
  ValueNotifier<bool> _openQ2 = ValueNotifier<bool>(false);
  ValueNotifier<bool> _openQ3 = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBarWidget(text: "Frequently Asked Questions", context: context),
      backgroundColor: constantColors.whiteColor,
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: SingleChildScrollView(
          child: AnimatedBuilder(
              animation: Listenable.merge([
                _openQ1,
                _openQ2,
                _openQ3,
              ]),
              builder: (context, childVal) {
                return Column(
                  children: [
                    InkWell(
                      onTap: () {
                        _openQ1.value = !_openQ1.value;
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        height: 100,
                        width: 100.w,
                        decoration: BoxDecoration(
                          color: constantColors.bioBg,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Sign Up Issue",
                              style: TextStyle(
                                color: constantColors.navButton,
                                fontSize: 18,
                              ),
                            ),
                            Icon(
                              _openQ1.value == true
                                  ? Icons.arrow_downward_outlined
                                  : Icons.arrow_forward_ios,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Visibility(
                        visible: _openQ1.value,
                        child: Column(
                          children: [
                            Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.symmetric(horizontal: 15),
                              constraints: BoxConstraints(
                                minHeight: 80,
                              ),
                              width: 100.w,
                              decoration: BoxDecoration(
                                color: constantColors.navButton,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                "If you cannot complete the sign-up process using your email address:",
                                softWrap: true,
                                style: TextStyle(
                                  color: constantColors.whiteColor,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Container(
                                alignment: Alignment.center,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 15),
                                constraints: BoxConstraints(
                                  minHeight: 80,
                                ),
                                width: 100.w,
                                decoration: BoxDecoration(
                                  color: constantColors.navButton,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  "- Please try signing up using your 3rd party service account",
                                  softWrap: true,
                                  style: TextStyle(
                                    color: constantColors.whiteColor,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  LoginIcon(
                                    color: Colors.black,
                                    icon: Icons.apple_outlined,
                                    onTap: () async {
                                      try {
                                        bool allOk =
                                            await Provider.of<Authentication>(
                                                    context,
                                                    listen: false)
                                                .signInWithApple(context);

                                        if (allOk == true) {
                                          String name =
                                              "${Provider.of<Authentication>(context, listen: false).getappleUsername} ";

                                          List<String> splitList =
                                              name.split(" ");
                                          List<String> indexList = [];

                                          for (int i = 0;
                                              i < splitList.length;
                                              i++) {
                                            for (int j = 0;
                                                j < splitList[i].length;
                                                j++) {
                                              indexList.add(splitList[i]
                                                  .substring(0, j + 1)
                                                  .toLowerCase());
                                            }
                                          }

                                          SharedPreferencesHelper.setString(
                                              "login", "apple");

                                          final String? _getToken =
                                              await FirebaseMessaging.instance
                                                  .getToken();

                                          bool checkExists = await Provider.of<
                                                      FirebaseOperations>(
                                                  context,
                                                  listen: false)
                                              .checkUserExists(
                                                  useruid: Provider.of<
                                                              Authentication>(
                                                          context,
                                                          listen: false)
                                                      .getUserId);

                                          if (checkExists == false) {
                                            await Provider.of<
                                                        FirebaseOperations>(
                                                    context,
                                                    listen: false)
                                                .createUserCollection(context, {
                                              'token': _getToken.toString(),
                                              'useruid':
                                                  Provider.of<Authentication>(
                                                          context,
                                                          listen: false)
                                                      .getUserId,
                                              'username':
                                                  Provider.of<Authentication>(
                                                          context,
                                                          listen: false)
                                                      .getappleUsername,
                                              'useremail':
                                                  Provider.of<Authentication>(
                                                          context,
                                                          listen: false)
                                                      .getappleUseremail,
                                              "userrealname":
                                                  Provider.of<Authentication>(
                                                          context,
                                                          listen: false)
                                                      .getappleUsername,
                                              "address": "",
                                              'usercontactnumber': "",
                                              "usergender": "",
                                              'userimage':
                                                  Provider.of<Authentication>(
                                                          context,
                                                          listen: false)
                                                      .getappleUserImage,
                                              "userbio": "",
                                              "usertiktokurl": "",
                                              "userinstagramurl": "",
                                              "userfacebookurl": "",
                                              "userdob": Timestamp.now(),
                                              "usercreatedat": Timestamp.now(),
                                              "isverified": false,
                                              "usercover":
                                                  "https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/f/ff1e3a0b-d453-4f25-9d40-b639ea34eac6/d8b0e2q-c3445053-675a-4952-9be8-11884fd5c7d7.jpg?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ1cm46YXBwOjdlMGQxODg5ODIyNjQzNzNhNWYwZDQxNWVhMGQyNmUwIiwiaXNzIjoidXJuOmFwcDo3ZTBkMTg4OTgyMjY0MzczYTVmMGQ0MTVlYTBkMjZlMCIsIm9iaiI6W1t7InBhdGgiOiJcL2ZcL2ZmMWUzYTBiLWQ0NTMtNGYyNS05ZDQwLWI2MzllYTM0ZWFjNlwvZDhiMGUycS1jMzQ0NTA1My02NzVhLTQ5NTItOWJlOC0xMTg4NGZkNWM3ZDcuanBnIn1dXSwiYXVkIjpbInVybjpzZXJ2aWNlOmZpbGUuZG93bmxvYWQiXX0.TNA3OxHyji3j7IYYhoKKMv0Z9RkWkP-pcdTdxLU6h3E",
                                              'usersearchindex': indexList,
                                              'totalmade': 0,
                                              'paypal': '',
                                              'percentage': 33,
                                            });
                                          }

                                          Navigator.pushReplacement(
                                              context,
                                              PageTransition(
                                                  child: FeedPage(),
                                                  type: PageTransitionType
                                                      .rightToLeft));
                                        } else {
                                          CoolAlert.show(
                                            context: context,
                                            type: CoolAlertType.error,
                                            title: "Login cancelled",
                                            text: "Apple login cancelled",
                                          );
                                        }
                                        // ignore: avoid_catches_without_on_clauses
                                      } catch (e) {
                                        CoolAlert.show(
                                          context: context,
                                          type: CoolAlertType.error,
                                          title: "Sign In Failed",
                                          text: e.toString(),
                                        );
                                      }
                                    },
                                  ),
                                  LoginIcon(
                                    color: Colors.purple,
                                    icon: EvaIcons.google,
                                    onTap: () async {
                                      try {
                                        bool allOk =
                                            await Provider.of<Authentication>(
                                                    context,
                                                    listen: false)
                                                .signInWithgoogle();

                                        if (allOk == true) {
                                          String name =
                                              "${Provider.of<Authentication>(context, listen: false).getgoogleUsername} ";

                                          List<String> splitList =
                                              name.split(" ");
                                          List<String> indexList = [];

                                          for (int i = 0;
                                              i < splitList.length;
                                              i++) {
                                            for (int j = 0;
                                                j < splitList[i].length;
                                                j++) {
                                              indexList.add(splitList[i]
                                                  .substring(0, j + 1)
                                                  .toLowerCase());
                                            }
                                          }

                                          indexList.forEach(log);

                                          SharedPreferencesHelper.setString(
                                              "login", "gmail");

                                          bool checkExists = await Provider.of<
                                                      FirebaseOperations>(
                                                  context,
                                                  listen: false)
                                              .checkUserExists(
                                                  useruid: Provider.of<
                                                              Authentication>(
                                                          context,
                                                          listen: false)
                                                      .getUserId);

                                          log(checkExists.toString());

                                          final String? _getToken =
                                              await FirebaseMessaging.instance
                                                  .getToken();

                                          if (checkExists == false) {
                                            await Provider.of<
                                                        FirebaseOperations>(
                                                    context,
                                                    listen: false)
                                                .createUserCollection(context, {
                                              'token': _getToken.toString(),
                                              'useruid':
                                                  Provider.of<Authentication>(
                                                          context,
                                                          listen: false)
                                                      .getUserId,
                                              'username':
                                                  Provider.of<Authentication>(
                                                          context,
                                                          listen: false)
                                                      .getgoogleUsername,
                                              'useremail':
                                                  Provider.of<Authentication>(
                                                          context,
                                                          listen: false)
                                                      .getgoogleUseremail,
                                              "userrealname":
                                                  Provider.of<Authentication>(
                                                          context,
                                                          listen: false)
                                                      .getgoogleUsername,
                                              "address": "",
                                              'usercontactnumber':
                                                  Provider.of<Authentication>(
                                                          context,
                                                          listen: false)
                                                      .getgooglePhoneNo,
                                              "usergender": "",
                                              'userimage':
                                                  Provider.of<Authentication>(
                                                          context,
                                                          listen: false)
                                                      .getgoogleUserImage,
                                              "userbio": "",
                                              "usertiktokurl": "",
                                              "userinstagramurl": "",
                                              "userfacebookurl": "",
                                              "userdob": Timestamp.now(),
                                              "usercreatedat": Timestamp.now(),
                                              "isverified": false,
                                              "usercover":
                                                  "https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/f/ff1e3a0b-d453-4f25-9d40-b639ea34eac6/d8b0e2q-c3445053-675a-4952-9be8-11884fd5c7d7.jpg?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ1cm46YXBwOjdlMGQxODg5ODIyNjQzNzNhNWYwZDQxNWVhMGQyNmUwIiwiaXNzIjoidXJuOmFwcDo3ZTBkMTg4OTgyMjY0MzczYTVmMGQ0MTVlYTBkMjZlMCIsIm9iaiI6W1t7InBhdGgiOiJcL2ZcL2ZmMWUzYTBiLWQ0NTMtNGYyNS05ZDQwLWI2MzllYTM0ZWFjNlwvZDhiMGUycS1jMzQ0NTA1My02NzVhLTQ5NTItOWJlOC0xMTg4NGZkNWM3ZDcuanBnIn1dXSwiYXVkIjpbInVybjpzZXJ2aWNlOmZpbGUuZG93bmxvYWQiXX0.TNA3OxHyji3j7IYYhoKKMv0Z9RkWkP-pcdTdxLU6h3E",
                                              'usersearchindex': indexList,
                                              'totalmade': 0,
                                              'paypal': '',
                                              'percentage': 33,
                                            });
                                          }

                                          Navigator.pushReplacement(
                                              context,
                                              PageTransition(
                                                  child: FeedPage(),
                                                  type: PageTransitionType
                                                      .rightToLeft));
                                        } else {
                                          CoolAlert.show(
                                            context: context,
                                            type: CoolAlertType.error,
                                            title: "Login cancelled",
                                            text: "Google login cancelled",
                                          );
                                        }
                                      } catch (e) {
                                        CoolAlert.show(
                                          context: context,
                                          type: CoolAlertType.error,
                                          title: "Sign In Failed",
                                          text: e.toString(),
                                        );
                                      }
                                    },
                                  ),
                                  LoginIcon(
                                    color: Colors.blue,
                                    icon: EvaIcons.facebook,
                                    onTap: () async {
                                      try {
                                        bool allOk =
                                            await Provider.of<Authentication>(
                                                    context,
                                                    listen: false)
                                                .signInWithFacebook();

                                        if (allOk == true) {
                                          String name =
                                              "${Provider.of<Authentication>(context, listen: false).getfacebookUsername} ";

                                          List<String> splitList =
                                              name.split(" ");
                                          List<String> indexList = [];

                                          for (int i = 0;
                                              i < splitList.length;
                                              i++) {
                                            for (int j = 0;
                                                j < splitList[i].length;
                                                j++) {
                                              indexList.add(splitList[i]
                                                  .substring(0, j + 1)
                                                  .toLowerCase());
                                            }
                                          }

                                          bool checkExists = await Provider.of<
                                                      FirebaseOperations>(
                                                  context,
                                                  listen: false)
                                              .checkUserExists(
                                                  useruid: Provider.of<
                                                              Authentication>(
                                                          context,
                                                          listen: false)
                                                      .getUserId);

                                          SharedPreferencesHelper.setString(
                                              "login", "facebook");

                                          final String? _getToken =
                                              await FirebaseMessaging.instance
                                                  .getToken();

                                          if (checkExists == false) {
                                            await Provider.of<
                                                        FirebaseOperations>(
                                                    context,
                                                    listen: false)
                                                .createUserCollection(context, {
                                              'token': _getToken.toString(),
                                              'useruid':
                                                  Provider.of<Authentication>(
                                                          context,
                                                          listen: false)
                                                      .getUserId,
                                              'username':
                                                  Provider.of<Authentication>(
                                                          context,
                                                          listen: false)
                                                      .getfacebookUsername,
                                              'useremail':
                                                  Provider.of<Authentication>(
                                                          context,
                                                          listen: false)
                                                      .getfacebookUseremail,
                                              "userrealname":
                                                  Provider.of<Authentication>(
                                                          context,
                                                          listen: false)
                                                      .getfacebookUsername,
                                              "address": "",
                                              'usercontactnumber': "",
                                              "usergender": "",
                                              'userimage':
                                                  Provider.of<Authentication>(
                                                          context,
                                                          listen: false)
                                                      .getfacebookUserImage,
                                              "userbio": "",
                                              "usertiktokurl": "",
                                              "userinstagramurl": "",
                                              "userfacebookurl": "",
                                              "userdob": Timestamp.now(),
                                              "usercreatedat": Timestamp.now(),
                                              "isverified": false,
                                              "usercover":
                                                  "https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/f/ff1e3a0b-d453-4f25-9d40-b639ea34eac6/d8b0e2q-c3445053-675a-4952-9be8-11884fd5c7d7.jpg?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ1cm46YXBwOjdlMGQxODg5ODIyNjQzNzNhNWYwZDQxNWVhMGQyNmUwIiwiaXNzIjoidXJuOmFwcDo3ZTBkMTg4OTgyMjY0MzczYTVmMGQ0MTVlYTBkMjZlMCIsIm9iaiI6W1t7InBhdGgiOiJcL2ZcL2ZmMWUzYTBiLWQ0NTMtNGYyNS05ZDQwLWI2MzllYTM0ZWFjNlwvZDhiMGUycS1jMzQ0NTA1My02NzVhLTQ5NTItOWJlOC0xMTg4NGZkNWM3ZDcuanBnIn1dXSwiYXVkIjpbInVybjpzZXJ2aWNlOmZpbGUuZG93bmxvYWQiXX0.TNA3OxHyji3j7IYYhoKKMv0Z9RkWkP-pcdTdxLU6h3E",
                                              'usersearchindex': indexList,
                                              'totalmade': 0,
                                              'paypal': '',
                                              'percentage': 33,
                                            });
                                          }

                                          Navigator.pushReplacement(
                                              context,
                                              PageTransition(
                                                  child: FeedPage(),
                                                  type: PageTransitionType
                                                      .rightToLeft));
                                        } else {
                                          CoolAlert.show(
                                            context: context,
                                            type: CoolAlertType.error,
                                            title: "Login cancelled",
                                            text: "Facebook login cancelled",
                                          );
                                        }
                                      } catch (e) {
                                        CoolAlert.show(
                                          context: context,
                                          type: CoolAlertType.error,
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: InkWell(
                        onTap: () {
                          _openQ2.value = !_openQ2.value;
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 15),
                          height: 100,
                          width: 100.w,
                          decoration: BoxDecoration(
                            color: constantColors.bioBg,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Email OTP Issue",
                                style: TextStyle(
                                  color: constantColors.navButton,
                                  fontSize: 18,
                                ),
                              ),
                              Icon(
                                _openQ2.value == true
                                    ? Icons.arrow_downward_outlined
                                    : Icons.arrow_forward_ios,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Visibility(
                        visible: _openQ2.value,
                        child: Column(
                          children: [
                            Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.symmetric(horizontal: 15),
                              constraints: BoxConstraints(
                                minHeight: 80,
                              ),
                              width: 100.w,
                              decoration: BoxDecoration(
                                color: constantColors.navButton,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                "Email Address Authentication (OTP) Mail Not Received:",
                                softWrap: true,
                                style: TextStyle(
                                  color: constantColors.whiteColor,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Container(
                                alignment: Alignment.center,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 15),
                                constraints: BoxConstraints(
                                  minHeight: 80,
                                ),
                                width: 100.w,
                                decoration: BoxDecoration(
                                  color: constantColors.navButton,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  "- If the communication environment is bad, you may not be able to receive email address authentication (OTP) mail. Please consider reviewing the communication environment by switching Wifi networks or using Mobile Data.",
                                  softWrap: true,
                                  style: TextStyle(
                                    color: constantColors.whiteColor,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Container(
                                alignment: Alignment.center,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 15),
                                constraints: BoxConstraints(
                                  minHeight: 80,
                                ),
                                width: 100.w,
                                decoration: BoxDecoration(
                                  color: constantColors.navButton,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  "- Please check your email environment and spam mailbox. Also, if you have set the rejection settings, please set it to allow mail from the diamantrose.co.jp domain.",
                                  softWrap: true,
                                  style: TextStyle(
                                    color: constantColors.whiteColor,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: InkWell(
                        onTap: () {
                          _openQ3.value = !_openQ3.value;
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 15),
                          height: 100,
                          width: 100.w,
                          decoration: BoxDecoration(
                            color: constantColors.bioBg,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Using Social Media Login",
                                style: TextStyle(
                                  color: constantColors.navButton,
                                  fontSize: 18,
                                ),
                              ),
                              Icon(
                                _openQ3.value == true
                                    ? Icons.arrow_downward_outlined
                                    : Icons.arrow_forward_ios,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Visibility(
                        visible: _openQ3.value,
                        child: Column(
                          children: [
                            Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.symmetric(horizontal: 15),
                              constraints: BoxConstraints(
                                minHeight: 80,
                              ),
                              width: 100.w,
                              decoration: BoxDecoration(
                                color: constantColors.navButton,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                "About Signing Up Using Third-Party Service Accounts:",
                                softWrap: true,
                                style: TextStyle(
                                  color: constantColors.whiteColor,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Container(
                                alignment: Alignment.center,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 15),
                                constraints: BoxConstraints(
                                  minHeight: 80,
                                ),
                                width: 100.w,
                                decoration: BoxDecoration(
                                  color: constantColors.navButton,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  "- If you sign up using a third-party service account, you cannot create an account using an email address with the same string as the account ID.",
                                  softWrap: true,
                                  style: TextStyle(
                                    color: constantColors.whiteColor,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: InkWell(
                        onTap: () async {
                          String email = 'gd@diamantrose.co.jp';
                          String subject = 'Glamorous Diastation Question';
                          String body =
                              'Dear GD Team, \n\nThe following is a concern I have with Glamorous Diastation:';

                          String emailUrl =
                              "mailto:$email?subject=$subject&body=$body";

                          if (await canLaunchUrl(Uri.parse(emailUrl))) {
                            await launchUrl(Uri.parse(emailUrl));
                          } else {
                            throw "Error occured sending an email";
                          }
                        },
                        child: Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.symmetric(horizontal: 15),
                          height: 80,
                          width: 100.w,
                          decoration: BoxDecoration(
                            color: constantColors.greenColor,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Text(
                            "Submit your Question",
                            style: TextStyle(
                              color: constantColors.navButton,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }),
        ),
      ),
    );
  }
}
