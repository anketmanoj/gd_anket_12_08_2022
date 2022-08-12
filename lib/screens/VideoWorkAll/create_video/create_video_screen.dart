import 'package:diamon_rose_app/constants/styles/colors.dart';
import 'package:diamon_rose_app/layer_entity/layer_entity.dart';
import 'package:diamon_rose_app/screens/VideoWorkAll/create_video/create_video_view_model.dart';
import 'package:diamon_rose_app/screens/VideoWorkAll/create_video/value/actions_toolbar_create_video.dart';
import 'package:diamon_rose_app/screens/VideoWorkAll/create_video/value/bottom_bar_create_video.dart';
import 'package:diamon_rose_app/share/localizations/l10n/localy.dart';
import 'package:diamon_rose_app/widgets/layer_video_widget.dart';
import 'package:diamon_rose_app/widgets/sliding_up_paned_widget.dart';
import 'package:diamon_rose_app/widgets/video_progress_bar_widget.dart';
import 'package:diamon_rose_app/widgets/widgets.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CreateVideoView extends GetView<CreateVideoVideoModel> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WillPopScope(
        onWillPop: () async {
          if (controller.panelController.value.isPanelOpen) {
            await controller.panelController.value.close();
            return false;
          }
          return true;
        },
        child: Scaffold(
            extendBodyBehindAppBar: true,
            backgroundColor: AppColors.black,
            appBar: appBarApp(
              actIconLeft: Get.back,
              isGradientBackground: true,
              title: "create video",
              titleColor: AppColors.white,
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconLeft: Icon(Icons.arrow_back_ios, color: AppColors.white),
            ),
            body: Obx(buildBody)),
      ),
    );
  }

  Widget buildBody() {
    return SlidingUpPanelWidget(
      height: MediaQuery.of(Get.context!).size.height * 0.5,
      controller: controller.panelController.value,
      bottomSheet: BottomBarCreateVideo(controller: controller),
      padding: EdgeInsets.only(top: 15),
      body: Stack(
        children: [
          ...controller.getBackgroundsSelected.map(_buildLayerItem).toList(),
          ...controller.getEffectsSelected.map(_buildLayerItem).toList(),
          ...controller.getARsSelected.map(_buildLayerItem).toList(),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 60, horizontal: 27),
            child: VideoProgressBarWidget(currentTime: 0, videoDuration: 60),
          ),
          Align(
              alignment: Alignment.centerRight,
              child: ActionsToolbarCreateVideo(controller: controller)),
        ],
      ),
      onPanelOpened: controller.onOpenPanel,
    );
  }

  Widget _buildLayerItem(LayerEntity layer) {
    return Positioned(
      left: layer.xcoordinates * controller.getScreenWidth,
      top: layer.ycoordinates * controller.getScreenHeight,
      child: Container(
          width: layer.width,
          height: layer.height,
          child: layer.itemThumbnailUrl.isNotEmpty
              ? SizedBox.expand(
                  child: FittedBox(
                      fit: BoxFit.fill,
                      child: Image.network(layer.itemThumbnailUrl)),
                )
              : LayerVideoWidget(
                  url: layer.itemUrl,
                  loadingWidget: Container(
                      child: Center(
                          child:
                              Container(child: CircularProgressIndicator()))),
                )),
    );
  }
}
