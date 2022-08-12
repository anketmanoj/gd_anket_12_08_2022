import 'package:diamon_rose_app/collection_entity/background_entity.dart';
import 'package:diamon_rose_app/collection_entity/effect_entity.dart';
import 'package:diamon_rose_app/constants/styles/colors.dart';
import 'package:diamon_rose_app/constants/styles/style.dart';
import 'package:diamon_rose_app/enum/layer_type.dart';
import 'package:diamon_rose_app/layer_entity/layer_entity.dart';
import 'package:diamon_rose_app/my_ar_entity/my_ar_entity.dart';
import 'package:diamon_rose_app/screens/VideoWorkAll/edit_video/edit_video_view_model.dart';
import 'package:diamon_rose_app/screens/VideoWorkAll/edit_video/values/edit_video_border.dart';
import 'package:diamon_rose_app/screens/VideoWorkAll/edit_video/values/range_slider_widget.dart';
import 'package:diamon_rose_app/screens/VideoWorkAll/edit_video/values/video_range_slider_widget.dart';
import 'package:diamon_rose_app/screens/VideoWorkAll/edit_video/values/volume_slider_widget.dart';
import 'package:diamon_rose_app/screens/VideoWorkAll/edit_video/views/edit_view.dart';
import 'package:diamon_rose_app/share/localizations/l10n/localy.dart';
import 'package:diamon_rose_app/widgets/button_action.dart';
import 'package:diamon_rose_app/widgets/image_placeholder_widget.dart';
import 'package:diamon_rose_app/widgets/layer_video_widget.dart';
import 'package:diamon_rose_app/widgets/shimmer_custom.dart';
import 'package:diamon_rose_app/widgets/sliding_up_paned_widget.dart';
import 'package:diamon_rose_app/widgets/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class PositionView extends StatelessWidget {
  const PositionView({Key? key, required this.controller}) : super(key: key);
  final EditVideoViewModel controller;

  @override
  Widget build(BuildContext context) => SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: _buildBody(),
        ),
      );

  Widget _buildBody() {
    return Stack(
      children: [
        EditView(controller: controller, isPreviewPage: false),
        _buildFrame(),
        ...EditVideoBorder().BuildBorder(controller),
        Align(
          alignment: Alignment.centerRight,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: SvgPicture.asset(
                  "assets/images/svg/ic_undo.svg",
                  color: AppColors.white,
                ),
                onPressed: () =>
                    controller.isCanUndo ? controller.onLayerUndo() : null,
              ),
              IconButton(
                icon: SvgPicture.asset(
                  "assets/images/svg/ic_layer_list.svg",
                  color: AppColors.white,
                ),
                onPressed: controller.panelController.open,
              ),
            ],
          ),
        ),
        SlidingUpPanelWidget(
          /// (getLayers.length * 90) is layers range slider height,
          /// and (+ 70) is video range slider height
          height: controller.getLayers.length * 90 + 70,
          controller: controller.panelController,
          body: SizedBox.shrink(),
          bottomSheet: _bottomSheet(),
          onPanelOpened: controller.onPanelOpened,
          onPanelClosed: controller.onPanelClosed,
        ),
      ],
    );
  }

  Widget _bottomSheet() {
    return GetBuilder<EditVideoViewModel>(builder: (_) {
      return SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            VideoRangeSliderWidget(
                max: controller.videoMaxRange,
                values: controller.getVideoRange,
                onChanged: controller.onVideoRangeChange),
            ..._buildRangeSliders(controller.getLayers),
          ],
        ),
      );
    });
  }

  List _buildRangeSliders(List<LayerEntity> layers) {
    controller.getLayerSelected;
    final rangeSliders = layers.map((layer) {
      return _buildRangeSliderItem(layer, controller.getLayerSelected == layer);
    }).toList();
    return rangeSliders;
  }

  Widget _buildRangeSliderItem(LayerEntity layer, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      color:
          isSelected ? AppColors.rangeBackgroundColor.withOpacity(0.8) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            height: 40,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  layer.itemType.asString(),
                  style: AppStyles.typeTextNormal(color: AppColors.white),
                ),
                Spacer(),
                _buildReselectButton(layer),
                if (layer.controller != null)
                  IconButton(
                      onPressed: () => _showSoundSetting(layer),
                      icon: Icon(Icons.volume_up_rounded)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 27),
            child: RangeSliderWidget(
              max: controller.videoMaxRange,
              values: layer.range,
              isSelected: isSelected,
              onChanged: (range) => controller.onRangeChange(layer, range),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReselectButton(LayerEntity layer) => SizedBox.fromSize(
        size: const Size(100, 30),
        child: ButtonAction(
          verticalPadding: 0,
          isNoPadding: true,
          horizontalPadding: 0,
          color: AppColors.white,
          content: "labelReselect",
          action: () {
            controller
              ..onLayerChoose(layer)
              ..panelController.close();
            showBottomSheetDefault<dynamic>(
                    isScrollControlled: false,
                    context: Get.context!,
                    widget: _buildGridView(layer))
                .then((data) {
              if (data != null) {
                controller.onReselectLayer(data, layer);
              } else {
                controller.panelController.open();
              }
            });
          },
        ),
      );

  Widget _buildGridView(LayerEntity layer) {
    var data;
    if (layer.itemType == LayerType.ar) {
      if (controller.getAllAR.length == 0) {
        controller.callArAPI();
      }
      data = controller.getAllAR;
    } else if (layer.itemType == LayerType.effect) {
      if (controller.getAllEffect.length == 0) {
        controller.callEffectAPI();
      }
      data = controller.getAllEffect;
    } else {
      if (controller.getAllBackground.length == 0) {
        controller.callBackgroundAPI();
      }
      data = controller.getAllBackground;
    }
    return GetBuilder<EditVideoViewModel>(builder: (_) {
      return Stack(children: [
        Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding:
                EdgeInsets.fromLTRB(12, 0, 12, controller.isLoading ? 20 : 0),
            child: GridView.builder(
                padding: EdgeInsets.zero,
                controller: controller.scrollController,
                itemCount: data.isEmpty ? 3 : data.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 2 / 3.5,
                    crossAxisSpacing: 30),
                itemBuilder: (context, index) {
                  if (data.isEmpty)
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 30),
                      child: ShimmerCustom(
                          child: Container(
                              color: AppColors.black, height: 500, width: 300)),
                    );

                  if (layer.itemType == LayerType.ar) {
                    return _buildARItem(data[index], layer);
                  } else if (layer.itemType == LayerType.effect) {
                    return _buildEffectItem(data[index], layer);
                  } else {
                    return _buildBackgroundItem(data[index], layer);
                  }
                }),
          ),
        ),
        if (controller.isLoading)
          Align(
            alignment: Alignment.bottomCenter,
            child: ShimmerCustom(
              highlightColor: AppColors.blue,
              child: Container(
                  height: 5, width: double.infinity, color: AppColors.greyDark),
            ),
          )
      ]);
    });
  }

  Widget _buildARItem(MyAREntity ar, LayerEntity layer) {
    final url = ar.arCollectionDTO.thumbnail.isNotEmpty
        ? ar.arCollectionDTO.thumbnail
        : ar.arCollectionDTO.arUrl;
    final isSelected = controller.getLayers.any(
        (e) => e.itemType == LayerType.ar && e.itemId == ar.arCollectionDTO.id);
    return GestureDetector(
        onTap: () => isSelected ? null : Get.back(result: ar),
        child: _buildItem(url, isSelected));
  }

  Widget _buildEffectItem(EffectEntity effect, LayerEntity layer) {
    final url =
        effect.thumbnail.isNotEmpty ? effect.thumbnail : effect.effectUrl;
    final isSelected = controller.getLayers
        .any((e) => e.itemType == LayerType.effect && e.itemId == effect.id);
    return GestureDetector(
        onTap: () => isSelected ? null : Get.back(result: effect),
        child: _buildItem(url, isSelected));
  }

  Widget _buildBackgroundItem(BackgroundEntity background, LayerEntity layer) {
    final url = background.thumbnail.isNotEmpty
        ? background.thumbnail
        : background.backgroundUrl;
    final isSelected = controller.getLayers.any(
        (e) => e.itemType == LayerType.background && e.itemId == background.id);
    return GestureDetector(
        onTap: () => isSelected ? null : Get.back(result: background),
        child: _buildItem(url, isSelected));
  }

  Widget _buildItem(String url, bool isSelected) => Center(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 30),
          child: Stack(
            children: [
              url.isNotEmpty
                  ? Container(
                      padding: EdgeInsets.all(2),
                      color: Colors.transparent,
                      child: SizedBox.expand(
                        child: controller.isVideo(url)
                            ? LayerVideoWidget(
                                url: url,
                                loadingWidget: ShimmerCustom(
                                    child: Container(
                                        color: AppColors.black,
                                        height: 500,
                                        width: 300)),
                              )
                            : FittedBox(
                                fit: BoxFit.fill,
                                child: ImagePlaceholderWidget(
                                    url: url,
                                    placeholderHeight: 500,
                                    placeholderWidth: 300),
                              ),
                      ),
                    )
                  : Container(child: Icon(Icons.error_outline)),
              if (isSelected)
                Center(
                    child: Container(
                        decoration: BoxDecoration(
                            color: AppColors.grey, shape: BoxShape.circle),
                        child: Icon(Icons.done, color: AppColors.green)))
            ],
          ),
        ),
      );

  void _showSoundSetting(LayerEntity layer) => showDialog<bool?>(
      context: Get.context!,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) => Dialog(
          insetPadding: EdgeInsets.all(15),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Stack(
            children: [
              GestureDetector(onTap: Get.back),
              Row(
                children: [
                  Expanded(child: GestureDetector(onTap: Get.back)),
                  Container(
                    width: 50,
                    alignment: Alignment.centerRight,
                    height: heightScreen() / 3,
                    padding: const EdgeInsets.all(15),
                    margin: const EdgeInsets.only(top: 13),
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.6),
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: GetBuilder<EditVideoViewModel>(
                        builder: (context) => VolumeSliderWidget(
                              volume: layer.controller!.value.volume,
                              onChanged: (volume) =>
                                  controller.onVolumeChange(layer, volume),
                            )),
                  ),
                ],
              ),
            ],
          )));
}

Widget _buildFrame() {
  final size = 1.0;
  final color = AppColors.greyDark;
  return Stack(
    children: [
      Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Divider(height: size, color: color),
          Divider(height: size, color: color),
          Divider(height: size, color: color),
        ],
      ),
      Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          VerticalDivider(width: size, color: color),
          VerticalDivider(width: size, color: color),
          VerticalDivider(width: size, color: color),
        ],
      )
    ],
  );
}
