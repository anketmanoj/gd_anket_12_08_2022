// ignore_for_file: unawaited_futures, omit_local_variable_types, prefer_final_locals, avoid_catches_without_on_clauses

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:diamon_rose_app/screens/feedPages/feedPage.dart';
import 'package:diamon_rose_app/screens/mainPage/mainpage.dart';
import 'package:diamon_rose_app/screens/mainPage/reset_password_screen.dart';
import 'package:diamon_rose_app/services/FirebaseOperations.dart';
import 'package:diamon_rose_app/services/authentication.dart';
import 'package:diamon_rose_app/translations/locale_keys.g.dart';
import 'package:diamon_rose_app/widgets/global.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class CloseAccountScreen extends StatefulWidget {
  CloseAccountScreen({Key? key}) : super(key: key);

  @override
  State<CloseAccountScreen> createState() => _CloseAccountScreenState();
}

class _CloseAccountScreenState extends State<CloseAccountScreen> {
  final _formKey = GlobalKey<FormState>();
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
                "Close Account",
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
                          return 'Password cannot be empty ';
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
            top: MediaQuery.of(context).size.height * 0.7,
            right: MediaQuery.of(context).size.width * 0.12,
            left: MediaQuery.of(context).size.width * 0.12,
            child: Column(
              children: [
                InkWell(
                  onTap: () async {
                    if (_formKey.currentState!.validate() == true) {
                      bool accountClosed = await Authentication().deleteUser(
                          _emailController.text, _passwordController.text);

                      if (accountClosed == true) {
                        Get.snackbar(
                          'Account successfully closed',
                          "You will no longer be able to sign in with the account linked to ${_emailController.text}",
                          overlayColor: constantColors.navButton,
                          colorText: constantColors.whiteColor,
                          snackPosition: SnackPosition.TOP,
                          forwardAnimationCurve: Curves.elasticInOut,
                          reverseAnimationCurve: Curves.easeOut,
                        );
                        Navigator.pushReplacement(
                          context,
                          PageTransition(
                              child: MainPage(),
                              type: PageTransitionType.topToBottom),
                        );
                      } else {
                        Get.snackbar(
                          'Error Closing Account',
                          "Please make sure you've entered the correct email and password",
                          overlayColor: constantColors.navButton,
                          colorText: constantColors.whiteColor,
                          snackPosition: SnackPosition.TOP,
                          forwardAnimationCurve: Curves.elasticInOut,
                          reverseAnimationCurve: Curves.easeOut,
                        );
                      }
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
                      "Close Account",
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
