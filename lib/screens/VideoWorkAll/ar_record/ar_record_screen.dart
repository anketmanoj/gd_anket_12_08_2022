import 'dart:async';

import 'package:camera/camera.dart';
import 'package:diamon_rose_app/constants/styles/colors.dart';
import 'package:diamon_rose_app/constants/styles/style.dart';
import 'package:diamon_rose_app/screens/VideoWorkAll/ar_record/ar_record_view_model.dart';

import 'package:diamon_rose_app/widgets/countdown.dart';
import 'package:diamon_rose_app/widgets/custom_scaffold.dart';
import 'package:diamon_rose_app/widgets/single_selection_list.dart';
import 'package:diamon_rose_app/widgets/utils.dart';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart' hide Trans;
import 'package:image_picker/image_picker.dart';

class ArRecordScreen extends GetView<ArRecordViewModel> {
  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      body: Container(
        width: widthScreen(),
        height: heightScreen(),
        color: AppColors.white,
        child: _body(context),
      ),
    );
  }

  Widget _body(BuildContext context) => Container(
      width: widthScreen(),
      height: heightScreen(),
      child: Obx(() => controller.isInit == true
          ? _cameraView(context)
          : Container(
              color: AppColors.black,
            )));

  Widget _cameraView(BuildContext context) {
    final double scale = controller.cameraController!.value.aspectRatio;

    return Stack(
      children: [
        Align(
            child: AspectRatio(
          aspectRatio: scale / 2.1,
          child: Transform.scale(
              scale: scale, child: CameraPreview(controller.cameraController!)),
        )),
        _countdownTimer(context),
        Container(
          width: widthScreen(),
          height: heightScreen(),
          child: Align(
              alignment: Alignment.bottomRight, child: _buttonSwitchCamera()),
        ),
        Container(
          width: widthScreen(),
          height: heightScreen(),
          child:
              Align(alignment: Alignment.bottomLeft, child: _buttonPickVideo()),
        ),
        Container(
          padding: EdgeInsets.only(top: 20, left: 20),
          color: AppColors.dark,
          width: widthScreen(),
          alignment: Alignment.bottomLeft,
          height: heightScreen(percent: 10),
          child: _backButton(context),
        ),
        Container(
          height: heightScreen(percent: 10),
          width: widthScreen(),
          child: Container(
            alignment: Alignment.bottomCenter,
            child: Obx(() => controller.isRecordingVideo.value == true
                ? Countdown(
                    animation: StepTween(
                      begin: 0,
                      end: 1 * 60,
                    ).animate(controller.animationController),
                  )
                : Text(
                    "00:00",
                    style: TextStyle(color: AppColors.white),
                  )),
          ),
        ),
        Container(
          padding: EdgeInsets.only(top: 20, right: 20),
          height: heightScreen(percent: 10),
          width: widthScreen(),
          child: Container(
            alignment: Alignment.bottomRight,
            child: _buttonTimer(context),
          ),
        )
      ],
    );
  }

  Widget _buttonSwitchCamera() => Obx(
        () => Container(
            child: controller.isRecordingVideo.value
                ? Container()
                : Container(
                    margin: EdgeInsets.only(bottom: 20, right: 20),
                    child: IconButton(
                        onPressed: () => controller.updateCameraId(),
                        icon: SvgPicture.asset(
                          'assets/images/svg/ic_switch_camera.svg',
                        )),
                  )),
      );

  Widget _buttonPickVideo() => Obx(
        () => Container(
            child: controller.isRecordingVideo.value
                ? Container()
                : Container(
                    margin: EdgeInsets.only(bottom: 20, left: 20),
                    child: IconButton(
                      onPressed: openVideoGallery,
                      icon: Icon(
                        Icons.image,
                        size: 34,
                        color: AppColors.white,
                      ),
                    ),
                  )),
      );

  Widget _buttonTimer(BuildContext context) => Obx(
        () => Container(
            child: controller.isRecordingVideo.value
                ? Container()
                : GestureDetector(
                    onTap: () => _showTimerOptionsBottomSheet(context),
                    child: Container(
                      margin: EdgeInsets.only(top: heightScreen(percent: 2)),
                      child: Column(
                        children: [
                          SvgPicture.asset(
                            'assets/images/svg/timer.svg',
                            height: 12,
                            color: AppColors.white,
                          ),
                          Text(
                            "labelTimer",
                            style: AppStyles.typeText18(
                                color: AppColors.white, size: 12),
                          )
                        ],
                      ),
                    ),
                  )),
      );

  Widget _backButton(BuildContext context) {
    return GestureDetector(
        onTap: controller.back,
        child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          Icon(
            Icons.arrow_back_ios,
            size: 28,
            color: AppColors.white,
          ),
          Text("back", style: AppStyles.typeWeight400(color: AppColors.white))
        ]));
  }

  Widget _countdownTimer(BuildContext context) => Center(
      child: Obx(() => controller.countdownCounter.value == 0
          ? Container()
          : Text(
              '${controller.countdownCounter.value}',
              style: AppStyles.typeWeight500(color: AppColors.white, size: 60),
            )));

  void _showTimerOptionsBottomSheet(BuildContext context) {
    showModalBottomSheet(
        context: context,
        backgroundColor: AppColors.white,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: _timerOptions);
  }

  Widget _timerOptions(BuildContext context) {
    final title = "labelTimer";

    final first = "off";
    final second = '3 seconds';
    final third = '5 seconds';
    final forth = '10 seconds';
    final options = [first, second, third, forth];

    final selectedIndex = controller.countdownTimer == 0
        ? 0
        : (controller.countdownTimer == 3
            ? 1
            : (controller.countdownTimer == 5 ? 2 : 3));

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: SingleSelectionList(
          title: title,
          options: options,
          selectedIndex: selectedIndex,
          onSelect: (index) => {
                if (index == 0)
                  {controller.countdownTimer = 0}
                else if (index == 1)
                  {controller.countdownTimer = 3}
                else if (index == 2)
                  {controller.countdownTimer = 5}
                else
                  {controller.countdownTimer = 10}
              }),
    );
  }

  Future<void> openVideoGallery() async {
    ImageCache().clear();
    final ImagePicker _picker = ImagePicker();
    final XFile? file = await _picker.pickVideo(source: ImageSource.gallery);

    unawaited(controller.handleSelectedVideo(file));
  }
}
