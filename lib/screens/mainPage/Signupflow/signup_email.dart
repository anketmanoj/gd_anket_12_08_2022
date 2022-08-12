// ignore_for_file: always_declare_return_types

import 'dart:math';
import 'dart:developer' as dev;

import 'package:cool_alert/cool_alert.dart';
import 'package:diamon_rose_app/logincreds.dart';
import 'package:diamon_rose_app/providers/user_signup_provider.dart';
import 'package:diamon_rose_app/screens/mainPage/Signupflow/signup_otp.dart';
import 'package:diamon_rose_app/services/FirebaseOperations.dart';
import 'package:diamon_rose_app/widgets/global.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:email_auth/email_auth.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class SignUpEmail extends StatefulWidget {
  SignUpEmail({Key? key}) : super(key: key);

  @override
  State<SignUpEmail> createState() => _SignUpEmailState();
}

class _SignUpEmailState extends State<SignUpEmail> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _emailConfrimController = TextEditingController();
  late String _otp;

  void createOtp() {
    final Random random = Random();
    final int otp = random.nextInt(9999);
    dev.log(otp.toString());
    setState(() {
      _otp = otp.toString();
    });
  }

  // ignore: type_annotate_public_apis
  Future<void> sendMail() async {
    final smtpServer = SmtpServer(
      'sv12325.xserver.jp',
      username: username,
      password: password,
      port: 465,
      ssl: true,
    );

    final equivalentMessage = Message()
      ..from = Address(username, 'Glamorous Diastation')
      ..recipients.add(Address(_emailController.text))
      ..subject = 'Email Verification OTP | Glamorous Diastation'
      ..html =
          """<p>Account verification code I requested to receive an account verification code.</p>
      <p>The OTP for authentication is:</p>
      <p>${_otp} Valid for 2 minutes.</p>
      <p>If you do not request the above features, please ignore this email.</p>
      <p>If you have any questions or comments, please feel free to contact us.</p>
      <p>Support email: diamantrosebe@gmail.com</p>
      <p>Please do not reply to this email.</p>
      <p>Created by Diamond Rose.</p>""";

    await send(equivalentMessage, smtpServer);
  }

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
                size: 35,
                color: Colors.white,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.2,
            left: MediaQuery.of(context).size.width * 0.12,
            right: MediaQuery.of(context).size.width * 0.12,
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Text(
                    "Sign up",
                    style: TextStyle(
                      fontSize: 30,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.05,
                  ),
                  TextFormField(
                    validator: (value) {
                      if (value!.isEmpty || !value.contains("@")) {
                        return 'Invalid Email';
                      }
                      return null;
                    },
                    controller: _emailController,
                    style: TextStyle(
                      color: Colors.white,
                    ),
                    decoration: InputDecoration(
                      label: Text("User Email"),
                      hintText: "johndoe@email.com",
                      hintStyle: TextStyle(
                        color: Colors.black.withOpacity(0.3),
                        fontSize: 15,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: TextFormField(
                      validator: (value) {
                        if (value!.isEmpty || !value.contains("@")) {
                          return 'Invalid Email';
                        }

                        if (value != _emailController.text ||
                            _emailConfrimController.text !=
                                _emailConfrimController.text) {
                          return "Emails don't match";
                        }
                        return null;
                      },
                      controller: _emailConfrimController,
                      style: TextStyle(
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                        label: Text("Confrim Email"),
                        hintText: "confirm email",
                        hintStyle: TextStyle(
                          color: Colors.black.withOpacity(0.3),
                          fontSize: 15,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.7,
            left: MediaQuery.of(context).size.width * 0.12,
            right: MediaQuery.of(context).size.width * 0.12,
            child: NextButton(
              function: () async {
                if (_formKey.currentState!.validate()) {
                  // ignore: unawaited_futures
                  CoolAlert.show(
                    context: context,
                    type: CoolAlertType.info,
                    title: "Please wait",
                    text: "We are sending you an email",
                  );
                  createOtp();
                  await sendMail().whenComplete(() {
                    Provider.of<SignUpUser>(context, listen: false)
                        .setEmail(_emailController.text);
                    Provider.of<SignUpUser>(context, listen: false)
                        .setOtp(_otp);
                  }).then((value) {
                    Navigator.push(
                      context,
                      PageTransition(
                        type: PageTransitionType.fade,
                        child: SignUpOTP(
                          email: _emailController.text,
                        ),
                      ),
                    );
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
