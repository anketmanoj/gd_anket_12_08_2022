// ignore_for_file: unawaited_futures

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:diamon_rose_app/providers/user_signup_provider.dart';
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

class SignUpUsername extends StatelessWidget {
  SignUpUsername({Key? key}) : super(key: key);
  TextEditingController _usernameController = TextEditingController();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  ValueNotifier<bool> checkboxValue = ValueNotifier<bool>(false);

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
                    "Set up a username",
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
                    controller: _usernameController,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Username cannot be empty';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: "username",
                      prefixIcon: Icon(
                        Icons.person,
                        color: Colors.white,
                      ),
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
                          color: Colors.white,
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
            child: Column(
              children: [
                SubmitButton(
                  function: () async {
                    if (_formKey.currentState!.validate()) {
                      // Show loading
                      try {
                        CoolAlert.show(
                          context: context,
                          type: CoolAlertType.loading,
                          title: "Signing up",
                          text: "Please wait...",
                        );

                        Provider.of<SignUpUser>(context, listen: false)
                            .setName(_usernameController.text);

                        await Provider.of<Authentication>(context,
                                listen: false)
                            .createAccount(
                                Provider.of<SignUpUser>(context, listen: false)
                                    .getEmail,
                                Provider.of<SignUpUser>(context, listen: false)
                                    .password);

                        SharedPreferencesHelper.setString("login", "email");

                        String name =
                            "${Provider.of<SignUpUser>(context, listen: false).name} ";

                        List<String> splitList = name.split(" ");
                        List<String> indexList = [];

                        for (int i = 0; i < splitList.length; i++) {
                          for (int j = 0; j < splitList[i].length; j++) {
                            indexList.add(
                                splitList[i].substring(0, j + 1).toLowerCase());
                          }
                        }

                        final String? _getToken =
                            await FirebaseMessaging.instance.getToken();

                        await Provider.of<FirebaseOperations>(context,
                                listen: false)
                            .createUserCollection(
                          context,
                          {
                            "token": _getToken.toString(),
                            "useruid": Provider.of<Authentication>(context,
                                    listen: false)
                                .getUserId,
                            "username":
                                Provider.of<SignUpUser>(context, listen: false)
                                    .name,
                            "useremail":
                                Provider.of<SignUpUser>(context, listen: false)
                                    .getEmail,
                            "userrealname":
                                Provider.of<SignUpUser>(context, listen: false)
                                    .name,
                            "address":
                                Provider.of<SignUpUser>(context, listen: false)
                                    .location,
                            "usercontactnumber": "",
                            "usergender": "",
                            "userimage":
                                "https://firebasestorage.googleapis.com/v0/b/gdfe-ac584.appspot.com/o/bgImagesAR%2FGDapplogo.png?alt=media&token=9a23d52a-2282-4eb7-a751-a8e4fc7b7f8f",
                            // "https://t3.ftcdn.net/jpg/03/46/83/96/360_F_346839683_6nAPzbhpSkIpb8pmAwufkC7c5eD7wYws.jpg",
                            "userbio": "",
                            "usertiktokurl": "",
                            "userinstagramurl": "",
                            "userfacebookurl": "",
                            "userdob": Timestamp.fromDate(
                                Provider.of<SignUpUser>(context, listen: false)
                                    .dob),
                            "usercreatedat": Timestamp.now(),
                            "isverified": false,
                            "usercover":
                                "https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/f/ff1e3a0b-d453-4f25-9d40-b639ea34eac6/d8b0e2q-c3445053-675a-4952-9be8-11884fd5c7d7.jpg?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ1cm46YXBwOjdlMGQxODg5ODIyNjQzNzNhNWYwZDQxNWVhMGQyNmUwIiwiaXNzIjoidXJuOmFwcDo3ZTBkMTg4OTgyMjY0MzczYTVmMGQ0MTVlYTBkMjZlMCIsIm9iaiI6W1t7InBhdGgiOiJcL2ZcL2ZmMWUzYTBiLWQ0NTMtNGYyNS05ZDQwLWI2MzllYTM0ZWFjNlwvZDhiMGUycS1jMzQ0NTA1My02NzVhLTQ5NTItOWJlOC0xMTg4NGZkNWM3ZDcuanBnIn1dXSwiYXVkIjpbInVybjpzZXJ2aWNlOmZpbGUuZG93bmxvYWQiXX0.TNA3OxHyji3j7IYYhoKKMv0Z9RkWkP-pcdTdxLU6h3E",
                            'usersearchindex': indexList,
                            'totalmade': 0,
                            'paypal': '',
                            'percentage': 33,
                          },
                        ).whenComplete(() {
                          context.read<Authentication>().setIsAnon(false);
                          Navigator.push(
                              context,
                              PageTransition(
                                type: PageTransitionType.fade,
                                child: FeedPage(),
                              ));
                        });

                        // ignore: avoid_catches_without_on_clauses
                      } catch (e) {
                        CoolAlert.show(
                            context: context,
                            type: CoolAlertType.error,
                            title: "Error",
                            text: e.toString());
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
