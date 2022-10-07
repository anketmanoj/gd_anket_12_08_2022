import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:diamon_rose_app/services/FirebaseOperations.dart';
import 'package:diamon_rose_app/services/authentication.dart';
import 'package:diamon_rose_app/translations/locale_keys.g.dart';
import 'package:diamon_rose_app/widgets/global.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({Key? key}) : super(key: key);

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final userProvider =
        Provider.of<FirebaseOperations>(context, listen: false);

    final TextEditingController _usernameController =
        TextEditingController(text: userProvider.initUserName);
    final TextEditingController _realnameController =
        TextEditingController(text: userProvider.userrealname);
    final TextEditingController _emailController =
        TextEditingController(text: userProvider.initUserEmail);
    final TextEditingController _phonenumberController =
        TextEditingController(text: userProvider.usercontactnumber);
    final TextEditingController _addressController =
        TextEditingController(text: userProvider.userAddress);
    final TextEditingController _genderController =
        TextEditingController(text: userProvider.usergender);
    final TextEditingController _userbioController =
        TextEditingController(text: userProvider.userbio);
    Timestamp _birthdayController = userProvider.userdob;
    String countryValue;

    String countryCode = userProvider.usercountrycode;
    String genderValue = userProvider.usergender;

    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBarWidget(text: "Profile", context: context),
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
                    onSubmit:
                        userProvider.setUserName(_usernameController.text),
                    controller: _usernameController,
                    labelText: LocaleKeys.username.tr(),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Username cannot be empty';
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 25),
                  child: ProfileUserDetails(
                    onSubmit:
                        userProvider.setUserRealName(_realnameController.text),
                    controller: _realnameController,
                    labelText: LocaleKeys.name.tr(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 25),
                  child: ProfileUserDetails(
                    onSubmit: userProvider.setUserBio(_userbioController.text),
                    controller: _userbioController,
                    labelText: LocaleKeys.yourbio.tr(),
                    lines: 3,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 25),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Container(
                          width: 75,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: CountryCodePicker(
                            onChanged: (value) {
                              // print(value.toString());
                              userProvider.setCountryCode(value.toString());
                            },
                            initialSelection: userProvider.usercountrycode,
                            showCountryOnly: true,
                            favorite: ['+971', 'JP'],
                            showOnlyCountryWhenClosed: false,
                            showFlagMain: false,
                            showFlag: true,
                          ),
                        ),
                      ),
                      Expanded(
                        child: ProfileUserDetails(
                          onSubmit: userProvider.setUserContactNumber(
                              _phonenumberController.text),
                          controller: _phonenumberController,
                          labelText: LocaleKeys.telephonenumber.tr(),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        LocaleKeys.selectcountry.tr(),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: CountryCodePicker(
                              showDropDownButton: true,
                              onChanged: (value) {
                                log(value.name!);
                                userProvider
                                    .setUserAddress(value.name.toString());
                                _addressController.text = value.name!;
                              },
                              initialSelection: _addressController.text,
                              showCountryOnly: true,
                              favorite: ['+971', 'JP'],
                              showOnlyCountryWhenClosed: true,
                              showFlagMain: true,
                              showFlag: true,
                              showFlagDialog: true,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        LocaleKeys.gender.tr(),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Radio(
                              activeColor: constantColors.mainColor,
                              focusColor: constantColors.mainColor,
                              toggleable: true,
                              value: "Male",
                              groupValue: genderValue,
                              onChanged: (value) {
                                userProvider.setUserGender(value.toString());
                                setState(() {});
                              },
                            ),
                            Text("Male"),
                            Radio(
                              activeColor: constantColors.mainColor,
                              focusColor: constantColors.mainColor,
                              toggleable: true,
                              value: "Female",
                              groupValue: genderValue,
                              onChanged: (value) {
                                userProvider.setUserGender(value.toString());
                                setState(() {});
                              },
                            ),
                            Text("Female"),
                            Radio(
                              activeColor: constantColors.mainColor,
                              focusColor: constantColors.mainColor,
                              toggleable: true,
                              value: "Other",
                              groupValue: genderValue,
                              onChanged: (value) {
                                userProvider.setUserGender(value.toString());
                                setState(() {});
                              },
                            ),
                            Text("Other"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        LocaleKeys.dateofbirth.tr(),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        width: size.width,
                        height: 60,
                        child: ElevatedButton(
                          style: ButtonStyle(
                            foregroundColor:
                                MaterialStateProperty.all<Color>(Colors.white),
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.purple),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                          onPressed: () {
                            showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(1900),
                              lastDate: DateTime(2050),
                            ).then((date) {
                              if (date != null) {
                                userProvider.setDob(Timestamp.fromDate(date));
                                setState(() {});
                              }
                            });
                          },
                          child: Text(
                            _birthdayController
                                .toDate()
                                .toString()
                                .split(" ")[0],
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                SubmitButton(
                  function: () async {
                    if (_formKey.currentState!.validate()) {
                      // show updating data alert
                      // ignore: unawaited_futures
                      showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text("Updating data"),
                          content:
                              Text("Please wait while we update your data"),
                        ),
                      );

                      await userProvider
                          .updateUserData(
                        uid: Provider.of<Authentication>(context, listen: false)
                            .getUserId,
                        username: _usernameController.text,
                        userrealname: _realnameController.text,
                        userContactNumber: _phonenumberController.text,
                        userAddress: _addressController.text,
                        userDob: _birthdayController,
                        userGender: genderValue,
                        countryCode: userProvider.usercountrycode,
                        userbio: _userbioController.text,
                      )
                          .whenComplete(() async {
                        await userProvider.initUserData(context);
                        Navigator.pop(context);
                      });
                    }
                  },
                ),
                const SizedBox(
                  height: 40,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
