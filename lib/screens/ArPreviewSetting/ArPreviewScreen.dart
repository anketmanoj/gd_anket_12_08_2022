// ignore_for_file: avoid_catches_without_on_clauses, unawaited_futures

import 'dart:developer' as dev;
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:diamon_rose_app/constants/Constantcolors.dart';
import 'package:diamon_rose_app/providers/ffmpegProviders.dart';
import 'package:diamon_rose_app/screens/PostPage/previewVideo.dart';
import 'package:diamon_rose_app/services/ArViewOnlyServerResponse.dart';
import 'package:diamon_rose_app/services/FirebaseOperations.dart';
import 'package:diamon_rose_app/services/authentication.dart';
import 'package:diamon_rose_app/widgets/global.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:multi_select_flutter/chip_field/multi_select_chip_field.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:provider/provider.dart';
import 'package:toggle_switch/toggle_switch.dart';

class ArPreviewSetting extends StatelessWidget {
  ArPreviewSetting({
    Key? key,
    required this.gifUrl,
    required this.ownerName,
    required this.audioFlag,
    required this.alphaUrl,
    required this.audioUrl,
    required this.imgSeqList,
    required this.arIdVal,
    required this.inputUrl,
    required this.userUid,
    required this.endDuration,
  }) : super(key: key);
  final String gifUrl;
  final String ownerName;
  final int audioFlag;
  final String alphaUrl;
  final String audioUrl;
  final List<String> imgSeqList;
  final String arIdVal;
  final String inputUrl;
  final String userUid;
  final Duration endDuration;

  final ConstantColors constantColors = ConstantColors();

  TextEditingController _arTitleController = TextEditingController();
  TextEditingController _arCaptionController = TextEditingController();
  ValueNotifier<TextEditingController> _arPrice =
      ValueNotifier<TextEditingController>(TextEditingController());
  ValueNotifier<TextEditingController> _contentDiscount =
      ValueNotifier<TextEditingController>(TextEditingController());

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  ValueNotifier<String> _arAs = ValueNotifier<String>("Material");
  ValueNotifier<DateTime> _endDiscountDate =
      ValueNotifier<DateTime>(DateTime.now());
  ValueNotifier<DateTime> _startDiscountDate =
      ValueNotifier<DateTime>(DateTime.now());
  ValueNotifier<bool> _isFree = ValueNotifier<bool>(true);
  ValueNotifier<bool> _isPaid = ValueNotifier<bool>(false);
  ValueNotifier<List<String>> bgImage = ValueNotifier<List<String>>([
    "https://firebasestorage.googleapis.com/v0/b/gdfe-ac584.appspot.com/o/bgImagesAR%2Fpexels-aleksandar-pasaric-2385210.jpg?alt=media&token=cefa1d4f-6b9d-494a-8be6-ed6679bd7f33",
    "https://firebasestorage.googleapis.com/v0/b/gdfe-ac584.appspot.com/o/bgImagesAR%2Fpexels-l-a-10799832.jpg?alt=media&token=790a7a0b-7f3e-4e5a-a0db-690c06204642",
    "https://firebasestorage.googleapis.com/v0/b/gdfe-ac584.appspot.com/o/bgImagesAR%2Fpexels-yuri-yuhara-4151484.jpg?alt=media&token=6772581b-2533-40bc-befc-79f7e303b5fe",
    "https://firebasestorage.googleapis.com/v0/b/gdfe-ac584.appspot.com/o/bgImagesAR%2Fpexels-jhovani-morales-12319997.jpg?alt=media&token=8fe114f3-8ff9-497f-8bcd-486c38c437d9",
    "https://firebasestorage.googleapis.com/v0/b/gdfe-ac584.appspot.com/o/bgImagesAR%2Fpexels-leandro-verolli-2599136.jpg?alt=media&token=665624d9-08ae-48bd-8208-a410a4168dad",
    "https://firebasestorage.googleapis.com/v0/b/gdfe-ac584.appspot.com/o/bgImagesAR%2Fpexels-pixabay-64271.jpg?alt=media&token=4fc1f128-dbfe-4aca-bb8f-4e5224560684",
    "https://firebasestorage.googleapis.com/v0/b/gdfe-ac584.appspot.com/o/bgImagesAR%2Fpexels-samuel-wo%CC%88lfl-1427578.jpg?alt=media&token=5dbbcf24-0681-4527-9021-df2293b6eb4d",
    "https://firebasestorage.googleapis.com/v0/b/gdfe-ac584.appspot.com/o/bgImagesAR%2Fpexels-shukhrat-umarov-1534411.jpg?alt=media&token=b606d709-3fef-491c-99f8-82f6474226e1",
  ]);
  ValueNotifier<String?> selectedImage = ValueNotifier<String?>(
      "https://firebasestorage.googleapis.com/v0/b/gdfe-ac584.appspot.com/o/bgImagesAR%2Fpexels-aleksandar-pasaric-2385210.jpg?alt=media&token=cefa1d4f-6b9d-494a-8be6-ed6679bd7f33");
  ValueNotifier<bool> showBgImg = ValueNotifier<bool>(false);

