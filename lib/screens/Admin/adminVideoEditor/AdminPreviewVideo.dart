// ignore_for_file: unawaited_futures

import 'dart:developer';
import 'dart:io';

import 'package:aws_s3_upload/aws_s3_upload.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:diamon_rose_app/constants/Constantcolors.dart';
import 'package:diamon_rose_app/providers/adminCreateVideoProvider.dart';
import 'package:diamon_rose_app/providers/ffmpegProviders.dart';
import 'package:diamon_rose_app/providers/homeScreenProvider.dart';
import 'package:diamon_rose_app/providers/video_editor_provider.dart';
import 'package:diamon_rose_app/screens/feedPages/feedPage.dart';
import 'package:diamon_rose_app/screens/testVideoEditor/ArContainerClass/ArContainerClass.dart';
import 'package:diamon_rose_app/services/aws/aws_upload_service.dart';
import 'package:diamon_rose_app/services/mux/mux_video_stream.dart';
import 'package:diamon_rose_app/widgets/global.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class AdminPreviewVideoScreen extends StatefulWidget {
  const AdminPreviewVideoScreen(
      {Key? key,
      required this.videoFile,
      required this.thumbnailFile,
      required this.arList,
      required this.bgFile,
      required this.bgMaterialThumnailFile})
      : super(key: key);

  final File videoFile;
  final File bgFile;
  final File thumbnailFile;
  final List<ARList> arList;
  final File bgMaterialThumnailFile;

  @override
  State<AdminPreviewVideoScreen> createState() =>
      _AdminPreviewVideoScreenState();
}

class _AdminPreviewVideoScreenState extends State<AdminPreviewVideoScreen> {
  final ConstantColors constantColors = ConstantColors();
  TextEditingController _videotitleController = TextEditingController();
  TextEditingController _videoCaptionController = TextEditingController();
  TextEditingController _contentPrice = TextEditingController();

  String? _setContentPrice;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isFree = true;
  bool _isSubscription = false;
  bool _isPaid = false;
  late List<ARList> selectMaterials;
  ValueNotifier<bool> bgSelected = ValueNotifier<bool>(true);

  List<String?> _selectedRecommendedOptions = [];

  DateTime _endDiscountDate = DateTime.now();
  // show todays date as Sun, Jan 14
  DateTime _startDiscountDate = DateTime.now();

  TextEditingController _contentDiscount = TextEditingController();

