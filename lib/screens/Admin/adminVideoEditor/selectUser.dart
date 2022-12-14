// ignore_for_file: prefer_const_constructors

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:diamon_rose_app/providers/adminCreateVideoProvider.dart';
import 'package:diamon_rose_app/providers/video_editor_provider.dart';
import 'package:diamon_rose_app/screens/Admin/adminVideoEditor/InitAdminVideoEditorScreen.dart';
import 'package:diamon_rose_app/screens/Admin/adminVideoEditor/adminPexelsSearchScreen.dart';
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

class SelectUserVideoEditor extends StatelessWidget {
  SelectUserVideoEditor({
    Key? key,
  }) : super(key: key);

  final ValueNotifier<UserModel?> selectedUser =
      ValueNotifier<UserModel?>(null);
  final ImagePicker _picker = ImagePicker();

  Future<int> audioCheck({required String videoUrl}) async {
    context.read<ArVideoCreation>().setFromPexel(false);
    context.read<VideoEditorProvider>().setBackgroundVideoId(null);
    return FFprobeKit.execute(
            "-i $videoUrl -show_streams -select_streams a -loglevel error")
        .then((value) {
      return value.getOutput().then((output) {
        if (output!.isEmpty) {
          context.read<ArVideoCreation>().setArAudioFlagGeneral(0);
          return 1;
        } else {
          context.read<ArVideoCreation>().setArAudioFlagGeneral(1);
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
                      InitAdminVideoEditorScreen()));
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
                            padding: EdgeInsets.only(top: 50),
                            child: ElevatedButton(
                              child: Text("Create Video"),
                              onPressed: () {
                                _adminBgVideoSelection(context);
                              },
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

  _adminBgVideoSelection(BuildContext context) {
    return showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            height: 30.h,
            color: constantColors.whiteColor,
            width: 100.w,
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      MaterialButton(
                        color: constantColors.navButton,
                        child: Text(
                          "From Gallery",
                          style: TextStyle(
                            color: constantColors.whiteColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        onPressed: () {
                          _pickVideo(context: context);
                        },
                      ),
                      MaterialButton(
                        color: constantColors.navButton,
                        child: Text(
                          "Search Online",
                          style: TextStyle(
                            color: constantColors.whiteColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        onPressed: () {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      AdminPexelsSearchScreen()));
                        },
                      ),
                    ],
                  ),
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
