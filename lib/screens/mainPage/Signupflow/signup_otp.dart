import 'package:cool_alert/cool_alert.dart';
import 'package:diamon_rose_app/providers/user_signup_provider.dart';
import 'package:diamon_rose_app/screens/mainPage/Signupflow/signUp_password.dart';
import 'package:diamon_rose_app/services/FirebaseOperations.dart';
import 'package:diamon_rose_app/widgets/global.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

class SignUpOTP extends StatefulWidget {
  const SignUpOTP({Key? key, required this.email}) : super(key: key);
  final String email;

  @override
  State<SignUpOTP> createState() => _SignUpOTPState();
}

class _SignUpOTPState extends State<SignUpOTP> {
  final pinController = TextEditingController();
  final focusNode = FocusNode();

  @override
  void dispose() {
    pinController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  bool checkOtp() {
    final otp = pinController.text;
    if (otp == Provider.of<SignUpUser>(context, listen: false).otp) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    const focusedBorderColor = Color.fromARGB(255, 255, 255, 255);
    const fillColor = Color.fromRGBO(243, 246, 249, 0);
    const borderColor = Color.fromARGB(102, 255, 255, 255);

    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: borderColor),
      ),
    );
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
            child: Column(
              children: [
                Text(
                  "Verification",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 25,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 50),
                  child: Text(
                    "Enter the code sent to the email",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    "${widget.email}",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 30),
                  child: Pinput(
                    controller: pinController,
                    focusNode: focusNode,
                    androidSmsAutofillMethod:
                        AndroidSmsAutofillMethod.smsRetrieverApi,
                    defaultPinTheme: defaultPinTheme,
                    hapticFeedbackType: HapticFeedbackType.lightImpact,
                    onCompleted: (s) async {
                      bool valid = checkOtp();

                      if (valid) {
                        // ignore: unawaited_futures
                        Navigator.push(
                          context,
                          PageTransition(
                            type: PageTransitionType.fade,
                            child: SignUpPassword(),
                          ),
                        );
                      } else {
                        // show error
                        // ignore: unawaited_futures
                        CoolAlert.show(
                          context: context,
                          type: CoolAlertType.error,
                          title: "Error",
                          text: "Invalid OTP",
                        );
                      }
                    },
                    cursor: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          margin: EdgeInsets.only(bottom: 9),
                          width: 22,
                          height: 1,
                          color: focusedBorderColor,
                        ),
                      ],
                    ),
                    focusedPinTheme: defaultPinTheme.copyWith(
                      decoration: defaultPinTheme.decoration!.copyWith(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: focusedBorderColor),
                      ),
                    ),
                    submittedPinTheme: defaultPinTheme.copyWith(
                      decoration: defaultPinTheme.decoration!.copyWith(
                        color: fillColor,
                        borderRadius: BorderRadius.circular(19),
                        border: Border.all(color: focusedBorderColor),
                      ),
                    ),
                    errorPinTheme: defaultPinTheme.copyBorderWith(
                      border: Border.all(color: Colors.redAccent),
                    ),
                    onSubmitted: (s) {},
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
