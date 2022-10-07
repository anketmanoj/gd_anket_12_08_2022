// ignore_for_file: unawaited_futures, omit_local_variable_types, prefer_final_locals, avoid_catches_without_on_clauses

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:diamon_rose_app/screens/feedPages/feedPage.dart';
import 'package:diamon_rose_app/screens/mainPage/reset_password_screen.dart';
import 'package:diamon_rose_app/services/FirebaseOperations.dart';
import 'package:diamon_rose_app/services/authentication.dart';
import 'package:diamon_rose_app/services/shared_preferences_helper.dart';
import 'package:diamon_rose_app/translations/locale_keys.g.dart';
import 'package:diamon_rose_app/widgets/global.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  GlobalKey _formKey = GlobalKey<FormState>();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  bool _showPassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          bodyColor(),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.05,
            left: 10,
            child: IconButton(
              icon: Icon(
                EvaIcons.arrowIosBack,
                size: 30,
                color: Colors.white,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.2,
            right: MediaQuery.of(context).size.width * 0.12,
            left: MediaQuery.of(context).size.width * 0.12,
            child: Container(
              height: 50,
              alignment: Alignment.center,
              child: Text(
                LocaleKeys.login.tr(),
                style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.35,
            right: MediaQuery.of(context).size.width * 0.12,
            left: MediaQuery.of(context).size.width * 0.12,
            child: Form(
              key: _formKey,
              child: Container(
                alignment: Alignment.center,
                child: Column(
                  children: [
                    TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(
                        color: Colors.black,
                      ),
                      controller: _emailController,
                      validator: (value) {
                        if (value!.isEmpty || !value.contains("@")) {
                          return LocaleKeys.invalidemail.tr();
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: "johndoe@email.com",
                        hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.3),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.white,
                          ),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(
                        color: Colors.black,
                      ),
                      obscureText: _showPassword,
                      controller: _passwordController,
                      validator: (value) {
                        if (value!.isEmpty || value.length < 6) {
                          return 'Password cannot be empty and it must be at least 6 characters';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _showPassword = !_showPassword;
                              });
                            },
                            icon: Icon(
                              _showPassword
                                  ? EvaIcons.eyeOffOutline
                                  : EvaIcons.eyeOutline,
                              color: Colors.black,
                            )),
                        hintText: "Secure password",
                        hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.3),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.white,
                          ),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.52,
            right: MediaQuery.of(context).size.width * 0.12,
            left: MediaQuery.of(context).size.width * 0.12,
            child: Column(
              children: [
                InkWell(
                  onTap: () async {
                    try {
                      await Provider.of<Authentication>(context, listen: false)
                          .loginIntoAccount(
                              _emailController.text, _passwordController.text);

                      SharedPreferencesHelper.setString("login", "email");

                      Navigator.pushReplacement(
                        context,
                        PageTransition(
                            child: FeedPage(),
                            type: PageTransitionType.bottomToTop),
                      );
                    } catch (e) {
                      CoolAlert.show(
                        context: context,
                        type: CoolAlertType.error,
                        title: "Sign In Failed",
                        text: e.toString(),
                      );
                    }
                  },
                  child: Container(
                    alignment: Alignment.center,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      LocaleKeys.login.tr(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        PageTransition(
                            type: PageTransitionType.fade,
                            child: ResetPassword()));
                  },
                  child: Container(
                    height: 40,
                    child: Text(
                      LocaleKeys.forgetpassword.tr(),
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.5),
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      LocaleKeys.loginwithyoursocialmediaaccounts.tr(),
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.5),
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      LoginIcon(
                        color: Colors.black,
                        icon: Icons.apple_outlined,
                        onTap: () async {
                          try {
                            bool allOk = await Provider.of<Authentication>(
                                    context,
                                    listen: false)
                                .signInWithApple(context);

                            if (allOk == true) {
                              String name =
                                  "${Provider.of<Authentication>(context, listen: false).getappleUsername} ";

                              List<String> splitList = name.split(" ");
                              List<String> indexList = [];

                              for (int i = 0; i < splitList.length; i++) {
                                for (int j = 0; j < splitList[i].length; j++) {
                                  indexList.add(splitList[i]
                                      .substring(0, j + 1)
                                      .toLowerCase());
                                }
                              }

                              SharedPreferencesHelper.setString(
                                  "login", "apple");

                              final String? _getToken =
                                  await FirebaseMessaging.instance.getToken();

                              bool checkExists =
                                  await Provider.of<FirebaseOperations>(context,
                                          listen: false)
                                      .checkUserExists(
                                          useruid: Provider.of<Authentication>(
                                                  context,
                                                  listen: false)
                                              .getUserId);

                              if (checkExists == false) {
                                await Provider.of<FirebaseOperations>(context,
                                        listen: false)
                                    .createUserCollection(context, {
                                  'token': _getToken.toString(),
                                  'useruid': Provider.of<Authentication>(
                                          context,
                                          listen: false)
                                      .getUserId,
                                  'username': Provider.of<Authentication>(
                                          context,
                                          listen: false)
                                      .getappleUsername,
                                  'useremail': Provider.of<Authentication>(
                                          context,
                                          listen: false)
                                      .getappleUseremail,
                                  "userrealname": Provider.of<Authentication>(
                                          context,
                                          listen: false)
                                      .getappleUsername,
                                  "address": "",
                                  'usercontactnumber': "",
                                  "usergender": "",
                                  'userimage': Provider.of<Authentication>(
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
                                      type: PageTransitionType.rightToLeft));
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
                            bool allOk = await Provider.of<Authentication>(
                                    context,
                                    listen: false)
                                .signInWithgoogle();

                            if (allOk == true) {
                              String name =
                                  "${Provider.of<Authentication>(context, listen: false).getgoogleUsername} ";

                              List<String> splitList = name.split(" ");
                              List<String> indexList = [];

                              for (int i = 0; i < splitList.length; i++) {
                                for (int j = 0; j < splitList[i].length; j++) {
                                  indexList.add(splitList[i]
                                      .substring(0, j + 1)
                                      .toLowerCase());
                                }
                              }

                              indexList.forEach(log);

                              SharedPreferencesHelper.setString(
                                  "login", "gmail");

                              bool checkExists =
                                  await Provider.of<FirebaseOperations>(context,
                                          listen: false)
                                      .checkUserExists(
                                          useruid: Provider.of<Authentication>(
                                                  context,
                                                  listen: false)
                                              .getUserId);

                              log(checkExists.toString());

                              final String? _getToken =
                                  await FirebaseMessaging.instance.getToken();

                              if (checkExists == false) {
                                await Provider.of<FirebaseOperations>(context,
                                        listen: false)
                                    .createUserCollection(context, {
                                  'token': _getToken.toString(),
                                  'useruid': Provider.of<Authentication>(
                                          context,
                                          listen: false)
                                      .getUserId,
                                  'username': Provider.of<Authentication>(
                                          context,
                                          listen: false)
                                      .getgoogleUsername,
                                  'useremail': Provider.of<Authentication>(
                                          context,
                                          listen: false)
                                      .getgoogleUseremail,
                                  "userrealname": Provider.of<Authentication>(
                                          context,
                                          listen: false)
                                      .getgoogleUsername,
                                  "address": "",
                                  'usercontactnumber':
                                      Provider.of<Authentication>(context,
                                              listen: false)
                                          .getgooglePhoneNo,
                                  "usergender": "",
                                  'userimage': Provider.of<Authentication>(
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
                                      type: PageTransitionType.rightToLeft));
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
                            bool allOk = await Provider.of<Authentication>(
                                    context,
                                    listen: false)
                                .signInWithFacebook();

                            if (allOk == true) {
                              String name =
                                  "${Provider.of<Authentication>(context, listen: false).getfacebookUsername} ";

                              List<String> splitList = name.split(" ");
                              List<String> indexList = [];

                              for (int i = 0; i < splitList.length; i++) {
                                for (int j = 0; j < splitList[i].length; j++) {
                                  indexList.add(splitList[i]
                                      .substring(0, j + 1)
                                      .toLowerCase());
                                }
                              }

                              bool checkExists =
                                  await Provider.of<FirebaseOperations>(context,
                                          listen: false)
                                      .checkUserExists(
                                          useruid: Provider.of<Authentication>(
                                                  context,
                                                  listen: false)
                                              .getUserId);

                              SharedPreferencesHelper.setString(
                                  "login", "facebook");

                              final String? _getToken =
                                  await FirebaseMessaging.instance.getToken();

                              if (checkExists == false) {
                                await Provider.of<FirebaseOperations>(context,
                                        listen: false)
                                    .createUserCollection(context, {
                                  'token': _getToken.toString(),
                                  'useruid': Provider.of<Authentication>(
                                          context,
                                          listen: false)
                                      .getUserId,
                                  'username': Provider.of<Authentication>(
                                          context,
                                          listen: false)
                                      .getfacebookUsername,
                                  'useremail': Provider.of<Authentication>(
                                          context,
                                          listen: false)
                                      .getfacebookUseremail,
                                  "userrealname": Provider.of<Authentication>(
                                          context,
                                          listen: false)
                                      .getfacebookUsername,
                                  "address": "",
                                  'usercontactnumber': "",
                                  "usergender": "",
                                  'userimage': Provider.of<Authentication>(
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
                                      type: PageTransitionType.rightToLeft));
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
                privacyPolicyLinkAndTermsOfService(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
