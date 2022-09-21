// ignore_for_file: unawaited_futures, avoid_catches_without_on_clauses

import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:diamon_rose_app/constants/Constantcolors.dart';
import 'package:diamon_rose_app/screens/feedPages/feedPage.dart';
import 'package:diamon_rose_app/screens/testVideoEditor/ArContainerClass/ArContainerClass.dart';
import 'package:diamon_rose_app/services/FirebaseOperations.dart';
import 'package:diamon_rose_app/services/authentication.dart';
import 'package:diamon_rose_app/services/video.dart';
import 'package:diamon_rose_app/widgets/global.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:provider/provider.dart';

class EditPreviewVideoScreen extends StatefulWidget {
  const EditPreviewVideoScreen({
    Key? key,
    required this.videoFile,
  }) : super(key: key);

  final Video videoFile;

  @override
  State<EditPreviewVideoScreen> createState() => _EditPreviewVideoScreenState();
}

class _EditPreviewVideoScreenState extends State<EditPreviewVideoScreen> {
  final ConstantColors constantColors = ConstantColors();
  TextEditingController _videotitleController = TextEditingController();
  TextEditingController _videoCaptionController = TextEditingController();
  TextEditingController _contentPrice = TextEditingController();

  String? _setContentPrice;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isFree = true;
  bool _isSubscription = false;
  bool _isPaid = false;

  ValueNotifier<bool> bgSelected = ValueNotifier<bool>(true);

  List<String?> _selectedRecommendedOptions = [];

  DateTime _endDiscountDate = DateTime.now();
  // show todays date as Sun, Jan 14
  DateTime _startDiscountDate = DateTime.now();

  TextEditingController _contentDiscount = TextEditingController();

