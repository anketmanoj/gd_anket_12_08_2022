import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diamon_rose_app/constants/Constantcolors.dart';
import 'package:diamon_rose_app/providers/promoCodeModel.dart';
import 'package:diamon_rose_app/services/user.dart';
import 'package:diamon_rose_app/widgets/global.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sizer/sizer.dart';

class AdminUserPromoScreen extends StatefulWidget {
  AdminUserPromoScreen({Key? key}) : super(key: key);

  @override
  State<AdminUserPromoScreen> createState() => _AdminUserPromoScreenState();
}

class _AdminUserPromoScreenState extends State<AdminUserPromoScreen>
    with TickerProviderStateMixin {
  final ValueNotifier<UserModel?> selectedUser =
      ValueNotifier<UserModel?>(null);
  late TabController tabController;

  List<PromoCodeModel> promoCodeList = [];
  List<PromoCodeModel> filteredList = [];

  void getDataPromo() async {
    await FirebaseFirestore.instance
        .collection("promoTracker")
        .get()
        .then((value) {
      for (var element in value.docs) {
        PromoCodeModel promoData = PromoCodeModel.fromMap(element.data());
        promoCodeList.add(promoData);
        log("added");
      }

      setState(() {});
    });
  }

  Future<List<PromoCodeModel>> getDataPromoDrop() async {
    final List<PromoCodeModel> promoList = promoCodeList;

    return promoList;
  }

  @override
  void initState() {
    super.initState();
    tabController = TabController(
      initialIndex: 0,
      length: 2,
      vsync: this,
    );
    getDataPromo();
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

  int? sortColumnIndex;
  bool isAscending = false;
  ValueNotifier<bool> showFAB = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
        valueListenable: showFAB,
        builder: (context, showFABVal, _) {
          return Scaffold(
            backgroundColor: constantColors.whiteColor,
            appBar:
                AppBarWidget(text: "Admin User Promocodes", context: context),
            floatingActionButton: showFABVal
                ? FloatingActionButton(
                    backgroundColor: constantColors.navButton,
                    child: Icon(
                      Icons.filter_alt,
                      color: constantColors.whiteColor,
                    ),
                    onPressed: () async {
                      await showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return Container(
                            height: 40.h,
                            width: 100.w,
                            color: constantColors.whiteColor,
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 150),
                                  child: Divider(
                                    thickness: 4,
                                    color: constantColors.navButton,
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: DropdownSearch<PromoCodeModel>(
                                        showSelectedItems: true,
                                        compareFn: (i, s) => i == s,
                                        dropdownSearchDecoration:
                                            InputDecoration(
                                          labelText: "Filter by Username",
                                          contentPadding:
                                              EdgeInsets.fromLTRB(12, 12, 0, 0),
                                          border: OutlineInputBorder(),
                                        ),
                                        onFind: (String? filter) =>
                                            getDataPromoDrop(),
                                        onChanged: (data) {
                                          setState(() {
                                            filteredList = promoCodeList
                                                .where((element) =>
                                                    element.name == data!.name)
                                                .toList();
                                          });
                                        },
                                        dropdownBuilder: _customDropDownPromo,
                                        popupItemBuilder:
                                            _customPopupItemBuilderPromo,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      filteredList.clear();
                                    });
                                  },
                                  child: Text("Reset Filters"),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  )
                : SizedBox(),
            bottomNavigationBar: Container(
              width: 400,
              height: 10.h,
              child: TabBar(
                labelColor: Color.fromRGBO(4, 2, 46, 1),
                indicatorColor: Color.fromRGBO(4, 2, 46, 1),
                unselectedLabelColor: Colors.grey,
                controller: tabController,
                onTap: (int va) {
                  if (va == 1) {
                    showFAB.value = true;
                  } else {
                    showFAB.value = false;
                  }
                },
                tabs: [
                  Text('Get Code'),
                  Text('Tracker'),
                ],
              ),
            ),
            body: TabBarView(
              controller: tabController,
              physics: NeverScrollableScrollPhysics(),
              children: [
                AnimatedBuilder(
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
                                    contentPadding:
                                        EdgeInsets.fromLTRB(12, 12, 0, 0),
                                    border: OutlineInputBorder(),
                                  ),
                                  onFind: (String? filter) => getData(filter),
                                  onChanged: (data) {
                                    selectedUser.value = data;
                                  },
                                  dropdownBuilder: _customDropDownExample,
                                  popupItemBuilder:
                                      _customPopupItemBuilderExample2,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          selectedUser.value != null
                              ? InkWell(
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                )
                              : SizedBox(),
                        ],
                      ),
                    );
                  },
                ),
                filteredList.isEmpty
                    ? Column(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                sortColumnIndex: sortColumnIndex,
                                sortAscending: isAscending,
                                columns: [
                                  DataColumn(
                                    label: Text("Date"),
                                    onSort: (int, bool) {
                                      setState(() {
                                        this.sortColumnIndex = int;
                                        this.isAscending = bool;
                                      });

                                      switch (isAscending) {
                                        case true:
                                          promoCodeList.sort((a, b) =>
                                              b.date.compareTo(a.date));
                                          promoCodeList.forEach((element) {
                                            log(element.date.toString());
                                          });

                                          break;
                                        case false:
                                          promoCodeList.sort((a, b) =>
                                              a.date.compareTo(b.date));
                                          promoCodeList.forEach((element) {
                                            log(element.date.toString());
                                          });
                                          break;
                                        default:
                                      }
                                    },
                                  ),
                                  DataColumn(
                                    label: Text("Name"),
                                    onSort: (int, bool) {
                                      setState(() {
                                        this.sortColumnIndex = int;
                                        this.isAscending = bool;
                                      });

                                      switch (isAscending) {
                                        case true:
                                          promoCodeList.sort((a, b) =>
                                              b.name.compareTo(a.name));
                                          promoCodeList.forEach((element) {
                                            log(element.name);
                                          });

                                          break;
                                        case false:
                                          promoCodeList.sort((a, b) =>
                                              a.name.compareTo(b.name));
                                          promoCodeList.forEach((element) {
                                            log(element.name);
                                          });
                                          break;
                                        default:
                                      }
                                    },
                                  ),
                                  DataColumn(
                                      label: Text("Promo Code"),
                                      onSort: (int, bool) {
                                        setState(() {
                                          this.sortColumnIndex = int;
                                          this.isAscending = bool;
                                        });

                                        switch (int) {
                                          case 0:
                                            switch (isAscending) {
                                              case true:
                                                promoCodeList.sort((a, b) => b
                                                    .promocode
                                                    .compareTo(a.promocode));
                                                promoCodeList
                                                    .forEach((element) {
                                                  log(element.promocode);
                                                });

                                                break;
                                              case false:
                                                promoCodeList.sort((a, b) => a
                                                    .promocode
                                                    .compareTo(b.promocode));
                                                promoCodeList
                                                    .forEach((element) {
                                                  log(element.promocode);
                                                });
                                                break;
                                              default:
                                            }
                                            break;
                                          default:
                                        }
                                      }),
                                  DataColumn(
                                      label: Text("Creator Name"),
                                      onSort: (int, bool) {
                                        setState(() {
                                          this.sortColumnIndex = int;
                                          this.isAscending = bool;
                                        });

                                        switch (int) {
                                          case 0:
                                            switch (isAscending) {
                                              case true:
                                                promoCodeList.sort((a, b) => b
                                                    .creatorname
                                                    .compareTo(a.creatorname));
                                                promoCodeList
                                                    .forEach((element) {
                                                  log(element.creatorname);
                                                });

                                                break;
                                              case false:
                                                promoCodeList.sort((a, b) => a
                                                    .creatorname
                                                    .compareTo(b.creatorname));
                                                promoCodeList
                                                    .forEach((element) {
                                                  log(element.creatorname);
                                                });
                                                break;
                                              default:
                                            }
                                            break;
                                          default:
                                        }
                                      }),
                                ],
                                rows: promoCodeList
                                    .map((PromoCodeModel promoCodeModel) {
                                  return DataRow(
                                    cells: [
                                      DataCell(Text(promoCodeModel.date
                                          .toDate()
                                          .toString()
                                          .substring(0, 10))),
                                      DataCell(Text(promoCodeModel.name)),
                                      DataCell(Text(promoCodeModel.promocode
                                          .toUpperCase())),
                                      DataCell(Text(promoCodeModel.creatorname
                                          .capitalize())),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              children: [
                                Text(
                                  "Total Rows: ",
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  promoCodeList.length.toString(),
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                sortColumnIndex: sortColumnIndex,
                                sortAscending: isAscending,
                                columns: [
                                  DataColumn(
                                    label: Text("Date"),
                                    onSort: (int, bool) {
                                      setState(() {
                                        this.sortColumnIndex = int;
                                        this.isAscending = bool;
                                      });

                                      switch (isAscending) {
                                        case true:
                                          filteredList.sort((a, b) =>
                                              b.date.compareTo(a.date));
                                          filteredList.forEach((element) {
                                            log(element.date.toString());
                                          });

                                          break;
                                        case false:
                                          filteredList.sort((a, b) =>
                                              a.date.compareTo(b.date));
                                          filteredList.forEach((element) {
                                            log(element.date.toString());
                                          });
                                          break;
                                        default:
                                      }
                                    },
                                  ),
                                  DataColumn(
                                    label: Text("Name"),
                                    onSort: (int, bool) {
                                      setState(() {
                                        this.sortColumnIndex = int;
                                        this.isAscending = bool;
                                      });

                                      switch (isAscending) {
                                        case true:
                                          filteredList.sort((a, b) =>
                                              b.name.compareTo(a.name));
                                          filteredList.forEach((element) {
                                            log(element.name);
                                          });

                                          break;
                                        case false:
                                          filteredList.sort((a, b) =>
                                              a.name.compareTo(b.name));
                                          filteredList.forEach((element) {
                                            log(element.name);
                                          });
                                          break;
                                        default:
                                      }
                                    },
                                  ),
                                  DataColumn(
                                      label: Text("Promo Code"),
                                      onSort: (int, bool) {
                                        setState(() {
                                          this.sortColumnIndex = int;
                                          this.isAscending = bool;
                                        });

                                        switch (int) {
                                          case 0:
                                            switch (isAscending) {
                                              case true:
                                                filteredList.sort((a, b) => b
                                                    .promocode
                                                    .compareTo(a.promocode));
                                                filteredList.forEach((element) {
                                                  log(element.promocode);
                                                });

                                                break;
                                              case false:
                                                filteredList.sort((a, b) => a
                                                    .promocode
                                                    .compareTo(b.promocode));
                                                filteredList.forEach((element) {
                                                  log(element.promocode);
                                                });
                                                break;
                                              default:
                                            }
                                            break;
                                          default:
                                        }
                                      }),
                                  DataColumn(
                                      label: Text("Creator Name"),
                                      onSort: (int, bool) {
                                        setState(() {
                                          this.sortColumnIndex = int;
                                          this.isAscending = bool;
                                        });

                                        switch (int) {
                                          case 0:
                                            switch (isAscending) {
                                              case true:
                                                filteredList.sort((a, b) => b
                                                    .creatorname
                                                    .compareTo(a.creatorname));
                                                filteredList.forEach((element) {
                                                  log(element.creatorname);
                                                });

                                                break;
                                              case false:
                                                filteredList.sort((a, b) => a
                                                    .creatorname
                                                    .compareTo(b.creatorname));
                                                filteredList.forEach((element) {
                                                  log(element.creatorname);
                                                });
                                                break;
                                              default:
                                            }
                                            break;
                                          default:
                                        }
                                      }),
                                ],
                                rows: filteredList
                                    .map((PromoCodeModel promoCodeModel) {
                                  return DataRow(
                                    cells: [
                                      DataCell(Text(promoCodeModel.date
                                          .toDate()
                                          .toString()
                                          .substring(0, 10))),
                                      DataCell(Text(promoCodeModel.name)),
                                      DataCell(Text(promoCodeModel.promocode
                                          .toUpperCase())),
                                      DataCell(Text(promoCodeModel.creatorname
                                          .capitalize())),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              children: [
                                Text(
                                  "Total Rows: ",
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  filteredList.length.toString(),
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
              ],
            ),
          );
        });
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

  Widget _customDropDownPromo(BuildContext context, PromoCodeModel? item) {
    if (item == null) {
      return Container();
    }

    return Container(
      child: ListTile(
        contentPadding: EdgeInsets.all(0),
        title: Text(item.name),
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

  Widget _customPopupItemBuilderPromo(
      BuildContext context, PromoCodeModel? item, bool isSelected) {
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
        title: Text(item?.name ?? ''),
      ),
    );
  }
}