  // Function to pick date
  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _startDiscountDate.value,
        firstDate: _startDiscountDate.value,
        lastDate: DateTime(2025));
    if (picked != null && picked != _endDiscountDate.value) {
      _endDiscountDate.value = picked;
    }
  }

  // Function to pick date
  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(2025));
    if (picked != null && picked != _startDiscountDate.value)
      _startDiscountDate.value = picked;
    _endDiscountDate.value = picked!;
  }

  List<String?> _selectedRecommendedOptions = [];

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
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final FirebaseOperations firebaseOperations =
        Provider.of<FirebaseOperations>(context, listen: false);
    final Authentication auth =
        Provider.of<Authentication>(context, listen: false);
    return Scaffold(
      backgroundColor: constantColors.whiteColor,
      appBar: AppBarWidget(
        text: "AR Preview Settings",
        context: context,
        goBack: true,
      ),
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
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 10),
                    child: Column(
                      children: [
                        Container(
                          color: constantColors.navButton,
                          height: 35,
                          child: Row(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text(
                                  "Set GD AR usage as",
                                  style: TextStyle(
                                    color: constantColors.whiteColor,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: ToggleSwitch(
                            minWidth: size.width * 0.5,
                            totalSwitches: 2,
                            activeBgColor: [
                              constantColors.navButton,
                              constantColors.navButton,
                            ],
                            labels: ['Material', 'AR View Only'],
                            animate: true,
                            onToggle: (index) {
                              if (index == 0) {
                                _arAs.value = "Material";
                              } else if (index == 1) {
                                _arAs.value = "AR View Only";
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedBuilder(
                      animation:
                          Listenable.merge([_arAs, selectedImage, showBgImg]),
                      builder: (context, _) {
                        switch (_arAs.value) {
                          case "Material":
                            return Column(
                              children: [
                                Text(
                                  "Material GD AR's are only for the Video Editor",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: constantColors.black,
                                  ),
                                ),
                                NewDivider(constantColors: constantColors),
                                Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: Container(
                                          decoration: BoxDecoration(
                                            image: showBgImg.value == true
                                                ? DecorationImage(
                                                    fit: BoxFit.cover,
                                                    image: Image.network(
                                                      selectedImage.value!,
                                                    ).image)
                                                : null,
                                          ),
                                          height: size.height * 0.5,
                                          child: Image.network(
                                            gifUrl,
                                            fit: BoxFit.cover,
                                          )),
                                    ),
                                    Visibility(
                                      visible: showBgImg.value == true,
                                      child: Positioned(
                                        top: 10,
                                        right: 10,
                                        child: Container(
                                          height: 40,
                                          width: 40,
                                          decoration: BoxDecoration(
                                            color: constantColors.black
                                                .withOpacity(0.6),
                                            borderRadius:
                                                BorderRadius.circular(40),
                                          ),
                                          child: IconButton(
                                            onPressed: () {
                                              selectedImage.value = bgImage
                                                      .value[
                                                  Random().nextInt(
                                                      bgImage.value.length)];
                                            },
                                            icon: Icon(
                                              Icons.refresh,
                                              color: constantColors.whiteColor,
                                              size: 20,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 10,
                                      left: 10,
                                      child: Container(
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: constantColors.black
                                              .withOpacity(0.6),
                                          borderRadius:
                                              BorderRadius.circular(40),
                                        ),
                                        child: Row(
                                          children: [
                                            Switch(
                                              value: showBgImg.value,
                                              onChanged: (val) {
                                                showBgImg.value = val;
                                              },
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );

                          case "AR View Only":
                            return Column(
                              children: [
                                Text(
                                  "AR View Only can only be used in the AR Viewer to immerse you and the AR in one world!",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: constantColors.black,
                                  ),
                                ),
                                NewDivider(constantColors: constantColors),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Flexible widget with video in it
                                    Flexible(
                                      flex: 1,
                                      child: Stack(
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            child: Container(
                                                decoration: BoxDecoration(
                                                    image: DecorationImage(
                                                        image: Image.asset(
                                                                "assets/arViewer/bg.png")
                                                            .image)),
                                                height: size.height * 0.25,
                                                child: Image.network(
                                                  gifUrl,
                                                  fit: BoxFit.cover,
                                                )),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Flexible(
                                      flex: 2,
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(left: 10),
                                        child: Container(
                                          height: size.height * 0.25,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Container(
                                                child: ProfileUserDetails(
                                                  controller:
                                                      _arTitleController,
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
                                                padding: const EdgeInsets.only(
                                                    top: 10),
                                                child: Container(
                                                  child: ProfileUserDetails(
                                                    lines: 4,
                                                    controller:
                                                        _arCaptionController,
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
                                ),
                              ],
                            );
                        }
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Container(
                      child: ValueListenableBuilder<String>(
                        valueListenable: _arAs,
                        builder: (context, val, _) {
                          switch (val) {
                            case "Material":
                              return SubmitButton(
                                function: () async {
                                  CoolAlert.show(
                                    context: context,
                                    type: CoolAlertType.loading,
                                    text: "Submitting GD AR as Material",
                                  );
                                  await firebaseOperations
                                      .addArToCollection(
                                    ownerName: ownerName,
                                    audioFlag: audioFlag,
                                    alphaUrl: alphaUrl,
                                    audioUrl: audioUrl,
                                    imgSeqList: imgSeqList,
                                    gifUrl: gifUrl,
                                    idVal: arIdVal,
                                    mainUrl: inputUrl,
                                    useruid: auth.getUserId,
                                    usage: "Material",
                                  )
                                      .whenComplete(() async {
                                    Get.snackbar(
                                      'GD AR posted as Material',
                                      "The use of this GD AR is in the vider editor only!",
                                      overlayColor: constantColors.navButton,
                                      colorText: constantColors.whiteColor,
                                      snackPosition: SnackPosition.TOP,
                                      forwardAnimationCurve:
                                          Curves.elasticInOut,
                                      reverseAnimationCurve: Curves.easeOut,
                                    );

                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                  });
                                },
                                text: "Submit as Material",
                              );

                            case "AR View Only":
                              return AnimatedBuilder(
                                  animation: Listenable.merge([
                                    _startDiscountDate,
                                    _endDiscountDate,
                                    _isFree,
                                    _isPaid,
                                    _arPrice,
                                    _contentDiscount
                                  ]),
                                  builder: (context, _) {
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 10),
                                          child: Container(
                                            child:
                                                MultiSelectChipField<String?>(
                                              headerColor:
                                                  constantColors.navButton,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              selectedChipColor: constantColors
                                                  .navButton
                                                  .withOpacity(0.4),
                                              title: Text(
                                                "Select Genre",
                                                style: TextStyle(
                                                  color:
                                                      constantColors.whiteColor,
                                                  fontSize: 15,
                                                ),
                                              ),
                                              items: _recommendedOptions
                                                  .map((e) =>
                                                      MultiSelectItem(e, e!))
                                                  .toList(),
                                              onTap: (values) {
                                                // _recommendedOptions = values;
                                                _selectedRecommendedOptions =
                                                    values;

                                                print(
                                                    "length == ${_selectedRecommendedOptions.length}");
                                              },
                                            ),
                                          ),
                                        ),
                                        ListTile(
                                          leading: Icon(FontAwesomeIcons
                                              .cloudDownloadAlt),
                                          minLeadingWidth: 10,
                                          trailing: Switch(
                                              activeColor:
                                                  constantColors.navButton,
                                              value: _isFree.value,
                                              onChanged: (value) {
                                                _isFree.value = value;
                                                _isPaid.value = !value;
                                              }),
                                          title: Text(
                                            "Free",
                                          ),
                                        ),
                                        ListTile(
                                          leading: Icon(
                                              FontAwesomeIcons.moneyBillAlt),
                                          minLeadingWidth: 10,
                                          trailing: Switch(
                                            activeColor:
                                                constantColors.navButton,
                                            value: _isPaid.value,
                                            onChanged: (value) {
                                              _isPaid.value = value;
                                              _isFree.value = !value;
                                            },
                                          ),
                                          title: Text(
                                            "Premium",
                                          ),
                                        ),
                                        Visibility(
                                          visible: _isPaid.value,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    "Price",
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 40,
                                                  ),
                                                  Expanded(
                                                    child: Container(
                                                      height: 50,
                                                      child: TextFormField(
                                                        controller:
                                                            _arPrice.value,
                                                        onFieldSubmitted:
                                                            (value) {
                                                          _arPrice.value.text =
                                                              value;
                                                        },
                                                        keyboardType:
                                                            TextInputType
                                                                .number,
                                                        decoration:
                                                            InputDecoration(
                                                          suffixIcon: Icon(
                                                            FontAwesomeIcons
                                                                .dollarSign,
                                                            size: 16,
                                                            color:
                                                                constantColors
                                                                    .navButton,
                                                          ),
                                                          labelStyle: TextStyle(
                                                              color:
                                                                  Colors.black),
                                                          border:
                                                              OutlineInputBorder(),
                                                          enabledBorder:
                                                              OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                                    color: Colors
                                                                        .black),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        30),
                                                          ),
                                                          focusedBorder:
                                                              OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                                    color: Colors
                                                                        .black),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        30),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Padding(
                                                padding:
                                                    EdgeInsets.only(top: 10),
                                                // Row widget where the user can set the discount amount
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      "Discount",
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: 10,
                                                    ),
                                                    Expanded(
                                                      child: Container(
                                                        height: 50,
                                                        child: TextFormField(
                                                          controller:
                                                              _contentDiscount
                                                                  .value,
                                                          onFieldSubmitted:
                                                              (value) {
                                                            _contentDiscount
                                                                .value
                                                                .text = value;
                                                          },
                                                          keyboardType:
                                                              TextInputType
                                                                  .number,
                                                          decoration:
                                                              InputDecoration(
                                                            suffixIcon: Icon(
                                                              FontAwesomeIcons
                                                                  .percentage,
                                                              size: 16,
                                                              color:
                                                                  constantColors
                                                                      .navButton,
                                                            ),
                                                            labelStyle:
                                                                TextStyle(
                                                                    color: Colors
                                                                        .black),
                                                            border:
                                                                OutlineInputBorder(),
                                                            enabledBorder:
                                                                OutlineInputBorder(
                                                              borderSide: BorderSide(
                                                                  color: Colors
                                                                      .black),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          30),
                                                            ),
                                                            focusedBorder:
                                                                OutlineInputBorder(
                                                              borderSide: BorderSide(
                                                                  color: Colors
                                                                      .black),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          30),
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
                                                padding: const EdgeInsets.only(
                                                    top: 10),
                                                child: Text(
                                                  "Discount Period",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 10),
                                                child: Container(
                                                  height: 60,
                                                  decoration: BoxDecoration(
                                                    color: constantColors
                                                        .navButton,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                  ),
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    children: [
                                                      TextButton.icon(
                                                        style: TextButton
                                                            .styleFrom(
                                                          primary: Colors.white,
                                                        ),
                                                        onPressed: () =>
                                                            _selectStartDate(
                                                                context),
                                                        icon: Icon(Icons
                                                            .calendar_month),
                                                        label: Text(
                                                          "${DateFormat("E, MMM, d").format(_startDiscountDate.value)}",
                                                        ),
                                                      ),
                                                      Text(
                                                        ">",
                                                        style: TextStyle(
                                                          color: constantColors
                                                              .whiteColor,
                                                          fontSize: 40,
                                                        ),
                                                      ),
                                                      TextButton.icon(
                                                        style: TextButton
                                                            .styleFrom(
                                                          primary: Colors.white,
                                                        ),
                                                        onPressed: () =>
                                                            _selectEndDate(
                                                                context),
                                                        icon: Icon(Icons
                                                            .calendar_month),
                                                        label: Text(
                                                            "${DateFormat("E, MMM, d").format(_endDiscountDate.value)}"),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 30, bottom: 30),
                                          child: SubmitButton(
                                            text: "Submit as AR View Only",
                                            function: () async {
                                              if (_formKey.currentState!
                                                      .validate() &&
                                                  _selectedRecommendedOptions
                                                          .length >
                                                      0) {
                                                // *First use FFmpeg to make it a video
                                                try {
                                                  // // ignore: unawaited_futures
                                                  CoolAlert.show(
                                                      barrierDismissible: false,
                                                      context: context,
                                                      type:
                                                          CoolAlertType.loading,
                                                      text:
                                                          "Submitting GD AR as View Only");

                                                  // await Provider.of<
                                                  //             FFmpegProvider>(
                                                  //         context,
                                                  //         listen: false)
                                                  //     .arViewOnlyVideoCreator(
                                                  //   audioFlagVal: audioFlag,
                                                  //   alphaFileUrl: alphaUrl,
                                                  //   videoFileUrl: inputUrl,
                                                  //   duration: endDuration,
                                                  // )
                                                  //     .then((videoFile) async {
                                                  // });

                                                  final ArViewOnlyModel?
                                                      arViewOnlyServerResponse =
                                                      await Provider.of<
                                                                  FirebaseOperations>(
                                                              context,
                                                              listen: false)
                                                          .postArViewOnlyServer(
                                                              videoDuration:
                                                                  endDuration
                                                                      .toString(),
                                                              audioFlag:
                                                                  audioFlag,
                                                              fileStarting:
                                                                  arIdVal);

                                                  if (arViewOnlyServerResponse !=
                                                      null) {
                                                    final String _inputFileUrl =
                                                        "https://anketvideobucket.s3.amazonaws.com/LZF1TxU9TabQ3hhbUXZH6uC22dH3/${arViewOnlyServerResponse.ARwithGDbackcover}";

                                                    dev.log(
                                                        "video File == ${_inputFileUrl}");

                                                    Navigator.pop(context);

                                                    await firebaseOperations
                                                        .uploadArVideoViewOnly(
                                                      alphaUrl: alphaUrl,
                                                      arIdVal: arIdVal,
                                                      audioFlag: audioFlag,
                                                      audioUrl: audioUrl,
                                                      caption:
                                                          _arCaptionController
                                                              .text,
                                                      contentAvailability:
                                                          "All",
                                                      ctx: context,
                                                      genre:
                                                          _selectedRecommendedOptions,
                                                      gifUrl: gifUrl,
                                                      imgSeqList: imgSeqList,
                                                      inputUrl: inputUrl,
                                                      isFree: _isFree.value,
                                                      isPaid: _isPaid.value,
                                                      isSubscription: false,
                                                      ownerName: ownerName,
                                                      userUid: auth.getUserId,
                                                      videoUrl: _inputFileUrl,
                                                      video_title:
                                                          _arTitleController
                                                              .text,
                                                      discountAmount:
                                                          _contentDiscount.value
                                                                  .text.isEmpty
                                                              ? 0
                                                              : double.parse(
                                                                  _contentDiscount
                                                                      .value
                                                                      .text),
                                                      endDiscountDate:
                                                          Timestamp.fromDate(
                                                              _endDiscountDate
                                                                  .value),
                                                      startDiscountDate:
                                                          Timestamp.fromDate(
                                                              _startDiscountDate
                                                                  .value),
                                                      price: _arPrice.value.text
                                                              .isEmpty
                                                          ? 0
                                                          : double.parse(
                                                              _arPrice
                                                                  .value.text),
                                                    );
                                                  } else {
                                                    Navigator.pop(context);
                                                    CoolAlert.show(
                                                      context: context,
                                                      type: CoolAlertType.error,
                                                      title:
                                                          "Error Uploading Video",
                                                      text:
                                                          "Error running Ar View Only Response",
                                                    );
                                                  }
                                                } catch (e) {
                                                  dev.log(
                                                      "Anket issue == ${e.toString()}");
                                                  Navigator.pop(context);
                                                  CoolAlert.show(
                                                    context: context,
                                                    type: CoolAlertType.error,
                                                    title:
                                                        "Error Uploading Video",
                                                    text: e.toString(),
                                                  );
                                                }
                                              } else if (_selectedRecommendedOptions
                                                      .length ==
                                                  0) {
                                                CoolAlert.show(
                                                  context: context,
                                                  type: CoolAlertType.error,
                                                  title: "No Selected Genre",
                                                  text:
                                                      "Please Select a Genre for your video",
                                                );
                                              }

                                              // }
                                              // await firebaseOperations
                                              //     .addArToCollection(
                                              //   ownerName: ownerName,
                                              //   audioFlag: audioFlag,
                                              //   alphaUrl: alphaUrl,
                                              //   audioUrl: audioUrl,
                                              //   imgSeqList: imgSeqList,
                                              //   gifUrl: gifUrl,
                                              //   idVal: arIdVal,
                                              //   mainUrl: inputUrl,
                                              //   useruid: auth.getUserId,
                                              //   usage: "Ar View Only",
                                              // )
                                              //     .whenComplete(() async {
                                              //   Navigator.pop(context);
                                              // });
                                            },
                                          ),
                                        ),
                                      ],
                                    );
                                  });
                          }
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