  String _setContentDiscount = "";

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
  void initState() {
    selectMaterials = widget.arList;

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  String _contentAvailableToValue = "All";

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBarWidget(text: "Admin Video Settings", context: context),
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
                          // _recommendedOptions = values;
                          _selectedRecommendedOptions = values;

                          print(
                              "length == ${_selectedRecommendedOptions.length}");
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
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            "Add / Remove Materials",
                            style: TextStyle(
                              color: constantColors.whiteColor,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ValueListenableBuilder<bool>(
                      valueListenable: bgSelected,
                      builder: (context, bgVal, _) {
                        return ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: selectMaterials.length,
                          itemBuilder: (context, index) {
                            return ValueListenableBuilder<bool>(
                                valueListenable:
                                    selectMaterials[index].selectedMaterial!,
                                builder: (context, selected, _) {
                                  switch (index) {
                                    case 0:
                                      return Column(
                                        children: [
                                          ListTile(
                                            trailing: Switch(
                                              activeColor:
                                                  constantColors.navButton,
                                              value: bgVal,
                                              onChanged: (val) {
                                                bgSelected.value = val;
                                              },
                                            ),
                                            leading: Container(
                                              height: 50,
                                              width: 50,
                                              child: Image.file(widget
                                                  .bgMaterialThumnailFile),
                                            ),
                                            title: Text(
                                              "Background",
                                            ),
                                          ),
                                          ListTile(
                                            trailing: Switch(
                                              activeColor:
                                                  constantColors.navButton,
                                              value: selected,
                                              onChanged: (val) {
                                                selectMaterials[index]
                                                    .selectedMaterial!
                                                    .value = val;

                                                log(selectMaterials
                                                    .where((element) =>
                                                        element
                                                            .selectedMaterial!
                                                            .value ==
                                                        true)
                                                    .toList()
                                                    .length
                                                    .toString());
                                              },
                                            ),
                                            leading: selectMaterials[index]
                                                        .layerType ==
                                                    LayerType.AR
                                                ? Container(
                                                    height: 50,
                                                    width: 50,
                                                    child: ImageNetworkLoader(
                                                        imageUrl: selectMaterials[
                                                                index]
                                                            .pathsForVideoFrames![0]),
                                                  )
                                                : Container(
                                                    height: 50,
                                                    width: 50,
                                                    child: Image.file(File(
                                                        selectMaterials[index]
                                                            .gifFilePath!)),
                                                  ),
                                            title: Text(
                                              selectMaterials[index]
                                                          .layerType ==
                                                      LayerType.AR
                                                  ? "AR Cut out"
                                                  : "Effect Added",
                                            ),
                                          ),
                                        ],
                                      );

                                    default:
                                      return ListTile(
                                        trailing: Switch(
                                          activeColor: constantColors.navButton,
                                          value: selected,
                                          onChanged: (val) {
                                            selectMaterials[index]
                                                .selectedMaterial!
                                                .value = val;

                                            log(selectMaterials
                                                .where((element) =>
                                                    element.selectedMaterial!
                                                        .value ==
                                                    true)
                                                .toList()
                                                .length
                                                .toString());
                                          },
                                        ),
                                        leading:
                                            selectMaterials[index].layerType ==
                                                    LayerType.AR
                                                ? Container(
                                                    height: 50,
                                                    width: 50,
                                                    child: ImageNetworkLoader(
                                                        imageUrl: selectMaterials[
                                                                index]
                                                            .pathsForVideoFrames![0]),
                                                  )
                                                : Container(
                                                    height: 50,
                                                    width: 50,
                                                    child: Image.file(File(
                                                        selectMaterials[index]
                                                            .gifFilePath!)),
                                                  ),
                                        title: Text(
                                          selectMaterials[index].layerType ==
                                                  LayerType.AR
                                              ? "AR Cut out"
                                              : "Effect Added",
                                        ),
                                      );
                                  }
                                });
                          },
                        );
                      }),
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
                                            final double endPrice = double
                                                    .parse(_contentPrice.text) *
                                                (1 - double.parse(value) / 100);

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
                                  crossAxisAlignment: CrossAxisAlignment.center,
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
                                      onPressed: () => _selectEndDate(context),
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
                                "\$1 = 1 Carat on Glamorous Diastation. Although you're setting the value of your content in Dollars, user will be using Carats to purchase items you've created!",
                                style: TextStyle(
                                  fontSize: 12,
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
                      Consumer<VideoEditorProvider>(
                          builder: (context, videoEditor, _) {
                        log("video here = ${videoEditor.getBackgroundVideoFile.path}");
                        return Padding(
                          padding: const EdgeInsets.only(top: 30, bottom: 30),
                          child: SubmitButton(function: () async {
                            if (_formKey.currentState!.validate() &&
                                _selectedRecommendedOptions.length > 0) {
                              // ignore: unawaited_futures
                              CoolAlert.show(
                                  barrierDismissible: false,
                                  context: context,
                                  type: CoolAlertType.loading,
                                  text: "Uploading Video");

                              log("now");

                              String? coverThumbnail = await AwsAnketS3.uploadFile(
                                  accessKey: "AKIATF76MVYR34JAVB7H",
                                  secretKey:
                                      "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",
                                  bucket: "anketvideobucket",
                                  file: widget.thumbnailFile,
                                  filename:
                                      "${Timestamp.now().millisecondsSinceEpoch}_bgThumbnailGif.gif",
                                  region: "us-east-1",
                                  destDir:
                                      "${Timestamp.now().millisecondsSinceEpoch}");

                              log("thumbnail == $coverThumbnail");

                              final bool result = await context
                                  .read<AdminVideoCreator>()
                                  .uploadVideo(
                                    coverThumbnailUrl: coverThumbnail!,
                                    addBgToMaterials: bgSelected.value,
                                    ctx: context,
                                    backgroundVideoFile:
                                        videoEditor.getBackgroundVideoFile,
                                    arListVal: selectMaterials
                                        .where((element) =>
                                            element.selectedMaterial!.value ==
                                            true)
                                        .toList(),
                                    videoFile: widget.videoFile,
                                    userUid: context
                                        .read<AdminVideoCreator>()
                                        .getUserModel!
                                        .useruid,
                                    caption: _videoCaptionController.text,
                                    isPaid: _isPaid,
                                    price: _contentPrice.text.isEmpty
                                        ? 0
                                        : double.parse(_contentPrice.text),
                                    discountAmount: _contentDiscount
                                            .text.isEmpty
                                        ? 0
                                        : double.parse(_contentDiscount.text),
                                    startDiscountDate:
                                        Timestamp.fromDate(_startDiscountDate),
                                    endDiscountDate:
                                        Timestamp.fromDate(_endDiscountDate),
                                    isSubscription: _isSubscription,
                                    contentAvailability:
                                        _contentAvailableToValue,
                                    isFree: _isFree,
                                    video_title: _videotitleController.text,
                                    genre: _selectedRecommendedOptions,
                                  );

                              log("done uploading");

                              if (result == true) {
                                log("works!!@!!");

                                widget.arList.forEach((arVal) {
                                  deleteFile(arVal.pathsForVideoFrames!);
                                });
                                Navigator.pushReplacement(
                                  context,
                                  PageTransition(
                                      child: FeedPage(),
                                      type: PageTransitionType.leftToRight),
                                );
                              } else if (result == false) {
                                log("SHIT!");
                                CoolAlert.show(
                                  context: context,
                                  type: CoolAlertType.error,
                                  title: "Error Uploading Video",
                                  text: "AWS error",
                                );
                              }

                              //ignore: avoid_catches_without_on_clauses

                            } else if (_selectedRecommendedOptions.length ==
                                0) {
                              CoolAlert.show(
                                context: context,
                                type: CoolAlertType.error,
                                title: "No Selected Genre",
                                text: "Please Select a Genre for your video",
                              );
                            }
                          }),
                        );
                      }),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      // SingleChildScrollView(
      //   child: SafeArea(
      //     top: false,
      //     child: Padding(
      //       padding: const EdgeInsets.all(20),
      //       child: Form(
      //         key: _formKey,
      //         child: Column(
      //           children: [
      //             Stack(
      //               children: [
      //                 InkWell(
      //                   onTap: () {
      //                     widget.videoPlayerController.play();
      //                   },
      //                   onDoubleTap: () {
      //                     widget.videoPlayerController.pause();
      //                   },
      //                   child: Container(
      //                     height: MediaQuery.of(context).size.height * .55,

      //                     color: constantColors.whiteColor,
      //                     child: AspectRatio(
      //                       aspectRatio: 16 / 9,
      //                       child:
      //                           widget.videoPlayerController.value.isInitialized
      //                               ? VideoPlayer(
      //                                   widget.videoPlayerController,
      //                                 )
      //                               : Container(
      //                                   height: 50,
      //                                   width: 50,
      //                                   child: CircularProgressIndicator(),
      //                                 ),
      //                     ),
      //                     // child: Image.file(storyImage),
      //                   ),
      //                 ),
      //                 Positioned(
      //                   top: MediaQuery.of(context).size.height * 0.45,
      //                   child: Container(
      //                     width: MediaQuery.of(context).size.width,
      //                     child: Row(
      //                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      //                       children: [
      //                         FloatingActionButton(
      //                           heroTag: "Reselect Image",
      //                           backgroundColor: constantColors.redColor,
      //                           child: Icon(
      //                             Icons.clear,
      //                             color: constantColors.whiteColor,
      //                           ),
      //                           onPressed: () {
      //                             widget.videoPlayerController
      //                                 .dispose()
      //                                 .then((value) {
      //                               Navigator.pop(context);
      //                             });
      //                           },
      //                         ),
      //                       ],
      //                     ),
      //                   ),
      //                 ),
      //               ],
      //             ),
      //             SizedBox(
      //               height: 20,
      //             ),
      //             ProfileUserDetails(
      //               controller: _videotitleController,
      //               labelText: "Video Title",
      //               onSubmit: (val) {},
      //               validator: (val) {
      //                 if (val!.isEmpty) {
      //                   return "Please enter video title";
      //                 }
      //                 return null;
      //               },
      //             ),
      //             Padding(
      //               padding: const EdgeInsets.only(top: 20),
      //               child: ProfileUserDetails(
      //                 controller: _songNameController,
      //                 labelText: "Song Name",
      //                 onSubmit: (val) {},
      //                 validator: (val) {
      //                   if (val!.isEmpty) {
      //                     return "Please enter song name";
      //                   }
      //                   return null;
      //                 },
      //               ),
      //             ),
      //             const SizedBox(
      //               height: 20,
      //             ),
      //             Container(
      //               child: Row(
      //                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      //                 children: [
      //                   Container(
      //                     alignment: Alignment.topCenter,
      //                     child: FilterChip(
      //                       showCheckmark: false,
      //                       backgroundColor: Colors.black,
      //                       label: Container(
      //                         alignment: Alignment.center,
      //                         width: size.width * 0.35,
      //                         child: Text(
      //                           "Free",
      //                           style: TextStyle(
      //                             color: constantColors.whiteColor,
      //                           ),
      //                         ),
      //                       ),
      //                       selected: isFree,
      //                       onSelected: (bool value) {
      //                         setState(() {
      //                           isFree = value;
      //                           isPaid = !value;
      //                         });
      //                       },
      //                       pressElevation: 15,
      //                       selectedColor: constantColors.mainColor,
      //                     ),
      //                   ),
      //                   Container(
      //                     alignment: Alignment.topCenter,
      //                     child: FilterChip(
      //                       backgroundColor: Colors.black,
      //                       showCheckmark: false,
      //                       label: Container(
      //                         alignment: Alignment.center,
      //                         width: size.width * 0.35,
      //                         child: Text(
      //                           "Paid",
      //                           style: TextStyle(
      //                             color: constantColors.whiteColor,
      //                           ),
      //                         ),
      //                       ),
      //                       selected: isPaid,
      //                       onSelected: (bool value) {
      //                         setState(() {
      //                           isPaid = value;
      //                           isFree = !value;
      //                         });
      //                       },
      //                       pressElevation: 15,
      //                       selectedColor: constantColors.mainColor,
      //                     ),
      //                   ),
      //                 ],
      //               ),
      //             ),
      //             const SizedBox(
      //               height: 20,
      //             ),
      // Container(
      //   height: 120,
      //   child: MultiSelectChipField<String?>(
      //     headerColor: constantColors.mainColor,
      //     decoration: BoxDecoration(
      //       borderRadius: BorderRadius.circular(20),
      //     ),
      //     selectedChipColor:
      //         constantColors.navButton.withOpacity(0.4),
      //     title: Text(
      //       "Select Genre",
      //       style: TextStyle(
      //         color: constantColors.whiteColor,
      //         fontSize: 15,
      //       ),
      //     ),
      //     items: _recommendedOptions
      //         .map((e) => MultiSelectItem(e, e!))
      //         .toList(),
      //     initialValue: [_recommendedOptions[0]],
      //     onTap: (values) {
      //       // _recommendedOptions = values;
      //       _selectedRecommendedOptions = values;

      //       print(
      //           "length == ${_selectedRecommendedOptions.length}");
      //     },
      //   ),
      // ),
      //             const SizedBox(
      //               height: 20,
      //             ),
      // SubmitButton(function: () async {
      //   if (_formKey.currentState!.validate() &&
      //       _selectedRecommendedOptions.length > 0) {
      //     print(
      //         "has recommended genre = ${_selectedRecommendedOptions.length}");
      //     // ignore: unawaited_futures
      //     CoolAlert.show(
      //         context: context,
      //         type: CoolAlertType.loading,
      //         text: "Uploading Video");
      //     try {
      //       await firebaseOperations
      //           .uploadVideo(
      //         videoFile: widget.videoFile,
      //         userUid: auth.getUserId,
      //         free: isFree,
      //         video_title: _videotitleController.text,
      //         song_name: _songNameController.text,
      //         genre: _selectedRecommendedOptions,
      //       )
      //           .whenComplete(() {
      //         widget.videoPlayerController.dispose();
      //         // Navigator.pushReplacement(
      //         //   context,
      //         //   PageTransition(
      //         //       child: FeedPage(),
      //         //       type: PageTransitionType.leftToRight),
      //         // );
      //         Navigator.pop(context);
      //         Navigator.pop(context);
      //         Navigator.pop(context);
      //       });
      //       // ignore: avoid_catches_without_on_clauses
      //     } catch (e) {
      //       CoolAlert.show(
      //         context: context,
      //         type: CoolAlertType.error,
      //         title: "Error Uploading Video",
      //         text: e.toString(),
      //       );
      //       // ignore: unawaited_futures

      //     }
      //   } else if (_selectedRecommendedOptions.length == 0) {
      //     CoolAlert.show(
      //       context: context,
      //       type: CoolAlertType.error,
      //       title: "No Selected Genre",
      //       text: "Please Select a Genre for your video",
      //     );
      //   }
      // }),
      //           ],
      //         ),
      //       ),
      //     ),
      //   ),
      // ),
    );
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
  final AdminPreviewVideoScreen widget;
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
                height: 25.h,
                child: Image.file(
                  widget.thumbnailFile,
                  filterQuality: FilterQuality.low,
                  fit: BoxFit.cover,
                )),
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
