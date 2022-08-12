// ignore_for_file: unawaited_futures

import 'package:cool_alert/cool_alert.dart';
import 'package:diamon_rose_app/services/FirebaseOperations.dart';
import 'package:diamon_rose_app/services/authentication.dart';
import 'package:diamon_rose_app/widgets/global.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class PayPalLinkScreen extends StatelessWidget {
  PayPalLinkScreen({Key? key}) : super(key: key);

  TextEditingController _paypalController = TextEditingController();
  TextEditingController _paypalController2 = TextEditingController();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final FirebaseOperations firebaseOperations =
        Provider.of<FirebaseOperations>(context, listen: false);
    final Authentication auth =
        Provider.of<Authentication>(context, listen: false);
    return Scaffold(
      body: Stack(
        children: [
          bodyColor(),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.1,
            left: MediaQuery.of(context).size.width * 0.05,
            child: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(
                Icons.arrow_back_ios_new,
                color: constantColors.whiteColor,
              ),
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
                    'Set up PayPal',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.2,
                  ),
                  TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(
                      color: Colors.black,
                    ),
                    obscureText: false,
                    controller: _paypalController,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'paypal cannot be empty';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      prefixText: "paypal.me/",
                      prefixStyle: TextStyle(
                        color: constantColors.black,
                      ),
                      hintText: "Paypal account name",
                      hintStyle: TextStyle(
                        color: Colors.black.withOpacity(0.3),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.white,
                        ),
                      ),
                      errorStyle: TextStyle(
                        color: constantColors.whiteColor,
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 30),
                    child: TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(
                        color: Colors.black,
                      ),
                      obscureText: false,
                      controller: _paypalController2,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'paypal cannot be empty';
                        }
                        if (value != _paypalController.text) {
                          return 'paypal account do not match';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        prefixText: "paypal.me/",
                        prefixStyle: TextStyle(
                          color: constantColors.black,
                        ),
                        hintText: "Confirm paypal account",
                        hintStyle: TextStyle(
                          color: Colors.black.withOpacity(0.3),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.white,
                          ),
                        ),
                        errorStyle: TextStyle(
                          color: constantColors.whiteColor,
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.black,
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
            top: MediaQuery.of(context).size.height * 0.75,
            left: MediaQuery.of(context).size.width * 0.12,
            right: MediaQuery.of(context).size.width * 0.12,
            child: SubmitButton(
              function: () async {
                if (_formKey.currentState!.validate()) {
                  CoolAlert.show(
                    context: context,
                    type: CoolAlertType.loading,
                    text: "Updating Paypal account details",
                    barrierDismissible: false,
                  );

                  await firebaseOperations
                      .updatePaypalLink(
                          paypalAccountName: _paypalController.text,
                          useruid: auth.getUserId)
                      .then(
                    (value) {
                      Navigator.pop(context);

                      showTopSnackBar(
                        context,
                        CustomSnackBar.success(
                            message: "Successfully updated Paypal"),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
