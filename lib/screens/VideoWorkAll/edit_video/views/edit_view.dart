import 'package:diamon_rose_app/constants/styles/colors.dart';
import 'package:diamon_rose_app/constants/styles/style.dart';
import 'package:diamon_rose_app/enum/layer_type.dart';
import 'package:diamon_rose_app/layer_entity/layer_entity.dart';
import 'package:diamon_rose_app/screens/VideoWorkAll/edit_video/edit_video_view_model.dart';
import 'package:diamon_rose_app/widgets/image_placeholder_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

class EditView extends StatelessWidget {
  const EditView(
      {Key? key, required this.controller, this.isPreviewPage = true})
      : super(key: key);
  final bool isPreviewPage;
  final EditVideoViewModel controller;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: GetX<EditVideoViewModel>(builder: (_) {
          return Stack(
              children: controller.getLayers
                  .map((value) => _buildWidgetItem(context, value))
                  .toList());
        }),
      ),
    );
  }

  Widget _buildWidgetItem(BuildContext context, LayerEntity layer) {
    /// Preview view
    if (isPreviewPage) {
      final currentTime = controller.getCurrentTime.toDouble();
      final isShowing =
          (layer.range.start - controller.getVideoRange.start) <= currentTime &&
              (layer.range.end - controller.getVideoRange.start) >= currentTime;
      return Visibility(
        visible: isShowing,
        child: _buildWidgetDetail(layer),
      );
    }

    /// Position view
    if (layer.itemType.isBackground) {
      return _buildWidgetDetail(layer);
    }

    return GestureDetector(
      onLongPress: () {
        controller.onLayerChoose(layer);
        _showChangeIndexOption(context, layer);
      },
      onScaleStart: (details) => controller.onLayerScaleStart(details, layer),
      onScaleUpdate: (details) => controller.onLayerScaleUpdate(details, layer),
      onScaleEnd: controller.onLayerScaleEnd,
      child: _buildWidgetDetail(layer),
    );
  }

  Widget _buildWidgetDetail(LayerEntity layer) => Stack(
        children: [
          Positioned(
            left: layer.xcoordinates * controller.getScreenWidth,
            top: layer.ycoordinates * controller.getScreenHeight,
            child: Transform.scale(
              scale: layer.scale,
              child: Transform.rotate(
                angle: layer.radian,
                child: Listener(
                  child: Container(
                      width: layer.width,
                      height: layer.height,
                      child: controller.isVideo(layer.itemUrl)
                          ? SizedBox.expand(
                              child: FittedBox(
                                fit: BoxFit.fill,
                                child: SizedBox(
                                    width: layer.width,
                                    height: layer.height,
                                    child: ClipRRect(
                                        borderRadius: BorderRadius.circular(0),
                                        child: VideoPlayer(layer.controller!))),
                              ),
                            )
                          : ImagePlaceholderWidget(url: layer.itemUrl)),
                ),
              ),
            ),
          )
        ],
      );

  Future _showChangeIndexOption(BuildContext context, LayerEntity layer) async {
    final canRotate = layer.itemType == LayerType.ar;
    final canUp = layer != controller.getLayers.last;
    final canDown =
        controller.getLayers.indexOf(layer) > controller.getBackgrounds.length;
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildChangeIndexItem("bring up menu",
                textStyle: AppStyles.typeTextNormal(
                    color: canUp ? AppColors.blue : AppColors.grey),
                onPressed: () {
              if (canUp)
                controller.onLayerIndexUpdate(layer: layer, isUpFront: true);
            }),
            Divider(height: 1, color: AppColors.greyDark),
            _buildChangeIndexItem("push down menu",
                textStyle: AppStyles.typeTextNormal(
                    color: canDown ? AppColors.red : AppColors.grey),
                onPressed: () {
              if (canDown)
                controller.onLayerIndexUpdate(layer: layer, isUpFront: false);
            }),
            Divider(height: 1, color: AppColors.greyDark),
            _buildChangeIndexItem("Rotate menu",
                textStyle: AppStyles.typeTextNormal(
                    color: canRotate ? AppColors.black : AppColors.grey),
                onPressed: () {
              if (canRotate) {
                controller.onArRotate(layer);
              }
            }),
          ],
        ),
      ),
    );
  }

  ListTile _buildChangeIndexItem(String label,
          {TextStyle? textStyle, Null Function()? onPressed}) =>
      ListTile(
        horizontalTitleGap: 0,
        onTap: onPressed,
        title: Text(
          label,
          style: textStyle ?? AppStyles.typeTextNormal(),
          textAlign: TextAlign.start,
        ),
      );
}
