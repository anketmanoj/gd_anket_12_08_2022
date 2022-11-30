// ignore_for_file: prefer_const_constructors

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:diamon_rose_app/providers/adminCreateVideoProvider.dart';
import 'package:diamon_rose_app/providers/video_editor_provider.dart';
import 'package:diamon_rose_app/screens/Admin/adminVideoEditor/InitAdminVideoEditorScreen.dart';
import 'package:diamon_rose_app/screens/Admin/adminVideoEditor/adminPexelsSearchScreen.dart';
import 'package:diamon_rose_app/screens/PostPage/PostDetailScreen.dart';
import 'package:diamon_rose_app/screens/VideoHomeScreen/core/build_context.dart';
import 'package:diamon_rose_app/services/ArVideoCreationService.dart';
import 'package:diamon_rose_app/services/FirebaseOperations.dart';
import 'package:diamon_rose_app/services/aws/aws_upload_service.dart';
import 'package:diamon_rose_app/services/user.dart';
import 'package:diamon_rose_app/services/video.dart';
import 'package:diamon_rose_app/translations/locale_keys.g.dart';
import 'package:diamon_rose_app/widgets/global.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/ffprobe_kit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:nanoid/nanoid.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'package:universal_io/io.dart';

class AdminUserArchive extends StatelessWidget {
  AdminUserArchive({
    Key? key,
  }) : super(key: key);

  TextEditingController _titleController = TextEditingController();

  TextEditingController _bodyController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  ValueNotifier<bool> absorbing = ValueNotifier<bool>(false);

