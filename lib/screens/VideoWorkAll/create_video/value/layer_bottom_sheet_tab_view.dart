import 'package:diamon_rose_app/collection_entity/background_entity.dart';
import 'package:diamon_rose_app/collection_entity/effect_entity.dart';
import 'package:diamon_rose_app/constants/styles/colors.dart';
import 'package:diamon_rose_app/enum/layer_type.dart';
import 'package:diamon_rose_app/my_ar_entity/my_ar_entity.dart';
import 'package:diamon_rose_app/screens/VideoWorkAll/create_video/create_video_view_model.dart';
import 'package:diamon_rose_app/widgets/image_placeholder_widget.dart';
import 'package:diamon_rose_app/widgets/layer_video_widget.dart';
import 'package:diamon_rose_app/widgets/shimmer_custom.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Widget LayerBottomSheetTabView(CreateVideoVideoModel controller) {
  return Expanded(
    child: TabBarView(
      controller: controller.tabController,
      children: <Widget>[
        _buildGridView(controller, LayerType.ar),
        _buildGridView(controller, LayerType.background),
        _buildGridView(controller, LayerType.effect),
      ],
    ),
  );
}

Widget _buildGridView(CreateVideoVideoModel controller, LayerType type) {
  late final layers;
  if (type == LayerType.ar) {
    layers = controller.getAllAR;
  } else if (type == LayerType.effect) {
    layers = controller.getAllEffect;
  } else {
    layers = controller.getAllBackground;
  }
  return GetBuilder<CreateVideoVideoModel>(builder: (context) {
    return Stack(children: [
      Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding:
              EdgeInsets.fromLTRB(12, 0, 12, controller.isLoading ? 20 : 0),
          child: GridView.builder(
              padding: EdgeInsets.zero,
              controller: controller.scrollController,
              itemCount: layers.isEmpty ? 3 : layers.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 2 / 3.5,
                  crossAxisSpacing: 30),
              itemBuilder: (context, index) {
                if (layers.isEmpty)
                  return Padding(
                    padding: EdgeInsets.only(bottom: 30),
                    child: ShimmerCustom(
                        child: Container(
                            color: AppColors.black, height: 500, width: 300)),
                  );

                final layer = layers[index];
                if (type == LayerType.ar) {
                  return _buildARItem(controller, layer, index);
                } else if (type == LayerType.effect) {
                  return _buildEffectItem(controller, layer, index);
                } else {
                  return _buildBackgroundItem(controller, layer, index);
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

Widget _buildARItem(
    CreateVideoVideoModel controller, MyAREntity ar, int index) {
  final url = ar.arCollectionDTO.thumbnail.isNotEmpty
      ? ar.arCollectionDTO.thumbnail
      : ar.arCollectionDTO.arUrl;

  int? number = null;
  if (ar.selected) {
    number =
        controller.getARsSelected.indexWhere((e) => e.itemId == ar.myARDTO.id) +
            1;
  }
  return GestureDetector(
      onTap: () => controller.onTapAR(index),
      child: _buildItem(controller, url, number));
}

Widget _buildEffectItem(
    CreateVideoVideoModel controller, EffectEntity effect, int index) {
  final url = effect.thumbnail.isNotEmpty ? effect.thumbnail : effect.effectUrl;
  int? number = null;
  if (effect.selected) {
    number =
        controller.getEffectsSelected.indexWhere((e) => e.itemId == effect.id) +
            1;
  }
  return GestureDetector(
      onTap: () => controller.onTapEffect(index),
      child: _buildItem(controller, url, number));
}

Widget _buildBackgroundItem(
    CreateVideoVideoModel controller, BackgroundEntity background, int index) {
  final url = background.thumbnail.isNotEmpty
      ? background.thumbnail
      : background.backgroundUrl;
  int? number = null;
  if (background.selected) {
    number = controller.getBackgroundsSelected
            .indexWhere((e) => e.itemId == background.id) +
        1;
  }
  return GestureDetector(
      onTap: () => controller.onTapBackground(index),
      child: _buildItem(controller, url, number));
}

Widget _buildItem(CreateVideoVideoModel controller, String url, int? number) =>
    Center(
      child: Padding(
        padding: EdgeInsets.only(bottom: 30),
        child: Stack(
          children: [
            url.isNotEmpty
                ? Container(
                    padding: EdgeInsets.all(2),
                    color:
                        number == null ? Colors.transparent : AppColors.purple,
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
            if (number != null)
              Center(
                child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                        color: AppColors.greyDark, shape: BoxShape.circle),
                    child: Text(number.toString())),
              )
          ],
        ),
      ),
    );
