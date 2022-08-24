// ignore_for_file: prefer_const_constructors

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:diamon_rose_app/services/FirebaseOperations.dart';
import 'package:diamon_rose_app/services/aws/aws_upload_service.dart';
import 'package:diamon_rose_app/services/user.dart';
import 'package:diamon_rose_app/widgets/global.dart';
import 'package:dropdown_search/dropdown_search.dart';
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

class UploadVideoScreen extends StatefulWidget {
  UploadVideoScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<UploadVideoScreen> createState() => _UploadVideoScreenState();
}

class _UploadVideoScreenState extends State<UploadVideoScreen> {
  final ValueNotifier<UserModel?> selectedUser =
      ValueNotifier<UserModel?>(null);
  File? mainVideo;
  File? alphaVideo;
  final ImagePicker _picker = ImagePicker();

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
                _contentDiscount
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
                                  Padding(
                                    padding: const EdgeInsets.only(top: 15),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Container(
                                          child: ProfileUserDetails(
                                            controller: _arTitleController,
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
                                          padding:
                                              const EdgeInsets.only(top: 10),
                                          child: Container(
                                            child: ProfileUserDetails(
                                              lines: 4,
                                              controller: _arCaptionController,
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
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(top: 10),
                                        child: Container(
                                          child: MultiSelectChipField<String?>(
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
                                        leading: Icon(
                                            FontAwesomeIcons.cloudDownloadAlt),
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
                                        leading:
                                            Icon(FontAwesomeIcons.moneyBillAlt),
                                        minLeadingWidth: 10,
                                        trailing: Switch(
                                          activeColor: constantColors.navButton,
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
                                                      controller:
                                                          _arPrice.value,
                                                      onFieldSubmitted:
                                                          (value) {
                                                        _arPrice.value.text =
                                                            value;
                                                      },
                                                      keyboardType:
                                                          TextInputType.number,
                                                      decoration:
                                                          InputDecoration(
                                                        suffixIcon: Icon(
                                                          FontAwesomeIcons
                                                              .dollarSign,
                                                          size: 16,
                                                          color: constantColors
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
                                                                  .circular(30),
                                                        ),
                                                        focusedBorder:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                                  color: Colors
                                                                      .black),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(30),
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
                                        padding: const EdgeInsets.only(
                                            top: 30, bottom: 30),
                                        child: SubmitButton(
                                          text: "Upload Video",
                                          function: () async {
                                            if (_formKey.currentState!
                                                    .validate() &&
                                                mainVideo != null &&
                                                alphaVideo != null) {
                                              try {
                                                // ignore: unawaited_futures
                                                CoolAlert.show(
                                                    context: context,
                                                    type: CoolAlertType.loading,
                                                    text:
                                                        "Uploading videos and submitting details to server");
                                                final String fileName =
                                                    Timestamp.now()
                                                        .millisecondsSinceEpoch
                                                        .toString();
                                                final String? mainVideoUrl =
                                                    await AwsAnketS3.uploadFile(
                                                        accessKey:
                                                            "AKIATF76MVYR3K3W62OX",
                                                        secretKey:
                                                            "st6hCmrpkk1E3ST23szLx6nofF9dXaQXtGrw0WaL",
                                                        bucket:
                                                            "anketvideobucket",
                                                        file: mainVideo!,
                                                        filename:
                                                            "${fileName}videoFile.mp4",
                                                        region: "us-east-1",
                                                        destDir:
                                                            "LZF1TxU9TabQ3hhbUXZH6uC22dH3");

                                                final String? alphaVideoUrl =
                                                    await AwsAnketS3.uploadFile(
                                                        accessKey:
                                                            "AKIATF76MVYR3K3W62OX",
                                                        secretKey:
                                                            "st6hCmrpkk1E3ST23szLx6nofF9dXaQXtGrw0WaL",
                                                        bucket:
                                                            "anketvideobucket",
                                                        file: alphaVideo!,
                                                        filename:
                                                            "${fileName}_alpha.mp4",
                                                        region: "us-east-1",
                                                        destDir:
                                                            "LZF1TxU9TabQ3hhbUXZH6uC22dH3");

                                                String name =
                                                    "${_arCaptionController.text} ${_arTitleController.text}";

                                                List<String> splitList =
                                                    name.split(" ");
                                                List<String> indexList = [];

                                                for (int i = 0;
                                                    i < splitList.length;
                                                    i++) {
                                                  for (int j = 0;
                                                      j < splitList[i].length;
                                                      j++) {
                                                    indexList.add(splitList[i]
                                                        .substring(0, j + 1)
                                                        .toLowerCase());
                                                  }
                                                }

                                                final String videoId = nanoid();

                                                final int response =
                                                    await firebaseOperations
                                                        .uploadDataForUser(
                                                  mainUrl: mainVideoUrl!,
                                                  alphaUrl: alphaVideoUrl!,
                                                  fileName: fileName,
                                                  useruid: selectedUser
                                                      .value!.useruid,
                                                  ownerName: selectedUser
                                                      .value!.username,
                                                  isVerified: selectedUser
                                                      .value!.isverified!,
                                                  price: _arPrice
                                                          .value.text.isEmpty
                                                      ? 0
                                                      : double.parse(
                                                          _arPrice.value.text),
                                                  genre:
                                                      _selectedRecommendedOptions,
                                                  isFree: _isFree.value,
                                                  isPaid: _isPaid.value,
                                                  userimageUrl: selectedUser
                                                      .value!.userimage,
                                                  searchindexList: indexList,
                                                  caption:
                                                      _arCaptionController.text,
                                                  fcmToken:
                                                      selectedUser.value!.token,
                                                  registrationId:
                                                      selectedUser.value!.token,
                                                  title:
                                                      _arTitleController.text,
                                                  videoId: videoId,
                                                  startDiscountDate:
                                                      DateTime.now().toString(),
                                                  endDiscountDate:
                                                      DateTime.now().toString(),
                                                );

                                                if (response == 200) {
                                                  Navigator.pop(context);
                                                  log("done uploading to videoid = $videoId and AR fileName = $fileName ");
                                                }

                                                log("Results\nmainUrl: $mainVideoUrl\nalphaUrl: $alphaVideoUrl\nfileName: $fileName\nUseruid: ${selectedUser.value!.useruid}\ntitle: ${_arTitleController.text}\ncaption: ${_arCaptionController.text}\ngenre: $_selectedRecommendedOptions\nisFree: ${_isFree.value}\nisPaid: ${_isPaid.value}\nPrice: ${_arPrice.value.text}");
                                              } catch (e) {
                                                Navigator.pop(context);
                                                // ignore: unawaited_futures
                                                CoolAlert.show(
                                                    context: context,
                                                    type: CoolAlertType.error,
                                                    title:
                                                        "Something went wrong",
                                                    text: e.toString());
                                              }
                                            }

                                            if (mainVideo == null) {
                                              CoolAlert.show(
                                                  context: context,
                                                  type: CoolAlertType.error,
                                                  title:
                                                      "Main video not selected",
                                                  text:
                                                      "Need to select main video");
                                            }
                                            if (alphaVideo == null) {
                                              CoolAlert.show(
                                                  context: context,
                                                  type: CoolAlertType.error,
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
