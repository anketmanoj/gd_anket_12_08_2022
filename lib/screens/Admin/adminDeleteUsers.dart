// ignore_for_file: prefer_const_constructors

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:diamon_rose_app/services/FirebaseOperations.dart';
import 'package:diamon_rose_app/services/aws/aws_upload_service.dart';
import 'package:diamon_rose_app/services/user.dart';
import 'package:diamon_rose_app/translations/locale_keys.g.dart';
import 'package:diamon_rose_app/widgets/global.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:nanoid/nanoid.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'package:universal_io/io.dart';

class AdminDeleteUsers extends StatefulWidget {
  AdminDeleteUsers({
    Key? key,
  }) : super(key: key);

  @override
  State<AdminDeleteUsers> createState() => _AdminDeleteUsersState();
}

class _AdminDeleteUsersState extends State<AdminDeleteUsers> {
  final ValueNotifier<UserModel?> selectedUser =
      ValueNotifier<UserModel?>(null);
  final _formKey = GlobalKey<FormState>();
  TextEditingController _userPercentageController = TextEditingController();
  TextEditingController _userCaratsController = TextEditingController();
  final ValueNotifier<bool> _isVerified = ValueNotifier<bool>(true);

  @override
  Widget build(BuildContext context) {
    final FirebaseOperations firebaseOperations =
        Provider.of<FirebaseOperations>(context, listen: false);
    return Scaffold(
      backgroundColor: constantColors.bioBg,
      appBar: AppBarWidget(text: "User Details", context: context),
      body: GestureDetector(
        onTap: () {
          final FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus &&
              currentFocus.focusedChild != null) {
            FocusManager.instance.primaryFocus!.unfocus();
          }
        },
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: AnimatedBuilder(
              animation: Listenable.merge([
                selectedUser,
                _isVerified,
              ]),
              builder: (context, _) {
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: DropdownSearch<UserModel>(
                              showSearchBox: true,
                              itemAsString: (UserModel? u) => u!.username,
                              showSelectedItems: true,
                              compareFn: (i, s) => i == s,
                              dropdownSearchDecoration: InputDecoration(
                                labelText: "User",
                                contentPadding:
                                    EdgeInsets.fromLTRB(12, 12, 0, 0),
                                border: OutlineInputBorder(),
                              ),
                              onFind: (String? filter) => getData(filter),
                              onChanged: (data) {
                                selectedUser.value = data;
                                _userPercentageController.text =
                                    data!.percentage.toString();
                                _isVerified.value = data.isverified!;
                                _userCaratsController.text =
                                    data.userCarats.toString();
                              },
                              dropdownBuilder: _customDropDownExample,
                              popupItemBuilder: _customPopupItemBuilderExample2,
                            ),
                          ),
                        ],
                      ),
                      selectedUser.value != null
                          ? Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: Column(
                                children: [
                                  ListTile(
                                    leading: Container(
                                      width: 50,
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: NetworkImage(
                                              selectedUser.value!.userimage),
                                        ),
                                      ),
                                    ),
                                    title: Text(selectedUser.value!.username),
                                    subtitle:
                                        Text(selectedUser.value!.useremail),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 30, bottom: 30),
                                    child: SubmitButton(
                                      text: "Delete User",
                                      function: () async {},
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Container(),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _customDropDownExample(BuildContext context, UserModel? item) {
    if (item == null) {
      return Container();
    }

    return Container(
      child: (item.userimage == null)
          ? ListTile(
              contentPadding: EdgeInsets.all(0),
              leading: CircleAvatar(),
              title: Text("No item selected"),
            )
          : ListTile(
              contentPadding: EdgeInsets.all(0),
              leading: CircleAvatar(
                // this does not work - throws 404 error
                backgroundImage: NetworkImage(item.userimage),
              ),
              title: Text(item.username),
              subtitle: Text(
                item.useremail,
              ),
            ),
    );
  }

  Future<List<UserModel>> getData(filter) async {
    List<UserModel> userList = [];

    await FirebaseFirestore.instance
        .collection("users")
        .orderBy("username")
        .get()
        .then((value) {
      value.docs.forEach((element) {
        UserModel userModel = UserModel.fromMap(element.data());

        userList.add(userModel);
      });
    });

    return userList;
  }

  Widget _customPopupItemBuilderExample2(
      BuildContext context, UserModel? item, bool isSelected) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8),
      decoration: !isSelected
          ? null
          : BoxDecoration(
              border: Border.all(color: Theme.of(context).primaryColor),
              borderRadius: BorderRadius.circular(5),
              color: Colors.white,
            ),
      child: ListTile(
        selected: isSelected,
        title: Text(item?.username ?? ''),
        subtitle: Text(item?.useremail.toString() ?? ''),
        leading: CircleAvatar(
          // this does not work - throws 404 error
          backgroundImage: NetworkImage(item?.userimage ?? ''),
        ),
      ),
    );
  }
}
