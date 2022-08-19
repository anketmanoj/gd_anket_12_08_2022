import 'dart:developer';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:diamon_rose_app/providers/user_signup_provider.dart';
import 'package:diamon_rose_app/screens/mainPage/Signupflow/signup_username.dart';
import 'package:diamon_rose_app/widgets/global.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class SignUpLocation extends StatefulWidget {
  const SignUpLocation({Key? key}) : super(key: key);

  @override
  State<SignUpLocation> createState() => _SignUpLocationState();
}

class _SignUpLocationState extends State<SignUpLocation> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _locationController = TextEditingController();
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Select Country",
                    style: TextStyle(
                      fontSize: 30,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.05,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                              color: constantColors.whiteColor,
                              borderRadius: BorderRadius.circular(30)),
                          child: CountryCodePicker(
                            showDropDownButton: true,
                            onChanged: (value) {
                              log(value.name!);

                              _locationController.text = value.name!;
                            },
                            initialSelection: _locationController.text,
                            showCountryOnly: true,
                            favorite: ['+971', 'JP'],
                            showOnlyCountryWhenClosed: true,
                            showFlagMain: true,
                            showFlag: true,
                            showFlagDialog: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.75,
            left: MediaQuery.of(context).size.width * 0.12,
            right: MediaQuery.of(context).size.width * 0.12,
            child: NextButton(
              function: () {
                if (_formKey.currentState!.validate()) {
                  Provider.of<SignUpUser>(context, listen: false)
                      .setLocation(_locationController.text);
                  Navigator.push(
                    context,
                    PageTransition(
                      type: PageTransitionType.fade,
                      child: SignUpUsername(),
                    ),
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
