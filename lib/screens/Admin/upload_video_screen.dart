// ignore_for_file: prefer_const_constructors

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:diamon_rose_app/services/FirebaseOperations.dart';
import 'package:diamon_rose_app/services/aws/aws_upload_service.dart';
import 'package:diamon_rose_app/services/myArCollectionClass.dart';
import 'package:diamon_rose_app/services/user.dart';
import 'package:diamon_rose_app/translations/locale_keys.g.dart';
import 'package:diamon_rose_app/widgets/global.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart' hide Trans;
import 'package:image_picker/image_picker.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:nanoid/nanoid.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'package:universal_io/io.dart';

class UploadVideoScreen extends StatefulWidget {
  UploadVideoScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<UploadVideoScreen> createState() => _UploadVideoScreenState();
}

class _UploadVideoScreenState extends State<UploadVideoScreen>
    with TickerProviderStateMixin {
  final ValueNotifier<UserModel?> selectedUser =
      ValueNotifier<UserModel?>(null);
  File? mainVideo;
  File? alphaVideo;
  final ImagePicker _picker = ImagePicker();
  ValueNotifier<bool> _asMaterialAlso = ValueNotifier<bool>(false);

  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(
      initialIndex: 0,
      length: 2,
      vsync: this,
    );
  }

  final String fileName = Timestamp.now().millisecondsSinceEpoch.toString();

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
  List<String?> _selectedRecommendedOptions = [];

  ValueNotifier<int> responseResult = ValueNotifier<int>(0);

  List<String?> _recommendedOptions = [
    LocaleKeys.musician.tr(),
    LocaleKeys.performers.tr(),
    LocaleKeys.dance.tr(),
    LocaleKeys.cosplayers.tr(),
    LocaleKeys.movie.tr(),
    LocaleKeys.actor.tr(),
    LocaleKeys.fashion.tr(),
    LocaleKeys.landscape.tr(),
    LocaleKeys.sports.tr(),
    LocaleKeys.animals.tr(),
    LocaleKeys.space.tr(),
    LocaleKeys.art.tr(),
    LocaleKeys.mystery.tr(),
    LocaleKeys.airplane.tr(),
    LocaleKeys.games.tr(),
    LocaleKeys.food.tr(),
    LocaleKeys.romance.tr(),
    LocaleKeys.sexy.tr(),
    LocaleKeys.sciencefiction.tr(),
    LocaleKeys.car.tr(),
    LocaleKeys.jobs.tr(),
    LocaleKeys.anime.tr(),
    LocaleKeys.ship.tr(),
    LocaleKeys.railroads.tr(),
    LocaleKeys.building.tr(),
    LocaleKeys.health.tr(),
    LocaleKeys.science.tr(),
    LocaleKeys.natural.tr(),
    LocaleKeys.machine.tr(),
    LocaleKeys.trip.tr(),
    LocaleKeys.travel.tr(),
    LocaleKeys.fantasy.tr(),
    LocaleKeys.funny.tr(),
    LocaleKeys.beauty.tr(),
  ];

  _pickVideo({required BuildContext context, String type = "main"}) async {
    FilePickerResult? file = await FilePicker.platform.pickFiles(
      type: FileType.video,
    );
    if (file != null) {
      switch (type) {
        case "main":
          setState(() {
            mainVideo = File(file.files.single.path!);
          });
          break;
        case "alpha":
          setState(() {
            alphaVideo = File(file.files.single.path!);
          });
          break;
      }
      // ignore: unawaited_futures

    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final FirebaseOperations firebaseOperations =
        Provider.of<FirebaseOperations>(context, listen: false);
    return Scaffold(
      backgroundColor: constantColors.bioBg,
      appBar: AppBarWidget(text: "Upload Video", context: context),
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
                _startDiscountDate,
                _endDiscountDate,
                _isFree,
                _isPaid,
                _arPrice,
                _contentDiscount,
                _asMaterialAlso,
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
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          children: [
                                            ElevatedButton(
                                              style: ButtonStyle(
                                                foregroundColor:
                                                    MaterialStateProperty.all<
                                                        Color>(Colors.white),
                                                backgroundColor:
                                                    MaterialStateProperty.all<
                                                            Color>(
                                                        constantColors
                                                            .navButton),
                                                shape:
                                                    MaterialStateProperty.all<
                                                        RoundedRectangleBorder>(
                                                  RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                  ),
                                                ),
                                              ),
                                              onPressed: () => _pickVideo(
                                                  context: context,
                                                  type: "main"),
                                              child: Text(
                                                "Upload Main Video",
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                            if (mainVideo != null)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 10),
                                                child: Icon(
                                                  Icons.check_box_outlined,
                                                  color:
                                                      constantColors.greenColor,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(
                                        child: Column(
                                          children: [
                                            ElevatedButton(
                                              style: ButtonStyle(
                                                foregroundColor:
                                                    MaterialStateProperty.all<
                                                        Color>(Colors.white),
                                                backgroundColor:
                                                    MaterialStateProperty.all<
                                                            Color>(
                                                        constantColors
                                                            .navButton),
                                                shape:
                                                    MaterialStateProperty.all<
                                                        RoundedRectangleBorder>(
                                                  RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                  ),
                                                ),
                                              ),
                                              onPressed: () => _pickVideo(
                                                  context: context,
                                                  type: "alpha"),
                                              child: Text(
                                                "Upload Alpha Video",
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                            if (alphaVideo != null)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 10),
                                                child: Icon(
                                                  Icons.check_box_outlined,
                                                  color:
                                                      constantColors.greenColor,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    height: 5.h,
                                    width: 400,
                                    child: TabBar(
                                      labelColor: Color.fromRGBO(4, 2, 46, 1),
                                      indicatorColor:
                                          Color.fromRGBO(4, 2, 46, 1),
                                      unselectedLabelColor: Colors.grey,
                                      controller: tabController,
                                      tabs: [
                                        Text('GD AR Material'),
                                        Text('AR View Only'),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    height: 100.h,
                                    width: 100.w,
                                    child: TabBarView(
                                      controller: tabController,
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 10),
                                          child: Column(
                                            children: [
                                              AnimatedBuilder(
                                                  animation: Listenable.merge([
                                                    responseResult,
                                                  ]),
                                                  builder: (context, _) {
                                                    switch (
                                                        responseResult.value) {
                                                      case 0:
                                                        return Column(
                                                          children: [
                                                            Container(
                                                              height: 40.h,
                                                              width: 80.w,
                                                              decoration:
                                                                  BoxDecoration(
                                                                image:
                                                                    DecorationImage(
                                                                  image: Image.asset(
                                                                          "assets/arViewer/bg.png")
                                                                      .image,
                                                                  fit: BoxFit
                                                                      .cover,
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: 20,
                                                            ),
                                                            SubmitButton(
                                                              text:
                                                                  "Submit as Materials",
                                                              function:
                                                                  () async {
                                                                CoolAlert.show(
                                                                    barrierDismissible:
                                                                        false,
                                                                    context:
                                                                        context,
                                                                    type: CoolAlertType
                                                                        .loading,
                                                                    text:
                                                                        "Uploading videos and submitting details to server");

                                                                log("fileName == $fileName");
                                                                final String? mainVideoUrl = await AwsAnketS3.uploadFile(
                                                                    accessKey:
                                                                        "AKIATF76MVYR34JAVB7H",
                                                                    secretKey:
                                                                        "qNosurynLH/WHV4iYu8vYWtSxkKqBFav0qbXEvdd",
                                                                    bucket:
                                                                        "anketvideobucket",
                                                                    file:
                                                                        mainVideo!,
                                                                    filename:
                                                                        "${fileName}videoFile.mp4",
                                                                    region:
                                                                        "us-east-1",
                                                                    destDir:
                                                                        "$fileName");

                                                                final String? alphaVideoUrl = await AwsAnketS3.uploadFile(
                                                                    accessKey:
                                                                        "AKIATF76MVYR34JAVB7H",
                                                                    secretKey:
                                                                        "qNosurynLH/WHV4iYu8vYWtSxkKqBFav0qbXEvdd",
                                                                    bucket:
                                                                        "anketvideobucket",
                                                                    file:
                                                                        alphaVideo!,
                                                                    filename:
                                                                        "${fileName}_alpha.mp4",
                                                                    region:
                                                                        "us-east-1",
                                                                    destDir:
                                                                        "$fileName");

                                                                log("mainurl == $mainVideoUrl || alpha url = $alphaVideoUrl");

                                                                responseResult
                                                                        .value =
                                                                    await context
                                                                        .read<
                                                                            FirebaseOperations>()
                                                                        .postMaterialOnlyServer(
                                                                          mainUrl:
                                                                              mainVideoUrl!,
                                                                          alphaUrl:
                                                                              alphaVideoUrl!,
                                                                          fileName:
                                                                              fileName,
                                                                          useruidVal: selectedUser
                                                                              .value!
                                                                              .useruid,
                                                                          ownerNameVal: selectedUser
                                                                              .value!
                                                                              .username,
                                                                        );

                                                                log("response == ${responseResult.value}");
                                                                Get.back();
                                                              },
                                                              color:
                                                                  constantColors
                                                                      .black,
                                                            ),
                                                          ],
                                                        );
                                                      case 200:
                                                        return Column(
                                                          children: [
                                                            FutureBuilder<
                                                                    DocumentSnapshot>(
                                                                future: FirebaseFirestore
                                                                    .instance
                                                                    .collection(
                                                                        "users")
                                                                    .doc(selectedUser
                                                                        .value!
                                                                        .useruid)
                                                                    .collection(
                                                                        "MyCollection")
                                                                    .doc(
                                                                        fileName)
                                                                    .get(),
                                                                builder: (context,
                                                                    snapshot) {
                                                                  if (snapshot
                                                                          .connectionState ==
                                                                      ConnectionState
                                                                          .waiting) {
                                                                    return Center(
                                                                      child:
                                                                          CircularProgressIndicator(),
                                                                    );
                                                                  }

                                                                  if (snapshot
                                                                      .hasError) {
                                                                    return Center(
                                                                      child: Text(
                                                                          "Error"),
                                                                    );
                                                                  }

                                                                  MyArCollection
                                                                      myAr =
                                                                      MyArCollection.fromJson(snapshot
                                                                              .data!
                                                                              .data()
                                                                          as Map<
                                                                              String,
                                                                              dynamic>);

                                                                  return Container(
                                                                      height:
                                                                          40.h,
                                                                      width:
                                                                          80.w,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        image:
                                                                            DecorationImage(
                                                                          image:
                                                                              Image.asset("assets/arViewer/bg.png").image,
                                                                          fit: BoxFit
                                                                              .cover,
                                                                        ),
                                                                      ),
                                                                      child: ImageNetworkLoader(
                                                                          imageUrl:
                                                                              myAr.gif));
                                                                }),
                                                            SizedBox(
                                                              height: 20,
                                                            ),
                                                            Row(
                                                              children: [
                                                                Expanded(
                                                                  child:
                                                                      SubmitButton(
                                                                    text:
                                                                        "Reject",
                                                                    color: Colors
                                                                        .red,
                                                                    function:
                                                                        () async {
                                                                      await FirebaseFirestore
                                                                          .instance
                                                                          .collection(
                                                                              "users")
                                                                          .doc(selectedUser
                                                                              .value!
                                                                              .useruid)
                                                                          .collection(
                                                                              "MyCollection")
                                                                          .doc(
                                                                              fileName)
                                                                          .delete();
                                                                    },
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  width: 10,
                                                                ),
                                                                Expanded(
                                                                  child:
                                                                      SubmitButton(
                                                                    text:
                                                                        "Approve",
                                                                    color: Colors
                                                                        .green,
                                                                    function:
                                                                        () {
                                                                      Navigator.pop(
                                                                          context);
                                                                    },
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        );

                                                      case 500:
                                                        return Center(
                                                          child: Text(
                                                              "Server Error 500"),
                                                        );
                                                    }
                                                    return SizedBox();
                                                  })
                                            ],
                                          ),
                                        ),
                                        Container(
                                          child: Column(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 15),
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
                                                            return LocaleKeys
                                                                .pleaseenteratitle
                                                                .tr();
                                                          }
                                                          return null;
                                                        },
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 10),
                                                      child: Container(
                                                        child:
                                                            ProfileUserDetails(
                                                          lines: 4,
                                                          controller:
                                                              _arCaptionController,
                                                          labelText: "Caption",
                                                          onSubmit: (val) {},
                                                          validator: (val) {
                                                            if (val!.isEmpty) {
                                                              return LocaleKeys
                                                                  .pleaseenteracaption
                                                                  .tr();
                                                            }
                                                            return null;
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 10),
                                                    child: Container(
                                                      child:
                                                          MultiSelectChipField<
                                                              String?>(
                                                        headerColor:
                                                            constantColors
                                                                .navButton,
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(20),
                                                        ),
                                                        selectedChipColor:
                                                            constantColors
                                                                .navButton
                                                                .withOpacity(
                                                                    0.4),
                                                        title: Text(
                                                          "Select Genre",
                                                          style: TextStyle(
                                                            color:
                                                                constantColors
                                                                    .whiteColor,
                                                            fontSize: 15,
                                                          ),
                                                        ),
                                                        items: _recommendedOptions
                                                            .map((e) =>
                                                                MultiSelectItem(
                                                                    e, e!))
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
                                                    leading: Icon(
                                                        FontAwesomeIcons.video),
                                                    minLeadingWidth: 10,
                                                    trailing: Switch(
                                                        activeColor:
                                                            constantColors
                                                                .navButton,
                                                        value: _asMaterialAlso
                                                            .value,
                                                        onChanged: (value) {
                                                          _asMaterialAlso
                                                              .value = value;
                                                        }),
                                                    title: Text(
                                                      "Allow usage as Material",
                                                    ),
                                                  ),
                                                  ListTile(
                                                    leading: Icon(
                                                        FontAwesomeIcons
                                                            .cloudDownloadAlt),
                                                    minLeadingWidth: 10,
                                                    trailing: Switch(
                                                        activeColor:
                                                            constantColors
                                                                .navButton,
                                                        value: _isFree.value,
                                                        onChanged: (value) {
                                                          _isFree.value = value;
                                                          _isPaid.value =
                                                              !value;
                                                        }),
                                                    title: Text(
                                                      "Free",
                                                    ),
                                                  ),
                                                  ListTile(
                                                    leading: Icon(
                                                        FontAwesomeIcons
                                                            .moneyBillAlt),
                                                    minLeadingWidth: 10,
                                                    trailing: Switch(
                                                      activeColor:
                                                          constantColors
                                                              .navButton,
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
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Text(
                                                              "Price",
                                                              style: TextStyle(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width: 40,
                                                            ),
                                                            Expanded(
                                                              child: Container(
                                                                height: 50,
                                                                child:
                                                                    TextFormField(
                                                                  controller:
                                                                      _arPrice
                                                                          .value,
                                                                  onFieldSubmitted:
                                                                      (value) {
                                                                    _arPrice.value
                                                                            .text =
                                                                        value;
                                                                  },
                                                                  keyboardType:
                                                                      TextInputType
                                                                          .number,
                                                                  decoration:
                                                                      InputDecoration(
                                                                    suffixIcon:
                                                                        Icon(
                                                                      FontAwesomeIcons
                                                                          .dollarSign,
                                                                      size: 16,
                                                                      color: constantColors
                                                                          .navButton,
                                                                    ),
                                                                    labelStyle:
                                                                        TextStyle(
                                                                            color:
                                                                                Colors.black),
                                                                    border:
                                                                        OutlineInputBorder(),
                                                                    enabledBorder:
                                                                        OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                              color: Colors.black),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              30),
                                                                    ),
                                                                    focusedBorder:
                                                                        OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                              color: Colors.black),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              30),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 30,
                                                            bottom: 30),
                                                    child: SubmitButton(
                                                      text: "Upload Video",
                                                      function: () async {
                                                        if (_formKey
                                                                .currentState!
                                                                .validate() &&
                                                            mainVideo != null &&
                                                            alphaVideo !=
                                                                null) {
                                                          try {
                                                            // ignore: unawaited_futures
                                                            CoolAlert.show(
                                                                context:
                                                                    context,
                                                                type:
                                                                    CoolAlertType
                                                                        .loading,
                                                                text:
                                                                    "Uploading videos and submitting details to server");
                                                            final String
                                                                fileName =
                                                                Timestamp.now()
                                                                    .millisecondsSinceEpoch
                                                                    .toString();

                                                            log("fileName == $fileName");
                                                            final String? mainVideoUrl = await AwsAnketS3.uploadFile(
                                                                accessKey:
                                                                    "AKIATF76MVYR34JAVB7H",
                                                                secretKey:
                                                                    "qNosurynLH/WHV4iYu8vYWtSxkKqBFav0qbXEvdd",
                                                                bucket:
                                                                    "anketvideobucket",
                                                                file:
                                                                    mainVideo!,
                                                                filename:
                                                                    "${fileName}videoFile.mp4",
                                                                region:
                                                                    "us-east-1",
                                                                destDir:
                                                                    "$fileName");

                                                            final String? alphaVideoUrl = await AwsAnketS3.uploadFile(
                                                                accessKey:
                                                                    "AKIATF76MVYR34JAVB7H",
                                                                secretKey:
                                                                    "qNosurynLH/WHV4iYu8vYWtSxkKqBFav0qbXEvdd",
                                                                bucket:
                                                                    "anketvideobucket",
                                                                file:
                                                                    alphaVideo!,
                                                                filename:
                                                                    "${fileName}_alpha.mp4",
                                                                region:
                                                                    "us-east-1",
                                                                destDir:
                                                                    "$fileName");

                                                            log("mainurl == $mainVideoUrl || alpha url = $alphaVideoUrl");

                                                            String name =
                                                                "${_arCaptionController.text} ${_arTitleController.text}";

                                                            List<String>
                                                                splitList =
                                                                name.split(" ");
                                                            List<String>
                                                                indexList = [];

                                                            for (int i = 0;
                                                                i <
                                                                    splitList
                                                                        .length;
                                                                i++) {
                                                              for (int j = 0;
                                                                  j <
                                                                      splitList[
                                                                              i]
                                                                          .length;
                                                                  j++) {
                                                                indexList.add(splitList[
                                                                        i]
                                                                    .substring(
                                                                        0,
                                                                        j + 1)
                                                                    .toLowerCase());
                                                              }
                                                            }

                                                            final String
                                                                videoId =
                                                                nanoid();

                                                            final int response =
                                                                await firebaseOperations
                                                                    .uploadDataForUser(
                                                              mainUrl:
                                                                  mainVideoUrl!,
                                                              alphaUrl:
                                                                  alphaVideoUrl!,
                                                              fileName:
                                                                  fileName,
                                                              useruid:
                                                                  selectedUser
                                                                      .value!
                                                                      .useruid,
                                                              ownerName:
                                                                  selectedUser
                                                                      .value!
                                                                      .username,
                                                              isVerified:
                                                                  selectedUser
                                                                      .value!
                                                                      .isverified!,
                                                              price: _arPrice
                                                                      .value
                                                                      .text
                                                                      .isEmpty
                                                                  ? 0
                                                                  : double.parse(
                                                                      _arPrice
                                                                          .value
                                                                          .text),
                                                              genre:
                                                                  _selectedRecommendedOptions,
                                                              isFree:
                                                                  _isFree.value,
                                                              isPaid:
                                                                  _isPaid.value,
                                                              userimageUrl:
                                                                  selectedUser
                                                                      .value!
                                                                      .userimage,
                                                              searchindexList:
                                                                  indexList,
                                                              caption:
                                                                  _arCaptionController
                                                                      .text,
                                                              fcmToken:
                                                                  selectedUser
                                                                      .value!
                                                                      .token,
                                                              registrationId:
                                                                  selectedUser
                                                                      .value!
                                                                      .token,
                                                              title:
                                                                  _arTitleController
                                                                      .text,
                                                              videoId: videoId,
                                                              startDiscountDate:
                                                                  DateTime.now()
                                                                      .toString(),
                                                              endDiscountDate:
                                                                  DateTime.now()
                                                                      .toString(),
                                                            );

                                                            switch (response) {
                                                              case 200:

                                                                // Navigator.pop(context);
                                                                if (_asMaterialAlso
                                                                        .value ==
                                                                    true) {
                                                                  await FirebaseFirestore
                                                                      .instance
                                                                      .collection(
                                                                          "users")
                                                                      .doc(selectedUser
                                                                          .value!
                                                                          .useruid)
                                                                      .collection(
                                                                          "MyCollection")
                                                                      .doc(
                                                                          fileName)
                                                                      .get()
                                                                      .then(
                                                                          (arSnapshot) async {
                                                                    Map<String,
                                                                            dynamic>
                                                                        submitAsMaterial =
                                                                        {
                                                                      "alpha":
                                                                          arSnapshot[
                                                                              'alpha'],
                                                                      "main": arSnapshot[
                                                                          'main'],
                                                                      "audioFile":
                                                                          arSnapshot[
                                                                              'audioFile'],
                                                                      "gif": arSnapshot[
                                                                          'gif'],
                                                                      "layerType":
                                                                          "AR",
                                                                      "valueType":
                                                                          "myItems",
                                                                      "timestamp":
                                                                          Timestamp
                                                                              .now(),
                                                                      "id":
                                                                          "${fileName}asMaterialAlso",
                                                                      "imgSeq":
                                                                          arSnapshot[
                                                                              'imgSeq'],
                                                                      "audioFlag":
                                                                          arSnapshot[
                                                                              'audioFlag'],
                                                                      "ownerId":
                                                                          arSnapshot[
                                                                              'ownerId'],
                                                                      "ownerName":
                                                                          arSnapshot[
                                                                              'ownerName'],
                                                                      "usage":
                                                                          "Material",
                                                                      "hideItem":
                                                                          false,
                                                                    };

                                                                    await FirebaseFirestore
                                                                        .instance
                                                                        .collection(
                                                                            "users")
                                                                        .doc(selectedUser
                                                                            .value!
                                                                            .useruid)
                                                                        .collection(
                                                                            "MyCollection")
                                                                        .doc(
                                                                            "${fileName}asMaterialAlso")
                                                                        .set(
                                                                            submitAsMaterial);
                                                                  });
                                                                }

                                                                await FirebaseFirestore
                                                                    .instance
                                                                    .collection(
                                                                        "posts")
                                                                    .doc(
                                                                        videoId)
                                                                    .update({
                                                                  "videotitle":
                                                                      _arTitleController
                                                                          .text,
                                                                  "caption":
                                                                      _arCaptionController
                                                                          .text,
                                                                });
                                                                log("done uploading to videoid = $videoId and AR fileName = $fileName ");
                                                                Navigator.pop(
                                                                    context);

                                                                break;
                                                              case 500:
                                                                Get.back();
                                                                CoolAlert.show(
                                                                    context:
                                                                        context,
                                                                    type: CoolAlertType
                                                                        .error,
                                                                    title:
                                                                        "ERROR 500",
                                                                    text:
                                                                        "Video Processing Error");
                                                                break;
                                                              case 406:
                                                                Get.back();
                                                                CoolAlert.show(
                                                                    context:
                                                                        context,
                                                                    type: CoolAlertType
                                                                        .error,
                                                                    title:
                                                                        "ERROR 406",
                                                                    text:
                                                                        "Title / Caption Invalid Characters!");
                                                                break;
                                                            }

                                                            log("Results\nmainUrl: $mainVideoUrl\nalphaUrl: $alphaVideoUrl\nfileName: $fileName\nUseruid: ${selectedUser.value!.useruid}\ntitle: ${_arTitleController.text}\ncaption: ${_arCaptionController.text}\ngenre: $_selectedRecommendedOptions\nisFree: ${_isFree.value}\nisPaid: ${_isPaid.value}\nPrice: ${_arPrice.value.text}");
                                                          } catch (e) {
                                                            Navigator.pop(
                                                                context);
                                                            // ignore: unawaited_futures
                                                            CoolAlert.show(
                                                                context:
                                                                    context,
                                                                type:
                                                                    CoolAlertType
                                                                        .error,
                                                                title:
                                                                    "Something went wrong",
                                                                text: e
                                                                    .toString());
                                                          }
                                                        }

                                                        if (mainVideo == null) {
                                                          CoolAlert.show(
                                                              context: context,
                                                              type:
                                                                  CoolAlertType
                                                                      .error,
                                                              title:
                                                                  "Main video not selected",
                                                              text:
                                                                  "Need to select main video");
                                                        }
                                                        if (alphaVideo ==
                                                            null) {
                                                          CoolAlert.show(
                                                              context: context,
                                                              type:
                                                                  CoolAlertType
                                                                      .error,
                                                              title:
                                                                  "Alpha video not selected",
                                                              text:
                                                                  "Need to select alpha video");
                                                        }
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
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