  final ValueNotifier<UserModel?> selectedUser =
      ValueNotifier<UserModel?>(null);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: constantColors.bioBg,
      appBar: AppBarWidget(text: "Select User", context: context),
      body: GestureDetector(
        onTap: () {
          final FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus &&
              currentFocus.focusedChild != null) {
            FocusManager.instance.primaryFocus!.unfocus();
          }
        },
        child: SingleChildScrollView(
          child: AnimatedBuilder(
            animation: Listenable.merge([
              selectedUser,
            ]),
            builder: (context, _) {
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
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
                              contentPadding: EdgeInsets.fromLTRB(12, 12, 0, 0),
                              border: OutlineInputBorder(),
                            ),
                            onFind: (String? filter) => getData(filter),
                            onChanged: (data) {
                              selectedUser.value = data;
                              context
                                  .read<AdminVideoCreator>()
                                  .setUserModel(data!);
                            },
                            dropdownBuilder: _customDropDownExample,
                            popupItemBuilder: _customPopupItemBuilderExample2,
                          ),
                        ),
                      ],
                    ),
                    selectedUser.value != null
                        ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              color: constantColors.whiteColor,
                              child: StreamBuilder<QuerySnapshot>(
                                  stream: FirebaseFirestore.instance
                                      .collection("posts")
                                      .where("useruid",
                                          isEqualTo:
                                              selectedUser.value!.useruid)
                                      .where("archive", isEqualTo: true)
                                      .orderBy("timestamp", descending: true)
                                      .snapshots(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Container(
                                        child: Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      );
                                    } else {
                                      if (snapshot.data!.docs.isNotEmpty) {
                                        return GridView.builder(
                                          gridDelegate:
                                              SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 2,
                                            crossAxisSpacing: 10,
                                            mainAxisSpacing: 5,
                                          ),
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            Video video = Video.fromJson(
                                                snapshot.data!.docs[index]
                                                        .data()
                                                    as Map<String, dynamic>);

                                            switch (video.timestamp
                                                .toDate()
                                                .isBefore(DateTime.now())) {
                                              case true:
                                                return InkWell(
                                                  onTap: () async {
                                                    await Get.dialog(
                                                      SimpleDialog(
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    10),
                                                            child: Row(
                                                              children: [
                                                                Expanded(
                                                                  child:
                                                                      MaterialButton(
                                                                    color: constantColors
                                                                        .navButton,
                                                                    child: Text(
                                                                      "View Post",
                                                                      style:
                                                                          TextStyle(
                                                                        color: constantColors
                                                                            .whiteColor,
                                                                        fontSize:
                                                                            16,
                                                                      ),
                                                                    ),
                                                                    onPressed:
                                                                        () async {
                                                                      Video videoVal = await context
                                                                          .read<
                                                                              FirebaseOperations>()
                                                                          .getVideoPosts(
                                                                              videoId: video.id);

                                                                      videoVal.userimage = context
                                                                          .read<
                                                                              FirebaseOperations>()
                                                                          .initUserImage;

                                                                      Navigator.push(
                                                                          context,
                                                                          PageTransition(
                                                                              child: PostDetailsScreen(
                                                                                video: videoVal,
                                                                              ),
                                                                              type: PageTransitionType.fade));
                                                                    },
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  width: 10,
                                                                ),
                                                                Expanded(
                                                                  child:
                                                                      MaterialButton(
                                                                    color: constantColors
                                                                        .navButton,
                                                                    child: Text(
                                                                      "Unarchive Post",
                                                                      style:
                                                                          TextStyle(
                                                                        color: constantColors
                                                                            .whiteColor,
                                                                        fontSize:
                                                                            16,
                                                                      ),
                                                                    ),
                                                                    onPressed:
                                                                        () async {
                                                                      await context
                                                                          .read<
                                                                              FirebaseOperations>()
                                                                          .unarchivePost(
                                                                              video: video);
                                                                      Get.back();
                                                                    },
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                    child: Stack(
                                                      children: [
                                                        Container(
                                                          color: Colors.white,
                                                          child: ImageNetworkLoader(
                                                              imageUrl: video
                                                                  .thumbnailurl),
                                                        ),
                                                        Positioned(
                                                          bottom: 5,
                                                          left: 10,
                                                          child: Container(
                                                            width: 100.w,
                                                            height: 40,
                                                            child: Row(
                                                              children: [
                                                                Icon(
                                                                  Icons
                                                                      .play_arrow_outlined,
                                                                  size: 16,
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                                Stack(
                                                                  children: [
                                                                    Text(
                                                                      video
                                                                          .views
                                                                          .toString(),
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            12,
                                                                        foreground:
                                                                            Paint()
                                                                              ..style = PaintingStyle.stroke
                                                                              ..strokeWidth = 2
                                                                              ..color = Colors.black,
                                                                      ),
                                                                    ),
                                                                    Text(
                                                                      video
                                                                          .views
                                                                          .toString(),
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            12,
                                                                        color: Colors
                                                                            .white,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );

                                              default:
                                                late String _setTime, _setDate;

                                                late String _hour,
                                                    _minute,
                                                    _time;

                                                late String dateTime;

                                                ValueNotifier<DateTime>
                                                    selectedDate =
                                                    ValueNotifier<DateTime>(
                                                        video.timestamp
                                                            .toDate());

                                                ValueNotifier<TimeOfDay>
                                                    selectedTime =
                                                    ValueNotifier<TimeOfDay>(
                                                        TimeOfDay.fromDateTime(
                                                            video.timestamp
                                                                .toDate()));

                                                Future<Null> _selectDate(
                                                    BuildContext
                                                        context) async {
                                                  final DateTime? picked =
                                                      await showDatePicker(
                                                          context: context,
                                                          initialDate:
                                                              selectedDate
                                                                  .value,
                                                          initialDatePickerMode:
                                                              DatePickerMode
                                                                  .day,
                                                          firstDate:
                                                              DateTime.now(),
                                                          lastDate:
                                                              DateTime(2101));
                                                  if (picked != null)
                                                    selectedDate.value = picked;
                                                }

                                                Future<Null> _selectTime(
                                                    BuildContext
                                                        context) async {
                                                  final TimeOfDay? picked =
                                                      await showTimePicker(
                                                    context: context,
                                                    initialTime:
                                                        selectedTime.value,
                                                  );
                                                  if (picked != null)
                                                    selectedTime.value = picked;
                                                }

                                                return AnimatedBuilder(
                                                    animation:
                                                        Listenable.merge([
                                                      selectedDate,
                                                      selectedTime
                                                    ]),
                                                    builder: (context, _) {
                                                      return InkWell(
                                                        onTap: () {
                                                          Get.bottomSheet(
                                                            Container(
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                      horizontal:
                                                                          20),
                                                              height: 20.h,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: constantColors
                                                                    .whiteColor,
                                                              ),
                                                              child: Column(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                children: [
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                            .symmetric(
                                                                        horizontal:
                                                                            150),
                                                                    child:
                                                                        Divider(
                                                                      thickness:
                                                                          4,
                                                                      color: constantColors
                                                                          .greyColor,
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    height: 10,
                                                                  ),
                                                                  Row(
                                                                    children: [
                                                                      Expanded(
                                                                        child:
                                                                            MaterialButton(
                                                                          color:
                                                                              constantColors.navButton,
                                                                          child:
                                                                              Text(
                                                                            "View Post",
                                                                            style:
                                                                                TextStyle(
                                                                              color: constantColors.whiteColor,
                                                                              fontSize: 16,
                                                                            ),
                                                                          ),
                                                                          onPressed:
                                                                              () async {
                                                                            Video
                                                                                videoVal =
                                                                                await context.read<FirebaseOperations>().getVideoPosts(videoId: video.id);

                                                                            videoVal.userimage =
                                                                                context.read<FirebaseOperations>().initUserImage;

                                                                            Navigator.push(
                                                                                context,
                                                                                PageTransition(
                                                                                    child: PostDetailsScreen(
                                                                                      video: videoVal,
                                                                                    ),
                                                                                    type: PageTransitionType.fade));
                                                                          },
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                        width:
                                                                            10,
                                                                      ),
                                                                      Expanded(
                                                                        child:
                                                                            MaterialButton(
                                                                          color:
                                                                              constantColors.navButton,
                                                                          child:
                                                                              Text(
                                                                            "Edit Post Schedule",
                                                                            style:
                                                                                TextStyle(
                                                                              color: constantColors.whiteColor,
                                                                              fontSize: 16,
                                                                            ),
                                                                          ),
                                                                          onPressed:
                                                                              () {
                                                                            _selectDate(context).then((value) => _selectTime(context)).whenComplete(() async {
                                                                              log("selectedtime == ${selectedTime.toString()} | selectedDate = ${selectedDate.toString()}");

                                                                              await context.read<FirebaseOperations>().updatePostSchedule(videoId: video.id, timeSelected: selectedTime.value, dateSelected: selectedDate.value);

                                                                              Get.back();
                                                                            });
                                                                          },
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  SizedBox(
                                                                    height: 10,
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                        child: Stack(
                                                          children: [
                                                            ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          20),
                                                              child: Stack(
                                                                children: [
                                                                  Container(
                                                                    color: Colors
                                                                        .white,
                                                                    child: ImageNetworkLoader(
                                                                        imageUrl:
                                                                            video.thumbnailurl),
                                                                  ),
                                                                  Positioned(
                                                                    bottom: 5,
                                                                    left: 10,
                                                                    child:
                                                                        Container(
                                                                      width:
                                                                          100.w,
                                                                      height:
                                                                          40,
                                                                      child:
                                                                          Row(
                                                                        children: [
                                                                          Icon(
                                                                            Icons.play_arrow_outlined,
                                                                            size:
                                                                                16,
                                                                            color:
                                                                                Colors.white,
                                                                          ),
                                                                          Stack(
                                                                            children: [
                                                                              Text(
                                                                                video.views.toString(),
                                                                                style: TextStyle(
                                                                                  fontSize: 12,
                                                                                  foreground: Paint()
                                                                                    ..style = PaintingStyle.stroke
                                                                                    ..strokeWidth = 2
                                                                                    ..color = Colors.black,
                                                                                ),
                                                                              ),
                                                                              Text(
                                                                                video.views.toString(),
                                                                                style: TextStyle(
                                                                                  fontSize: 12,
                                                                                  color: Colors.white,
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            Positioned.fill(
                                                              child: Container(
                                                                decoration: BoxDecoration(
                                                                    color: constantColors
                                                                        .black
                                                                        .withOpacity(
                                                                            0.4)),
                                                                child: Column(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    Icon(
                                                                      FontAwesomeIcons
                                                                          .clock,
                                                                      color: constantColors
                                                                          .whiteColor,
                                                                    ),
                                                                    SizedBox(
                                                                      height:
                                                                          10,
                                                                    ),
                                                                    Text(
                                                                      "${DateFormat.yMd().format(video.timestamp.toDate())} at ${DateFormat('kk:mm').format(video.timestamp.toDate())}",
                                                                      softWrap:
                                                                          true,
                                                                      style: TextStyle(
                                                                          color:
                                                                              constantColors.whiteColor),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    });
                                            }
                                          },
                                          padding: EdgeInsets.all(0),
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          itemCount: snapshot.data!.docs.length,
                                        );
                                      } else {
                                        return Container(
                                          child: Center(
                                            child: Text(
                                              "No Archived Posts",
                                              style: TextStyle(
                                                color: constantColors.mainColor,
                                                fontSize: 20,
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                    }
                                  }),
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
