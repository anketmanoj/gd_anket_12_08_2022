import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:diamon_rose_app/services/FirebaseOperations.dart';
import 'package:diamon_rose_app/services/authentication.dart';
import 'package:diamon_rose_app/widgets/global.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nanoid/nanoid.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sizer/sizer.dart';

class AdminRegisterUser extends StatelessWidget {
  AdminRegisterUser();

  final _userEmailController = TextEditingController();
  final _userConfirmEmailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  ValueNotifier<bool> accountCreated = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(text: "Register User", context: context),
      backgroundColor: constantColors.whiteColor,
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              TextFormField(
                enableInteractiveSelection: false,
                validator: (value) {
                  if (value!.isEmpty || !value.contains("@")) {
                    return "Invalid Email";
                  }
                  return null;
                },
                controller: _userEmailController,
                style: TextStyle(
                  color: Colors.black,
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
                      color: constantColors.navButton,
                      width: 2,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: constantColors.navButton,
                      width: 2,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: TextFormField(
                  enableInteractiveSelection: false,
                  validator: (value) {
                    if (value!.isEmpty || !value.contains("@")) {
                      return "Invalid Email";
                    }

                    if (value != _userEmailController.text) {
                      return "Emails dont match";
                    }
                    return null;
                  },
                  controller: _userConfirmEmailController,
                  style: TextStyle(
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    label: Text("Confirm Email"),
                    hintText: "Confirm Email",
                    hintStyle: TextStyle(
                      color: Colors.black.withOpacity(0.3),
                      fontSize: 15,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: constantColors.navButton,
                        width: 2,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: constantColors.navButton,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              submitButton(context),
              SizedBox(
                height: 20,
              ),
              ValueListenableBuilder<bool>(
                  valueListenable: accountCreated,
                  builder: (context, accountVal, _) {
                    return Visibility(
                      visible: accountVal,
                      child: InkWell(
                        onTap: () async {
                          await Share.share(
                            "Hello, your login credentials for Glamorous Diastation are as follows: \nEmail: ${_userConfirmEmailController.text}\nPassword: GDCreator123",
                          );
                        },
                        child: Container(
                          height: 25.h,
                          width: 100.w,
                          padding: EdgeInsets.all(40),
                          decoration: BoxDecoration(
                            color: constantColors.navButton,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Email: ${_userConfirmEmailController.text}",
                                style: TextStyle(
                                  color: constantColors.whiteColor,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                "Password: GDCreator123",
                                style: TextStyle(
                                  color: constantColors.whiteColor,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Text(
                                "Click to share login credentials with the user",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: constantColors.whiteColor,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  })
            ],
          ),
        ),
      ),
    );
  }

  Widget submitButton(BuildContext context) {
    return SubmitButton(
      text: "Create User",
      function: () async {
        if (_formKey.currentState!.validate()) {
          try {
            CoolAlert.show(
              context: context,
              barrierDismissible: false,
              type: CoolAlertType.loading,
              title: "Signing up",
              text: "Please wait...",
            );

            User? adminCreatedUser =
                await Provider.of<Authentication>(context, listen: false)
                    .adminCreateAccount(
                        _userConfirmEmailController.text, "GDCreator123");

            String name = "GDcreator";

            List<String> splitList = name.split(" ");
            List<String> indexList = [];

            for (int i = 0; i < splitList.length; i++) {
              for (int j = 0; j < splitList[i].length; j++) {
                indexList.add(splitList[i].substring(0, j + 1).toLowerCase());
              }
            }

            bool checkExists =
                await Provider.of<FirebaseOperations>(context, listen: false)
                    .checkUserExists(useruid: adminCreatedUser!.uid);

            // final String? _getToken =
            //     await FirebaseMessaging.instance.getToken();

            if (checkExists == false) {
              await Provider.of<FirebaseOperations>(context, listen: false)
                  .adminCreateUserCollection(
                context: context,
                data: {
                  "token": "emptyToken",
                  "useruid": adminCreatedUser.uid,
                  "username": "${_userConfirmEmailController.text}",
                  "useremail": "${_userConfirmEmailController.text}",
                  "userrealname": "${_userConfirmEmailController.text}",
                  "address": "",
                  "usercontactnumber": "",
                  "usergender": "",
                  "userimage":
                      "https://firebasestorage.googleapis.com/v0/b/gdfe-ac584.appspot.com/o/bgImagesAR%2FGDapplogo.png?alt=media&token=9a23d52a-2282-4eb7-a751-a8e4fc7b7f8f",
                  // "https://t3.ftcdn.net/jpg/03/46/83/96/360_F_346839683_6nAPzbhpSkIpb8pmAwufkC7c5eD7wYws.jpg",
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
                },
                userUid: adminCreatedUser.uid,
              );
              accountCreated.value = true;

              Get.back();
            } else {
              Get.back();
              Get.dialog(
                SimpleDialog(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Text("User already exists!"),
                    ),
                  ],
                ),
              );
            }

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
    );
  }
}
