import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diamon_rose_app/constants/Constantcolors.dart';
import 'package:diamon_rose_app/services/user.dart';
import 'package:diamon_rose_app/widgets/global.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sizer/sizer.dart';

class AdminUserPromoScreen extends StatelessWidget {
  AdminUserPromoScreen({Key? key}) : super(key: key);
  final ValueNotifier<UserModel?> selectedUser =
      ValueNotifier<UserModel?>(null);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: constantColors.whiteColor,
      appBar: AppBarWidget(text: "Admin User Promocodes", context: context),
      body: AnimatedBuilder(
        animation: Listenable.merge([selectedUser]),
        builder: (context, _) {
          return Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DropdownSearch<UserModel>(
                        showSelectedItems: true,
                        compareFn: (i, s) => i == s,
                        dropdownSearchDecoration: InputDecoration(
                          labelText: "User",
                          contentPadding: EdgeInsets.fromLTRB(12, 12, 0, 0),
                          border: OutlineInputBorder(),
                        ),
                        onFind: (String? filter) => getData(filter),
                        onChanged: (data) {
                          selectedUser.value = data;
                        },
                        dropdownBuilder: _customDropDownExample,
                        popupItemBuilder: _customPopupItemBuilderExample2,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                InkWell(
                  onTap: () async {
                    await Share.share(
                      "Hi ${selectedUser.value!.username.toString().capitalize()}, your promocode is : ${selectedUser.value!.useruid.substring(0, 4).toUpperCase()}",
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
                          selectedUser.value!.useruid
                              .substring(0, 4)
                              .toUpperCase(),
                          style: TextStyle(
                            color: constantColors.whiteColor,
                            fontSize: 30,
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "Click to share this Promo code with the user",
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
              ],
            ),
          );
        },
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
