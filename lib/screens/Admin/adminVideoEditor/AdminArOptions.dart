// ignore_for_file: prefer_const_constructors

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:diamon_rose_app/providers/adminCreateVideoProvider.dart';
import 'package:diamon_rose_app/providers/video_editor_provider.dart';
import 'package:diamon_rose_app/screens/Admin/adminVideoEditor/AdminGdArNotificationScreen.dart';
import 'package:diamon_rose_app/screens/Admin/adminVideoEditor/AdminInitArVideoEditorScreen.dart';
import 'package:diamon_rose_app/screens/Admin/adminVideoEditor/InitAdminVideoEditorScreen.dart';
import 'package:diamon_rose_app/screens/VideoHomeScreen/core/build_context.dart';
import 'package:diamon_rose_app/services/ArVideoCreationService.dart';
import 'package:diamon_rose_app/services/FirebaseOperations.dart';
import 'package:diamon_rose_app/services/aws/aws_upload_service.dart';
import 'package:diamon_rose_app/services/user.dart';
import 'package:diamon_rose_app/translations/locale_keys.g.dart';
import 'package:diamon_rose_app/widgets/global.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/ffprobe_kit.dart';
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

class AdminArOptions extends StatelessWidget {
  AdminArOptions({
    Key? key,
  }) : super(key: key);

  final ValueNotifier<UserModel?> selectedUser =
      ValueNotifier<UserModel?>(null);
  final ImagePicker _picker = ImagePicker();

  Future<int> audioCheck({required String videoUrl}) async {
    context.read<ArVideoCreation>().setFromPexel(false);
    return FFprobeKit.execute(
            "-i $videoUrl -show_streams -select_streams a -loglevel error")
        .then((value) {
      return value.getOutput().then((output) {
        if (output!.isEmpty) {
          ArVideoCreation().setArAudioFlagGeneral(0);
          return 0;
        } else {
          ArVideoCreation().setArAudioFlagGeneral(1);
          return 1;
        }
      });
    });
  }

  _pickVideo({required BuildContext context}) async {
    final XFile? file = await _picker.pickVideo(
      source: ImageSource.gallery,
    );
    if (file != null) {
      final int audioFlag = await audioCheck(videoUrl: file.path);

      switch (audioFlag) {
        case 1:
          context
              .read<VideoEditorProvider>()
              .setBackgroundVideoFile(File(file.path));
          Navigator.push(
              context,
              MaterialPageRoute<void>(
                  builder: (BuildContext context) =>
                      InitAdminVideoEditorScreen(file: File(file.path))));
          break;
        default:
          CoolAlert.show(
            context: context,
            type: CoolAlertType.info,
            title: LocaleKeys.videocontainsnoaudio.tr(),
            text: LocaleKeys.onlyVideoWithAudioSupported.tr(),
          );
      }
      // ignore: unawaited_futures

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: constantColors.bioBg,
      appBar: AppBarWidget(text: "Admin AR Options", context: context),
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
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(top: 10),
                                  child: ElevatedButton(
                                    child: Text("Select AR Video"),
                                    onPressed: () {
                                      selectVideoOptionsSheet(context);
                                    },
                                  ),
                                ),
                                Divider(),
                                Container(
                                  height: 60.h,
                                  width: 100.w,
                                  child: AdminGDARNotificationScreen(
                                    userModel: selectedUser.value!,
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
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
    );
  }

  Future<File?> _pickArVideo(
      {required BuildContext context, required ImageSource source}) async {
    final XFile? file = await _picker.pickVideo(
      source: source,
    );
    if (file != null) {
      return File(file.path);
    } else {
      return null;
    }
  }

  Future selectVideoOptionsSheet(BuildContext context) async {
    return showModalBottomSheet(
        context: context,
        builder: (context) {
          return SafeArea(
            bottom: true,
            child: Container(
              // ignore: sort_child_properties_last
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 150),
                    child: Divider(
                      thickness: 4,
                      color: constantColors.navButton,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Select Video Option",
                          style: TextStyle(
                            color: constantColors.navButton,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          )),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      MaterialButton(
                        color: constantColors.navButton,
                        child: Text(
                          'Gallery',
                          style: TextStyle(
                            color: constantColors.whiteColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        onPressed: () async {
                          final File? inputFile = await _pickArVideo(
                              context: context, source: ImageSource.gallery);

                          if (inputFile != null) {
                            // ignore: unawaited_futures

                            final int audioFlag =
                                await audioCheck(videoUrl: inputFile.path);

                            switch (audioFlag) {
                              case 1:
                                // ignore: unawaited_futures
                                Navigator.push(
                                    context,
                                    MaterialPageRoute<void>(
                                        builder: (BuildContext context) =>
                                            AdminArVideoEditorScreen(
                                                userModel: selectedUser.value!,
                                                file: inputFile)));
                                break;
                              case 0:
                                // ignore: unawaited_futures
                                Navigator.push(
                                    context,
                                    MaterialPageRoute<void>(
                                        builder: (BuildContext context) =>
                                            AdminArVideoEditorScreen(
                                                userModel: selectedUser.value!,
                                                file: inputFile)));
                                break;
                              default:
                                CoolAlert.show(
                                  context: context,
                                  type: CoolAlertType.info,
                                  title: "Video processing error",
                                  text:
                                      "Please check video source and ensure there isnt any problems with the video",
                                );
                            }
                          } else {
                            // ignore: unawaited_futures
                            CoolAlert.show(
                              context: context,
                              type: CoolAlertType.error,
                              title: "Error",
                              text: LocaleKeys.novideoselected.tr(),
                            );
                          }
                        },
                      ),
                      MaterialButton(
                        color: constantColors.navButton,
                        child: Text(
                          'Camera',
                          style: TextStyle(
                            color: constantColors.whiteColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        onPressed: () async {
                          final File? inputFile = await _pickArVideo(
                              context: context, source: ImageSource.camera);

                          if (inputFile != null) {
                            // ignore: unawaited_futures

                            final int audioFlag =
                                await audioCheck(videoUrl: inputFile.path);

                            switch (audioFlag) {
                              case 1:
                                // ignore: unawaited_futures
                                Navigator.push(
                                    context,
                                    MaterialPageRoute<void>(
                                        builder: (BuildContext context) =>
                                            AdminArVideoEditorScreen(
                                                userModel: selectedUser.value!,
                                                file: inputFile)));
                                break;
                              default:
                                CoolAlert.show(
                                  context: context,
                                  type: CoolAlertType.info,
                                  title: LocaleKeys.videocontainsnoaudio.tr(),
                                  text: LocaleKeys.onlyVideoWithAudioSupported
                                      .tr(),
                                );
                            }
                          } else {
                            // ignore: unawaited_futures
                            CoolAlert.show(
                              context: context,
                              type: CoolAlertType.error,
                              title: "Error",
                              text: LocaleKeys.novideoselected.tr(),
                            );
                          }
                        },
                      ),
                    ],
                  )
                ],
              ),
              height: MediaQuery.of(context).size.height * 0.2,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: constantColors.whiteColor,
                borderRadius: BorderRadius.circular(12),
              ),
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