  String _setContentDiscount = "";

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      setState(() {
        _videotitleController.text = widget.videoFile.videotitle;
        _videoCaptionController.text = widget.videoFile.caption;
        _contentPrice.text = widget.videoFile.price.toString();
        _isFree = widget.videoFile.isFree;
        _isPaid = widget.videoFile.isPaid;
        _selectedRecommendedOptions =
            widget.videoFile.genre.map((e) => e.toString()).toList();
        _contentDiscount.text = widget.videoFile.discountAmount.toString();
        _startDiscountDate = widget.videoFile.startDiscountDate.toDate();
        _endDiscountDate = widget.videoFile.endDiscountDate.toDate();
        _contentAvailableToValue = widget.videoFile.contentAvailability;
      });
    });
  }

  // Function to pick date
  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _startDiscountDate,
        firstDate: _startDiscountDate,
        lastDate: DateTime(2025));
    if (picked != null && picked != _endDiscountDate) {
      setState(() {
        _endDiscountDate = picked;
      });
    }
  }

  // Function to pick date
  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(2025));
    if (picked != null && picked != _startDiscountDate)
      setState(() {
        _startDiscountDate = picked;
        _endDiscountDate = picked;
      });
  }

  List<String?> _recommendedOptions = [
    'Musician',
    'Performer',
    'Dance',
    'Cosplayers',
    'Movie',
    'Actor',
    'Fashion',
    'Landscape',
    'Sports',
    'Animals',
    'Space',
    'Art',
    'Mystery',
    'Airplane',
    'Games',
    'Food',
    'Romance',
    'Sexy',
    'Science fiction',
    'Car',
    'Jobs',
    'Anime',
    'Ship',
    'Railroads',
    'Building',
    'Health',
    'Science',
    'Natural',
    'Machine',
    'Trip',
    'Travel',
    'Fantasy',
    'Funny',
    'Beauty',
  ];

  @override
  void dispose() {
    super.dispose();
  }

  String _contentAvailableToValue = "All";

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final FirebaseOperations firebaseOperations =
        Provider.of<FirebaseOperations>(context, listen: false);
    final Authentication auth =
        Provider.of<Authentication>(context, listen: false);
    return Scaffold(
        appBar: AppBarWidget(text: "Edit Video Settings", context: context),
        backgroundColor: constantColors.bioBg,
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
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    ImageTitleAndCaption(
                      size: size,
                      widget: widget,
                      videotitleController: _videotitleController,
                      videoCaptionController: _videoCaptionController,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Container(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Flexible(
                              flex: 1,
                              child: Text(
                                "Content Available To",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Flexible(
                              flex: 2,
                              child: Container(
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Row(
                                          children: [
                                            Radio(
                                              autofocus: true,
                                              activeColor:
                                                  constantColors.navButton,
                                              value: "All",
                                              groupValue:
                                                  _contentAvailableToValue,
                                              onChanged: (value) {
                                                setState(() {
                                                  _contentAvailableToValue =
                                                      value! as String;
                                                });
                                              },
                                            ),
                                            Text("All"),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Radio(
                                              activeColor:
                                                  constantColors.navButton,
                                              value: "Only Followers",
                                              groupValue:
                                                  _contentAvailableToValue,
                                              onChanged: (value) {
                                                setState(() {
                                                  _contentAvailableToValue =
                                                      value! as String;
                                                });
                                              },
                                            ),
                                            Text("Only Followers")
                                          ],
                                        ),
                                      ],
                                    ),
                                    // Row(
                                    //   children: [
                                    //     Radio(
                                    //       activeColor: constantColors.navButton,
                                    //       value: "Private",
                                    //       groupValue: _contentAvailableToValue,
                                    //       onChanged: (value) {
                                    //         setState(() {
                                    //           _contentAvailableToValue =
                                    //               value! as String;
                                    //         });
                                    //       },
                                    //     ),
                                    //     Text("Private"),
                                    //   ],
                                    // ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    NewDivider(constantColors: constantColors),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Container(
                        child: MultiSelectChipField<String?>(
                          headerColor: constantColors.navButton,
                          initialValue: widget.videoFile.genre
                              .map((e) => e.toString())
                              .toList(),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          selectedChipColor:
                              constantColors.navButton.withOpacity(0.4),
                          title: Text(
                            "Select Genre",
                            style: TextStyle(
                              color: constantColors.whiteColor,
                              fontSize: 15,
                            ),
                          ),
                          items: _recommendedOptions
                              .map((e) => MultiSelectItem(e, e!))
                              .toList(),
                          onTap: (values) {
                            _selectedRecommendedOptions = values;
                          },
                        ),
                      ),
                    ),
                    NewDivider(constantColors: constantColors),
                    Container(
                      color: constantColors.navButton,
                      height: 35,
                      child: Row(
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              "Show / Hide Materials",
                              style: TextStyle(
                                color: constantColors.whiteColor,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    FutureBuilder<QuerySnapshot>(
                      future: FirebaseFirestore.instance
                          .collection("posts")
                          .doc(widget.videoFile.id)
                          .collection("materials")
                          .where("videoId", isEqualTo: widget.videoFile.id)
                          .get(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (!snapshot.hasData) {
                          return Center(
                            child: Text("No Materails To Add / Remove"),
                          );
                        }
                        return ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            final ValueNotifier<bool> hideItem =
                                ValueNotifier<bool>(false);

                            if ((snapshot.data!.docs[index].data()
                                    as Map<String, dynamic>)
                                .containsKey("hideItem")) {
                              hideItem.value =
                                  snapshot.data!.docs[index]['hideItem'];
                            }

                            log("usage types = ${snapshot.data!.docs[index]['layerType']}");

                            switch (snapshot.data!.docs[index]['layerType']) {
                              case "Background":
                                return ValueListenableBuilder(
                                    valueListenable: hideItem,
                                    builder: (context, val, _) {
                                      return ListTile(
                                        trailing: Switch(
                                          activeColor: constantColors.navButton,
                                          value: hideItem.value,
                                          onChanged: (val) async {
                                            hideItem.value = val;
                                            Get.dialog(
                                              SimpleDialog(
                                                backgroundColor:
                                                    constantColors.whiteColor,
                                                title: Text(
                                                  "Updating Hide to ${val.toString().capitalizeFirst}",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: constantColors.black,
                                                  ),
                                                ),
                                              ),
                                              barrierDismissible: false,
                                            );
                                            await firebaseOperations
                                                .hideUnhideItem(
                                                    videoId:
                                                        widget.videoFile.id,
                                                    itemId: snapshot
                                                        .data!.docs[index].id,
                                                    hideVal: val);
                                            Get.back();
                                            Get.dialog(
                                              SimpleDialog(
                                                backgroundColor:
                                                    constantColors.whiteColor,
                                                title: Text(
                                                  "Item hide value updated to ${val}",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: constantColors.black,
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                        leading: Container(
                                          height: 50,
                                          width: 50,
                                          child: Image.network(snapshot
                                              .data!.docs[index]['gif']),
                                        ),
                                        title: Text(
                                          "Background",
                                        ),
                                      );
                                    });
                              case "Effect":
                                return ValueListenableBuilder(
                                    valueListenable: hideItem,
                                    builder: (context, val, _) {
                                      return ListTile(
                                        trailing: Switch(
                                          activeColor: constantColors.navButton,
                                          value: hideItem.value,
                                          onChanged: (val) async {
                                            hideItem.value = val;
                                            Get.dialog(
                                              SimpleDialog(
                                                backgroundColor:
                                                    constantColors.whiteColor,
                                                title: Text(
                                                  "Updating Hide to ${val.toString().capitalizeFirst}",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: constantColors.black,
                                                  ),
                                                ),
                                              ),
                                              barrierDismissible: false,
                                            );
                                            await firebaseOperations
                                                .hideUnhideItem(
                                                    videoId:
                                                        widget.videoFile.id,
                                                    itemId: snapshot
                                                        .data!.docs[index].id,
                                                    hideVal: val);
                                            Get.back();
                                            Get.dialog(
                                              SimpleDialog(
                                                backgroundColor:
                                                    constantColors.whiteColor,
                                                title: Text(
                                                  "Item hide value updated to ${val}",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: constantColors.black,
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                        leading: Container(
                                          height: 50,
                                          width: 50,
                                          child: Image.network(snapshot
                                              .data!.docs[index]['gif']),
                                        ),
                                        title: Text(
                                          "Effect",
                                        ),
                                      );
                                    });
                              case "AR":
                                switch (snapshot.data!.docs[index]['usage']) {
                                  case "Material":
                                    return ValueListenableBuilder(
                                        valueListenable: hideItem,
                                        builder: (context, val, _) {
                                          return ListTile(
                                            trailing: Switch(
                                              activeColor:
                                                  constantColors.navButton,
                                              value: hideItem.value,
                                              onChanged: (val) async {
                                                hideItem.value = val;
                                                Get.dialog(
                                                  SimpleDialog(
                                                    backgroundColor:
                                                        constantColors
                                                            .whiteColor,
                                                    title: Text(
                                                      "Updating Hide to ${val.toString().capitalizeFirst}",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        color: constantColors
                                                            .black,
                                                      ),
                                                    ),
                                                  ),
                                                  barrierDismissible: false,
                                                );
                                                await firebaseOperations
                                                    .hideUnhideItem(
                                                        videoId:
                                                            widget.videoFile.id,
                                                        itemId: snapshot.data!
                                                            .docs[index].id,
                                                        hideVal: val);
                                                Get.back();
                                                Get.dialog(
                                                  SimpleDialog(
                                                    backgroundColor:
                                                        constantColors
                                                            .whiteColor,
                                                    title: Text(
                                                      "Item hide value updated to ${val}",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        color: constantColors
                                                            .black,
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                            leading: Container(
                                              height: 50,
                                              width: 50,
                                              child: Image.network(snapshot
                                                  .data!.docs[index]['gif']),
                                            ),
                                            title: Text(
                                              "AR (Material)",
                                            ),
                                          );
                                        });

                                  case "Ar View Only":
                                    return ValueListenableBuilder(
                                        valueListenable: hideItem,
                                        builder: (context, val, _) {
                                          return ListTile(
                                            trailing: Switch(
                                              activeColor:
                                                  constantColors.navButton,
                                              value: hideItem.value,
                                              onChanged: (val) async {
                                                hideItem.value = val;
                                                Get.dialog(
                                                  SimpleDialog(
                                                    backgroundColor:
                                                        constantColors
                                                            .whiteColor,
                                                    title: Text(
                                                      "Updating Hide to ${val.toString().capitalizeFirst}",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        color: constantColors
                                                            .black,
                                                      ),
                                                    ),
                                                  ),
                                                  barrierDismissible: false,
                                                );
                                                await firebaseOperations
                                                    .hideUnhideItem(
                                                        videoId:
                                                            widget.videoFile.id,
                                                        itemId: snapshot.data!
                                                            .docs[index].id,
                                                        hideVal: val);
                                                Get.back();
                                                Get.dialog(
                                                  SimpleDialog(
                                                    backgroundColor:
                                                        constantColors
                                                            .whiteColor,
                                                    title: Text(
                                                      "Item hide value updated to ${val}",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        color: constantColors
                                                            .black,
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                            leading: Container(
                                              height: 50,
                                              width: 50,
                                              child: Image.network(snapshot
                                                  .data!.docs[index]['gif']),
                                            ),
                                            title: Text(
                                              "AR (Ar View Only)",
                                            ),
                                          );
                                        });

                                  default:
                                    return ValueListenableBuilder(
                                        valueListenable: hideItem,
                                        builder: (context, val, _) {
                                          return ListTile(
                                            trailing: Switch(
                                              activeColor:
                                                  constantColors.navButton,
                                              value: hideItem.value,
                                              onChanged: (val) async {
                                                hideItem.value = val;
                                                Get.dialog(
                                                  SimpleDialog(
                                                    backgroundColor:
                                                        constantColors
                                                            .whiteColor,
                                                    title: Text(
                                                      "Updating Hide to ${val.toString().capitalizeFirst}",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        color: constantColors
                                                            .black,
                                                      ),
                                                    ),
                                                  ),
                                                  barrierDismissible: false,
                                                );
                                                await firebaseOperations
                                                    .hideUnhideItem(
                                                        videoId:
                                                            widget.videoFile.id,
                                                        itemId: snapshot.data!
                                                            .docs[index].id,
                                                        hideVal: val);
                                                Get.back();
                                                Get.dialog(
                                                  SimpleDialog(
                                                    backgroundColor:
                                                        constantColors
                                                            .whiteColor,
                                                    title: Text(
                                                      "Item hide value updated to ${val}",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        color: constantColors
                                                            .black,
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                            leading: Container(
                                              height: 50,
                                              width: 50,
                                              child: Image.network(snapshot
                                                  .data!.docs[index]['gif']),
                                            ),
                                            title: Text(
                                              "AR",
                                            ),
                                          );
                                        });
                                }

                              default:
                                return ListTile(
                                  trailing: Switch(
                                    activeColor: constantColors.navButton,
                                    value: hideItem.value,
                                    onChanged: (val) {
                                      hideItem.value = val;
                                    },
                                  ),
                                  leading: Container(
                                    height: 50,
                                    width: 50,
                                    child: Image.network(
                                        snapshot.data!.docs[index]['gif']),
                                  ),
                                  title: Text(
                                    "Background",
                                  ),
                                );
                            }
                          },
                        );
                      },
                    ),
                    NewDivider(constantColors: constantColors),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          leading: Icon(FontAwesomeIcons.cloudDownloadAlt),
                          minLeadingWidth: 10,
                          trailing: Switch(
                              activeColor: constantColors.navButton,
                              value: _isFree,
                              onChanged: (value) {
                                setState(() {
                                  _isFree = value;
                                  _isPaid = !value;
                                });
                              }),
                          title: Text(
                            "Free",
                          ),
                        ),
                        // ListTile(
                        //   leading: Icon(FontAwesomeIcons.users),
                        //   minLeadingWidth: 10,
                        //   trailing: Switch(
                        //       activeColor: constantColors.navButton,
                        //       value: _isSubscription,
                        //       onChanged: (value) {
                        //         setState(() {
                        //           _isSubscription = value;
                        //         });
                        //       }),
                        //   title: Text(
                        //     "Subscription",
                        //   ),
                        // ),
                        ListTile(
                          leading: Icon(FontAwesomeIcons.moneyBillAlt),
                          minLeadingWidth: 10,
                          trailing: Switch(
                            activeColor: constantColors.navButton,
                            value: _isPaid,
                            onChanged: (value) {
                              setState(() {
                                _isPaid = value;
                                _isFree = !value;
                              });
                            },
                          ),
                          title: Text(
                            "Premium",
                          ),
                        ),
                        Visibility(
                          visible: _isPaid,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    "Price",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 40,
                                  ),
                                  Expanded(
                                    child: Container(
                                      height: 50,
                                      child: TextFormField(
                                        validator: (value) {
                                          if (value!.isEmpty &&
                                              int.parse(value) <= 0) {
                                            return "Please enter a price";
                                          }
                                          return null;
                                        },
                                        controller: _contentPrice,
                                        onChanged: (value) {
                                          setState(() {
                                            _setContentPrice = value;
                                          });
                                        },
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                          suffixIcon: Icon(
                                            FontAwesomeIcons.dollarSign,
                                            size: 16,
                                            color: constantColors.navButton,
                                          ),
                                          labelStyle:
                                              TextStyle(color: Colors.black),
                                          border: OutlineInputBorder(),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide:
                                                BorderSide(color: Colors.black),
                                            borderRadius:
                                                BorderRadius.circular(30),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide:
                                                BorderSide(color: Colors.black),
                                            borderRadius:
                                                BorderRadius.circular(30),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              Padding(
                                padding: EdgeInsets.only(
                                  top: 10,
                                ),
                                // Row widget where the user can set the discount amount
                                child: Row(
                                  children: [
                                    Text(
                                      "Discount",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                      child: Container(
                                        height: 50,
                                        child: TextFormField(
                                          validator: (value) {
                                            if (_isPaid == true &&
                                                value!.isNotEmpty) {
                                              final double endPrice =
                                                  double.parse(
                                                          _contentPrice.text) *
                                                      (1 -
                                                          double.parse(value) /
                                                              100);

                                              if (endPrice >= 1.00) {
                                                return null;
                                              } else {
                                                return "Total price after discount too low";
                                              }
                                            }
                                            return null;
                                          },
                                          controller: _contentDiscount,
                                          onChanged: (value) {
                                            setState(() {
                                              _setContentDiscount = value;
                                            });
                                          },
                                          keyboardType: TextInputType.number,
                                          decoration: InputDecoration(
                                            suffixIcon: Icon(
                                              FontAwesomeIcons.percentage,
                                              size: 16,
                                              color: constantColors.navButton,
                                            ),
                                            labelStyle:
                                                TextStyle(color: Colors.black),
                                            border: OutlineInputBorder(),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.black),
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.black),
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // TextWidget saying "Sales Period"
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Text(
                                  "Discount Period",
                                  style: TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Container(
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: constantColors.navButton,
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      TextButton.icon(
                                        style: TextButton.styleFrom(
                                          primary: Colors.white,
                                        ),
                                        onPressed: () =>
                                            _selectStartDate(context),
                                        icon: Icon(Icons.calendar_month),
                                        label: Text(
                                          "${DateFormat("E, MMM, d").format(_startDiscountDate)}",
                                        ),
                                      ),
                                      Text(
                                        ">",
                                        style: TextStyle(
                                          color: constantColors.whiteColor,
                                          fontSize: 40,
                                        ),
                                      ),
                                      TextButton.icon(
                                        style: TextButton.styleFrom(
                                          primary: Colors.white,
                                        ),
                                        onPressed: () =>
                                            _selectEndDate(context),
                                        icon: Icon(Icons.calendar_month),
                                        label: Text(
                                            "${DateFormat("E, MMM, d").format(_endDiscountDate)}"),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 10,
                                ),
                                child: Text(
                                  "*Due to the regulations of the App Stores, purchases made with in-app payment by the user will result in price differences to accommodate the split between the Creator, Glamorous Diastation and the App Stores.",
                                  style: TextStyle(
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 30, bottom: 30),
                          child: SubmitButton(
                              text: "Update Post",
                              function: () async {
                                if (_formKey.currentState!.validate() &&
                                    _selectedRecommendedOptions.length > 0) {
                                  // ignore: unawaited_futures
                                  CoolAlert.show(
                                      barrierDismissible: false,
                                      context: context,
                                      type: CoolAlertType.loading,
                                      text: "Updating Video");
                                  try {
                                    log("updating video");
                                    firebaseOperations
                                        .updatePost(
                                      caption: _videoCaptionController.text,
                                      video_title: _videotitleController.text,
                                      videoId: widget.videoFile.id,
                                      isFree: _isFree,
                                      isPaid: _isPaid,
                                      price: double.parse(_contentPrice.text),
                                      discountAmount:
                                          double.parse(_contentDiscount.text),
                                      startDiscountDate: Timestamp.fromDate(
                                          _startDiscountDate),
                                      endDiscountDate:
                                          Timestamp.fromDate(_endDiscountDate),
                                      genre: _selectedRecommendedOptions,
                                      contentAvailability:
                                          _contentAvailableToValue,
                                    )
                                        .whenComplete(() {
                                      Get.to(() => FeedPage(
                                            pageIndexValue: 4,
                                          ));
                                      Get.snackbar(
                                        'Video Updated ✅',
                                        "Your video has been updated!",
                                        overlayColor: constantColors.navButton,
                                        colorText: constantColors.whiteColor,
                                        snackPosition: SnackPosition.TOP,
                                        forwardAnimationCurve:
                                            Curves.elasticInOut,
                                        reverseAnimationCurve: Curves.easeOut,
                                      );
                                    });
                                  } catch (e) {
                                    CoolAlert.show(
                                      context: context,
                                      type: CoolAlertType.error,
                                      title: "Error Uploading Video",
                                      text: e.toString(),
                                    );
                                  }
                                } else if (_selectedRecommendedOptions.length ==
                                    0) {
                                  CoolAlert.show(
                                    context: context,
                                    type: CoolAlertType.error,
                                    title: "No Selected Genre",
                                    text:
                                        "Please Select a Genre for your video",
                                  );
                                }
                              }),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}

class NewDivider extends StatelessWidget {
  const NewDivider({
    Key? key,
    required this.constantColors,
  }) : super(key: key);

  final ConstantColors constantColors;

  @override
  Widget build(BuildContext context) {
    return Divider(
      thickness: 2,
      color: constantColors.navButton.withOpacity(0.3),
    );
  }
}

class ImageTitleAndCaption extends StatelessWidget {
  const ImageTitleAndCaption({
    Key? key,
    required this.size,
    required this.widget,
    required TextEditingController videotitleController,
    required TextEditingController videoCaptionController,
  })  : _videotitleController = videotitleController,
        _videoCaptionController = videoCaptionController,
        super(key: key);

  final Size size;
  final EditPreviewVideoScreen widget;
  final TextEditingController _videotitleController;
  final TextEditingController _videoCaptionController;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Flexible widget with video in it
        Flexible(
          flex: 1,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              height: size.height * 0.25,
              child: ImageNetworkLoader(
                imageUrl: widget.videoFile.thumbnailurl,
              ),
            ),
          ),
        ),
        Flexible(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Container(
              height: size.height * 0.25,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    child: ProfileUserDetails(
                      controller: _videotitleController,
                      labelText: "Title",
                      onSubmit: (val) {},
                      validator: (val) {
                        if (val!.isEmpty) {
                          return "Please Enter a Title";
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Container(
                      child: ProfileUserDetails(
                        lines: 4,
                        controller: _videoCaptionController,
                        labelText: "Caption",
                        onSubmit: (val) {},
                        validator: (val) {
                          if (val!.isEmpty) {
                            return "Please Enter a Caption";
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }
}
