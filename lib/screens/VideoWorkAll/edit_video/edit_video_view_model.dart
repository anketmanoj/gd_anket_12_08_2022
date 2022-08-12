import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui';

import 'package:diamon_rose_app/Navigation/page.dart';
import 'package:diamon_rose_app/collection_entity/background_entity.dart';
import 'package:diamon_rose_app/collection_entity/effect_entity.dart';
import 'package:diamon_rose_app/enum/edit_video_type.dart';
import 'package:diamon_rose_app/enum/layer_type.dart';
import 'package:diamon_rose_app/enum/loading_state.dart';
import 'package:diamon_rose_app/enum/status_video_type.dart';
import 'package:diamon_rose_app/layer_entity/layer_entity.dart';
import 'package:diamon_rose_app/my_ar_entity/ar_dto_entity.dart';
import 'package:diamon_rose_app/my_ar_entity/collection_dto_entity.dart';
import 'package:diamon_rose_app/my_ar_entity/my_ar_entity.dart';
import 'package:diamon_rose_app/providers/ffmpegProviders.dart';
import 'package:diamon_rose_app/screens/PostPage/previewVideo.dart';
import 'package:diamon_rose_app/screens/VideoWorkAll/create_wk_video_request/create_wk_video_request.dart';
import 'package:diamon_rose_app/screens/VideoWorkAll/create_wk_video_request/layer_item_request.dart';
import 'package:diamon_rose_app/screens/VideoWorkAll/edit_video/views/page_index.dart';
import 'package:diamon_rose_app/screens/VideoWorkAll/wk_video_entity/draft_video_item_entity.dart';
import 'package:diamon_rose_app/screens/VideoWorkAll/wk_video_entity/my_draft_video_entity.dart';
import 'package:diamon_rose_app/screens/VideoWorkAll/wk_video_repository/wk_video_repository.dart';
import 'package:diamon_rose_app/widgets/utils.dart';
import 'package:diamon_rose_app/widgets/validate_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:video_player/video_player.dart';

class EditVideoViewModel extends GetxController with WidgetsBindingObserver {
  late final double _screenHeight;
  late final double _screenWidth;
  double _mainHeight = 0;
  double _mainWidth = 0;
  double _mainRatio = 1;
  double _previousMainX = 0;
  double _previousMainY = 0;
  double _previousMainHeight = 0;
  double _previousMainWidth = 0;
  Rx<LoadingState> _loadingState = LoadingState.init.obs;
  PageController pageController = PageController();
  final ScrollController scrollController = ScrollController();
  PanelController panelController = PanelController();
  RxInt _currentTime = 0.obs;
  RxBool _isPreviewPlaying = false.obs;
  RxBool _enablePageViewScroll = true.obs;
  Timer? _timer;
  Rx<List<LayerEntity>> _layerList = Rx([]);
  Rx<RangeValues> _videoRange = Rx(RangeValues(0, 60));
  double videoMaxRange = 60;
  Offset _initPos = Offset(0, 0);
  Offset _currentPos = Offset(0, 0);
  double _currentScale = 0;
  double _currentRotation = 0;
  Rx<List<LayerEntity>> _editingHistory = Rx([]);
  LayerEntity? _layerSelected;
  bool _changing = false;
  final videoCapController = Rx(TextEditingController());
  final videoCapFocus = FocusNode();
  int _initVideoCount = 0;
  Rx<List<MyAREntity?>> _allAr = Rx([]);
  Rx<List<BackgroundEntity?>> _allBackground = Rx([]);
  Rx<List<EffectEntity?>> _allEffect = Rx([]);
  final _pageSize = 10;
  int _arPage = 0;
  int _backgroundPage = 0;
  int _effectPage = 0;
  int? totalArRecord;
  int? totalEffectRecord;
  int? totalBackgroundRecord;
  int? _videoId;
  bool isNewVideo = false;
  bool isGoBack = false;

  double get getScreenHeight => _screenHeight;

  double get getScreenWidth => _screenWidth;

  double get verticalPadding => (_screenHeight - _mainHeight) / 2;

  double get horizontalPadding => (_screenWidth - _mainWidth) / 2;

  LoadingState get loadingState => _loadingState.value;

  bool get isLoading => loadingState == LoadingState.loading;

  bool get isInit => loadingState == LoadingState.init;

  List<LayerEntity> get getLayers => _layerList.value;

  List<LayerEntity> get getBackgrounds => _layerList.value
      .where((e) => e.itemType == LayerType.background)
      .toList();

  LayerEntity? get getLayerSelected => _layerSelected;

  List<MyAREntity?> get getAllAR => _allAr.value;

  List<BackgroundEntity?> get getAllBackground => _allBackground.value;

  List<EffectEntity?> get getAllEffect => _allEffect.value;

  bool get isCanUndo => _editingHistory.value.isNotEmpty;

  bool get enablePageViewScroll => _enablePageViewScroll.value;

  RangeValues get getVideoRange => _videoRange.value;

  int get getCurrentTime => _currentTime.value;

  bool get isPreviewPlaying => _isPreviewPlaying.value;

  double get getVideoDuration => _videoRange.value.end;

  String get getProgressString {
    final progressSeconds =
        getCurrentTime < 10 ? '0$getCurrentTime' : '$getCurrentTime';
    return getCurrentTime == 60 ? '01:00' : '00:$progressSeconds';
  }

  @override
  Future<void> onInit() async {
    await showLoading();
    update();
    _screenHeight = (window.physicalSize.height - window.padding.top) /
        window.devicePixelRatio;
    _screenWidth = window.physicalSize.width / window.devicePixelRatio;
    _onUpdateMainSize(width: _screenWidth, height: _screenHeight);
    scrollController.addListener(_onLoadMore);
    await _onInitLayers();
    super.onInit();
  }

  bool isVideo(String value) {
    // return value.toLowerCase().contains(RegExp('mp4|mov'));
    if (value.toLowerCase().contains(".mp4")) {
      print("its a video");
    } else {
      print("its not a video");
    }
    return value.toLowerCase().contains(".mp4");
  }

  Future<void> onPanelOpened() async {
    _enablePageViewScroll.value = false;
    update();
  }

  Future<void> onPanelClosed() async {
    _enablePageViewScroll.value = true;
    update();
  }

  void onLayerChoose(LayerEntity layer) {
    _layerSelected = layer;
    update();
  }

  void onVideoCapChange(String captionText) {
    if (captionText.trim().isEmpty) {
      videoCapController.value.clear();
    }
    videoCapController.refresh();
  }

  bool onCaptionValidate() {
    return !ValidateUtils.isNullEmptyOrWhitespace(
        videoCapController.value.text);
  }

  void onVideoCapClear() => videoCapController
    ..value.clear()
    ..refresh();

  Future<void> _onLoadMore() async {
    if (!scrollController.hasClients ||
        _loadingState.value == LoadingState.loading) {
      return;
    }
    final thresholdReached = scrollController.position.extentAfter == 0;
    if (thresholdReached) {
      if (_layerSelected?.itemType == LayerType.ar &&
          totalArRecord != null &&
          getAllAR.length < totalArRecord!) {
        _arPage++;
        callArAPI();
      } else if (_layerSelected?.itemType == LayerType.background &&
          totalBackgroundRecord != null &&
          getAllBackground.length < totalBackgroundRecord!) {
        _backgroundPage++;
        callBackgroundAPI();
      } else if (_layerSelected?.itemType == LayerType.effect &&
          totalEffectRecord != null &&
          getAllEffect.length < totalEffectRecord!) {
        _effectPage++;
        callEffectAPI();
      }
    }
  }

  Future<void> onLayerUndo() async {
    if (isCanUndo) {
      await showLoading();
      final previous = _editingHistory.value.first;
      final index = getLayers.indexWhere((e) => e.key == previous.key);
      if (getLayers[index].position > previous.position) {
        /// Undo position
        getLayers[index].position--;
        getLayers[index - 1].position++;
        getLayers.insert(index - 1, getLayers.removeAt(index));
      } else if (getLayers[index].position < previous.position) {
        /// Undo position
        getLayers[index].position++;
        getLayers[index + 1].position--;
        getLayers.insert(index, getLayers.removeAt(index + 1));
      } else if (getLayers[index].itemId != previous.itemId &&
          getLayers[index].itemType == previous.itemType) {
        /// Undo layer reselected
        await _onUpdateLayerInfo(previous, index,
            newId: previous.itemId, newUrl: previous.itemUrl);
        if (index == 0 && getLayers[index].itemType.isBackground) {
          await _onUpdateAllLayerInfo();
        }
      } else {
        /// Undo coordinates
        getLayers[index] =
            previous.copyWith(controller: getLayers[index].controller);
      }
      _editingHistory
        ..value.removeAt(0)
        ..refresh();
      _layerList.refresh();
      await dismissLoading();
    }
  }

  Future<void> onReselectLayer(dynamic value, LayerEntity layer) async {
    await showLoading();
    final index = getLayers.indexOf(layer);
    var url = '';
    var id = -1;
    final isAr = layer.itemType.isAR;
    final isEffect = layer.itemType.isEffect;
    final isBackground = layer.itemType.isBackground;
    if (isAr) {
      value as MyAREntity;
      url = value.arCollectionDTO.arUrl;
      id = value.arCollectionDTO.id;
    } else if (isEffect) {
      value as EffectEntity;
      url = value.effectUrl;
      id = value.id;
    } else {
      value as BackgroundEntity;
      url = value.backgroundUrl;
      id = value.id;
    }
    _editingHistory.value.insert(0, layer.copyWith());
    await _onUpdateLayerInfo(layer, index, newId: id, newUrl: url);
    _layerSelected = getLayers[index];
    if (index == 0 && isBackground) {
      await _onUpdateAllLayerInfo();
    }
    _layerList.refresh();
    update();
    await dismissLoading();
  }

  void _onUpdateMainSize({required double width, required double height}) {
    _mainHeight = height;
    _mainWidth = width;
    _mainRatio = _mainWidth / _mainHeight;
  }

  Future<void> _onUpdateAllLayerInfo() async {
    for (int i = 1; i < getLayers.length; i++) {
      await _onUpdateLayerInfo(getLayers[i], i);
    }
  }

  Future<void> _onUpdateLayerInfo(LayerEntity layer, int index,
      {String? newUrl, int? newId}) async {
    final isAr = layer.itemType.isAR;
    final isEffect = layer.itemType.isEffect;
    final isBackground = layer.itemType.isBackground;
    var ratio = layer.width / layer.height;
    var duration = layer.duration;
    final width;
    final height;
    double x = layer.xcoordinates;
    double y = layer.ycoordinates;
    var controller = layer.controller;
    final isFrameChange;

    if (newUrl != null) {
      if (isVideo(newUrl)) {
        controller = await getVideoController(newUrl, awaitInit: true);
        ratio = controller!.value.aspectRatio;
        duration = controller.value.duration.inSeconds.toDouble();
      } else {
        ratio = await getImageRatio(newUrl);
        duration = videoMaxRange;
      }
    }

    isFrameChange = index == 0 && isBackground;

    if (isFrameChange) {
      _onUpdateMainSize(width: _screenWidth, height: _screenHeight);
      _previousMainX = getLayers.first.xcoordinates;
      _previousMainY = getLayers.first.ycoordinates;
      _previousMainWidth = getLayers.first.width;
      _previousMainHeight = getLayers.first.height;
    }

    if (_mainRatio < ratio) {
      /// Horizontal video
      width = newUrl == null
          ? layer.width *
              ((_mainHeight * _mainWidth) /
                  (_previousMainHeight * _previousMainWidth))
          : _mainWidth *
              (isAr
                  ? 2 / 3
                  : isEffect
                      ? 2 / 5
                      : 1);
      height = width / ratio;
    } else {
      /// vertical video
      height = newUrl == null
          ? layer.height *
              ((_mainHeight * _mainWidth) /
                  (_previousMainHeight * _previousMainWidth))
          : _mainHeight *
              (isAr
                  ? 2 / 3
                  : isEffect
                      ? 2 / 5
                      : 1);
      width = height * ratio;
    }
    if (isFrameChange) {
      _onUpdateMainSize(width: width, height: height);
    }

    if (newUrl == null || isBackground) {
      final position = _getLayerPosition(width, height, layer);
      x = position['x'];
      y = position['y'];
    }

    if (newUrl != null && (layer.controller?.value.isInitialized ?? false)) {
      await layer.controller!.dispose();
    }

    getLayers[index] = layer.copyWith(
      itemId: newId,
      url: newUrl,
      height: height,
      width: width,
      xcoordinates: x,
      ycoordinates: y,
      controller: controller,
      duration: duration,
      range: RangeValues(0, duration),
    );
  }

  Map _getLayerPosition(double width, double height, LayerEntity layer) {
    final bg = getLayers.first.itemType.isBackground ? getLayers.first : null;
    final position = {"x": layer.xcoordinates, "y": layer.ycoordinates};
    if (layer.itemType.isBackground) {
      position['x'] = ((_screenWidth - width) / 2) / _screenWidth;
      position['y'] = ((_screenHeight - height) / 2) / _screenHeight;
    } else {
      var paddingTop;
      var newPaddingTop;
      var paddingLeft;
      var newPaddingLeft;

      if (_previousMainWidth > _mainWidth) {
        paddingTop = (layer.ycoordinates - _previousMainY) * _screenHeight;
        newPaddingTop = paddingTop * _mainHeight / _previousMainHeight;

        paddingLeft = (layer.xcoordinates - _previousMainX) * _screenWidth;
        newPaddingLeft = paddingLeft * _mainWidth / _previousMainWidth;
      } else {
        paddingTop = (layer.ycoordinates - _previousMainY) * _screenHeight;
        newPaddingTop = paddingTop * _mainHeight / _previousMainHeight;

        paddingLeft = (layer.xcoordinates - _previousMainX) * _screenWidth;
        newPaddingLeft = paddingLeft * _mainWidth / _previousMainWidth;
      }
      position['x'] = (bg?.xcoordinates ?? 0) + (newPaddingLeft / _screenWidth);
      position['y'] = (bg?.ycoordinates ?? 0) + (newPaddingTop / _screenHeight);
    }
    return position;
  }

  Future<void> onLayerIndexUpdate(
      {required LayerEntity layer, required bool isUpFront}) async {
    _editingHistory.value.insert(0, layer.copyWith());
    final index = getLayers.indexOf(layer);
    if (isUpFront) {
      getLayers[index].position++;
      getLayers[index + 1].position--;
      getLayers.insert(index, getLayers.removeAt(index + 1));
    } else {
      getLayers[index].position--;
      getLayers[index - 1].position++;
      getLayers.insert(index - 1, getLayers.removeAt(index));
    }
    _layerList.refresh();
    Get.back();
  }

  Future<void> onArRotate(LayerEntity layer) async {
    _editingHistory.value.insert(0, layer.copyWith());
    layer.radian = layer.radian + math.pi / 2;
    _layerList.refresh();
    Get.back();
  }

  Future<void> onLayerScaleUpdate(
      ScaleUpdateDetails details, LayerEntity layer) async {
    final delta = details.focalPoint - _initPos;
    final x = (delta.dx / _screenWidth) + _currentPos.dx;
    final y = (delta.dy / _screenHeight) + _currentPos.dy;
    layer
      ..xcoordinates = x
      ..ycoordinates = y
      ..scale = details.scale * _currentScale;
    if (layer.itemType == LayerType.ar)
      layer.radian = details.rotation + _currentRotation;
    _layerList.refresh();
  }

  Future<void> onLayerScaleEnd(ScaleEndDetails details) async {
    if (details.pointerCount == 0) {
      _changing = false;
    }
  }

  Future<void> onLayerScaleStart(
      ScaleStartDetails details, LayerEntity value) async {
    _initPos = details.focalPoint;
    _currentPos = Offset(value.xcoordinates, value.ycoordinates);
    _currentScale = value.scale;
    _currentRotation = value.radian;
    onLayerChoose(value);
    if (!_changing) {
      _editingHistory.value.insert(0, value.copyWith());
      _changing = true;
    }
    update();
  }

  void onRangeChange(LayerEntity layer, RangeValues range) {
    if (range.end - range.start > layer.duration) {
      return;
    }
    layer.range = range;
    update();
  }

  void onPageChange(int page) {
    if (getCurrentTime > 0) {
      _timer?.cancel();
      _currentTime.value = 0;
      getLayers.forEach((e) => e.controller
        ?..pause()
        ..seekTo(Duration.zero));
      _isPreviewPlaying.value = false;
    }
    update();
  }

  void onVideoRangeChange(RangeValues value) {
    _videoRange.value = RangeValues(0, value.end);
    update();
  }

  void startPreview() {
    _isPreviewPlaying.value = !_isPreviewPlaying.value;
    update();
    if (isPreviewPlaying) {
      if (_currentTime.value > 0) {
        getLayers.forEach((e) {
          if (e.range.start <= _currentTime.value &&
              e.range.end >= _currentTime.value) {
            e.controller?.play();
          }
        });
      }
      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        if (_currentTime.value >=
            (_videoRange.value.end - _videoRange.value.start).toInt()) {
          _timer?.cancel();
          getLayers.forEach((e) => e.controller
            ?..pause()
            ..seekTo(Duration.zero));
          _currentTime.value = 0;
          _isPreviewPlaying.value = !_isPreviewPlaying.value;
          return;
        }
        getLayers.forEach((e) {
          if (e.range.start == _currentTime.value) {
            e.controller?.play();
          } else if (e.range.end == _currentTime.value) {
            e.controller
              ?..pause()
              ..seekTo(Duration.zero);
          }
        });
        _currentTime.value++;
        _layerList.refresh();
      });
    } else {
      _timer?.cancel();
      getLayers.forEach((e) => e.controller?.pause());
    }
  }

  void onVolumeChange(LayerEntity layer, double value) {
    layer.controller!.setVolume(value);
    update();
  }

  Future<void> _onInitLayers() async {
    final arg = Get.arguments;
    isNewVideo = arg['TYPE'] == EditVideoType.newVideo;
    if (isNewVideo) {
      final List<LayerEntity> layers = arg['DATA'];
      await _onInitNewVideo(layers);
    } else {
      // final MyDraftVideoEntity draftVideo = arg['DATA'];
      // _onInitDraftVideo(draftVideo);
    }
  }

  Future<void> _onInitNewVideo(List<LayerEntity> layers) async {
    final firstLayer = layers.first;
    if (firstLayer.itemType.isBackground) {
      _onUpdateMainSize(width: firstLayer.width, height: firstLayer.height);
    }
    layers.asMap().forEach((index, layer) {
      _layerList.value.add(layer.copyWith(
          key: '$index${layer.itemType.asString()}',
          position: index,
          controller: layer.controller));
    });
    _loadingState.value = LoadingState.none;
    _layerList.refresh();
    update();
    await dismissLoading();
  }

  void _onInitDraftVideo(MyDraftVideoEntity draftVideo) {
    _videoId = draftVideo.id;
    videoCapController.value.text = draftVideo.wkVideoName;
    _videoRange.value = RangeValues(0, draftVideo.duration.toDouble());
    final fistLayerInfo = draftVideo.listLayer.first.layerItem;
    var residualRatio = 1.0 / window.devicePixelRatio;
    if (fistLayerInfo.itemType.isBackground) {
      final ratio = fistLayerInfo.width / fistLayerInfo.height;
      final width;
      final height;
      if (_mainRatio < ratio) {
        /// Horizontal video
        width = _mainWidth;
        height = width / ratio;
        residualRatio = _mainWidth / fistLayerInfo.width;
      } else {
        /// vertical video
        height = _mainHeight;
        width = height * ratio;
        residualRatio = _mainHeight / fistLayerInfo.height;
      }
      _onUpdateMainSize(width: width, height: height);
    }

    final residualW = (_screenWidth - _mainWidth) / 2;
    final residualH = (_screenHeight - _mainHeight) / 2;
    draftVideo.listLayer.forEach((item) async {
      await _initLayer(item, draftVideo.listLayer.length, residualW, residualH,
          residualRatio);
    });
  }

  Future<void> _initLayer(DraftVideoItemEntity item, int length,
      double residualW, double residualH, double residualRatio) async {
    VideoPlayerController? controller;
    if (isVideo(item.layerItemCusDTO.itemUrl)) {
      controller = await getVideoController(item.layerItemCusDTO.itemUrl,
          awaitInit: true);
      if (controller == null) {
        return;
      }
      await controller.setVolume(item.layerItem.volume / 100);
    }
    final layer = LayerEntity(
      key: item.layerItem.id.toString(),
      itemId: item.layerItem.itemId,
      itemUrl: item.layerItemCusDTO.itemUrl,
      width: item.layerItem.width * residualRatio,
      height: item.layerItem.height * residualRatio,
      radian: item.layerItem.radian,
      position: item.layerItem.position,
      xcoordinates:
          (item.layerItem.xcoordinates * _mainWidth + residualW) / _screenWidth,
      ycoordinates: (item.layerItem.ycoordinates * _mainHeight + residualH) /
          _screenHeight,
      volume: item.layerItem.volume / 100,
      itemType: item.layerItem.itemType,
      startTime: item.layerItem.startTime.toDouble(),
      endTime: item.layerItem.endTime.toDouble(),
      range: RangeValues(item.layerItem.startTime.toDouble(),
          item.layerItem.endTime.toDouble()),
      controller: controller,
      duration:
          controller?.value.duration.inSeconds.toDouble() ?? videoMaxRange,
    );
    _layerList.value.add(layer);
    _initVideoCount++;
    if (length == _initVideoCount) {
      _layerList.value.sort((a, b) => a.position.compareTo(b.position));
      _loadingState.value = LoadingState.none;
      _layerList.refresh();
      update();
      await dismissLoading();
    }
  }

  Future<VideoPlayerController?> getVideoController(String url,
      {bool awaitInit = false, bool mixWithOthers = true}) async {
    try {
      final controller = VideoPlayerController.network(url,
          videoPlayerOptions: VideoPlayerOptions(mixWithOthers: mixWithOthers));
      awaitInit
          ? await controller.initialize()
          : unawaited(controller.initialize());
      return controller;
    } on PlatformException catch (e) {
      debugPrint('${e.message}');
      await dismissLoading();
      await showErrorConfirmDialog(
          context: Get.context!, errors: [e.message.toString()]);
      return null;
    } on Exception catch (e) {
      debugPrint('$e');
      await dismissLoading();
      await showErrorConfirmDialog(
          context: Get.context!, errors: [e.toString()]);
      return null;
    }
  }

  Future<void> onRequestMergeVideo(
      StatusVideoType mergeStatus, BuildContext context) async {
    final List<RequestLayerItemModel> layerItemsModel = [];
    LayerEntity bg = LayerEntity(height: _screenHeight, width: _screenWidth);
    if (getLayers.first.itemType.isBackground) {
      bg = getLayers.first;
    }
    for (var i = 0; i < getLayers.length; i++) {
      final layer = getLayers[i];
      final w = (layer.width * layer.scale) * window.devicePixelRatio;
      final h = (layer.height * layer.scale) * window.devicePixelRatio;
      final x = ((layer.xcoordinates - bg.xcoordinates) * _screenWidth -
              (layer.scale - 1) * layer.width / 2) /
          bg.width;
      final y = ((layer.ycoordinates - bg.ycoordinates) * _screenHeight -
              (layer.scale - 1) * layer.height / 2) /
          bg.height;
      layerItemsModel.add(RequestLayerItemModel(
        itemId: layer.itemId,
        itemType: layer.itemType,
        endTime: layer.range.end.toInt(),
        startTime: layer.range.start.toInt(),
        position: layer.position,
        radian: layer.radian,
        volume: ((layer.controller?.value.volume ?? 0) * 100).toInt(),
        height: h,
        width: w,
        xcoordinates: x,
        ycoordinates: y,
      ));

      // print(
      //     "layer = ${getLayers[i].name} | position = ${getLayers[i].position} | x = $x | y = $y | w = $w | h = $h");
    }
    final length = _videoRange.value.end - _videoRange.value.start;

    // print coordinates

    final RequestCreateWkVideoModel requestCreateWkVideo =
        RequestCreateWkVideoModel(
            canvasWidth: _mainWidth * window.devicePixelRatio,
            canvasHeight: _mainHeight * window.devicePixelRatio,
            duration: length.toInt(),
            titleVideo: videoCapController.value.text.trim(),
            layerItems: layerItemsModel,
            status: mergeStatus);

    // Getting all the layer info, now to pass to ffmpeg
    print(requestCreateWkVideo.layerItems);

//     await Provider.of<FFmpegProvider>(context, listen: false)
//         .videoMerger(
//             context: context,
//             videoArLayer: getLayers[1].itemUrl,
//             videoBgLayer: getLayers[0].itemUrl,
//             endTime: "00:00:30",
//             canvasWidth: requestCreateWkVideo.canvasWidth!.ceil().toString(),
//             canvasHeight: requestCreateWkVideo.canvasHeight!.ceil().toString(),
//             bgWidth: requestCreateWkVideo.layerItems![0].width.toString(),
//             bgHeight: requestCreateWkVideo.layerItems![0].height.toString(),
//             bgXCoordinate:
//                 requestCreateWkVideo.layerItems![0].xcoordinates.toString(),
//             bgYCoordinate:
//                 requestCreateWkVideo.layerItems![0].ycoordinates.toString(),
//             bgStartTime:
//                 requestCreateWkVideo.layerItems![0].startTime.toString(),
//             bgEndTime: requestCreateWkVideo.layerItems![0].endTime.toString(),
//             arWidth: requestCreateWkVideo.layerItems![1].width.toString(),
//             arHeight: requestCreateWkVideo.layerItems![1].height.toString(),
//             arXCoordinate:
//                 requestCreateWkVideo.layerItems![1].xcoordinates.toString(),
//             arYCoordinate:
//                 requestCreateWkVideo.layerItems![1].ycoordinates.toString(),
//             arStartTime:
//                 requestCreateWkVideo.layerItems![1].startTime.toString(),
//             arEndTime: requestCreateWkVideo.layerItems![1].endTime.toString())
//         .then((value) {
// // ignore: unawaited_futures
//       // Navigator.push(
//       //     context,
//       //     PageTransition(
//       //         child: PreviewVideoScreen(
//       //             thumbnailFile:
//       //                 Provider.of<FFmpegProvider>(context, listen: false)
//       //                     .thumbnailFile!,
//       //             videoFile: File(
//       //                 Provider.of<FFmpegProvider>(context, listen: false)
//       //                     .outputFile!
//       //                     .path),
//       //             videoPlayerController:
//       //                 Provider.of<FFmpegProvider>(context, listen: false)
//       //                     .controller!),
//       //         type: PageTransitionType.fade));
//     });

    // VideoCreateRepository.instance.requestCreateWkVideo(
    //   videoId: isNewVideo ? '' : '/${_videoId}',
    //   requestCreateWkVideo: requestCreateWkVideo,
    //   onStart: showLoading,
    //   onSuccess: (data) async {
    //     videoCapController.value.clear();
    //     await dismissLoading();
    //     if (mergeStatus == StatusVideoType.completed) {
    //       final videoId = data['item']['videoId'];

    //       /// is update draft video
    //       if (!isNewVideo) {
    //         await Get.toNamed(ROUTER_VIDEO_SETTINGS, arguments: [videoId]);

    //         /// call back to refresh draft video list in [MyDraftVideoScreen]
    //         Get.back(result: true);
    //       } else {
    //         await Get.offAndToNamed(ROUTER_VIDEO_SETTINGS,
    //             arguments: [videoId]);
    //       }
    //       return;
    //     }
    //     if (mergeStatus == StatusVideoType.draft && isNewVideo) {
    //       await Get.offAndToNamed(ROUTER_MY_DRAFT_VIDEO);
    //     } else {
    //       Get.back(result: true);
    //     }
    //   },
    //   onError: (e) {
    //     showErrorConfirmDialog(context: Get.context!, errors: e);
    //     dismissLoading();
    //   },
    // );
  }

  void callArAPI() {
    _allAr.value.add(
      MyAREntity(
        myARDTO: ARDTOEntity(
          id: 1,
          createBy: 1,
          arCollectionId: 1,
          userId: 1,
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
        ),
        arCollectionDTO: CollectionDTOEntity(
          createBy: 1,
          id: 1,
          arName: "test",
          arType: 1,
          arUrl:
              "https://www.learningcontainer.com/wp-content/uploads/2020/05/sample-mp4-file.mp4",
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
        ),
      ),
    );
    totalArRecord = _allAr.value.length;
    _allAr.refresh();
    _loadingState.value = LoadingState.none;
    update();
    // ARRepository.instance.getARList(
    //   queryParameters: GetARParamEntity(size: _pageSize, page: _arPage),
    //   onStart: () {
    //     _loadingState.value = LoadingState.loading;
    //     update();
    //   },
    //   onSuccess: (response) async {
    //     _allAr.value.addAll(response.items);
    //     totalArRecord = response.totalElements;
    //     _allAr.refresh();
    //     _loadingState.value = LoadingState.none;
    //     update();
    //   },
    //   onError: (error) {
    //     showSnackBar(
    //         message: error.join("\n"), snackBarType: SnackBarType.danger);
    //     _loadingState.value = LoadingState.none;
    //     update();
    //   },
    // );
  }

  void callEffectAPI() {
    // MyCollectionRepository.instance.getEffect(
    //   requestParam: RequestGetArModel(size: _pageSize, page: _effectPage),
    //   onStart: () {
    //     _loadingState.value = LoadingState.loading;
    //     update();
    //   },
    //   onSuccess: (response) async {
    //     _allEffect.value.addAll(response.items);
    //     totalEffectRecord = response.totalElements;
    //     _allEffect.refresh();
    //     _loadingState.value = LoadingState.none;
    //     update();
    //   },
    //   onError: (error) {
    //     showSnackBar(
    //         message: error.join("\n"), snackBarType: SnackBarType.danger);
    //     _loadingState.value = LoadingState.none;
    //     update();
    //   },
    // );
  }

  void callBackgroundAPI() {
    _allBackground.value.add(BackgroundEntity(
      id: 1,
      backgroundDesc: "test background",
      backgroundUrl:
          "https://cdn.pixabay.com/photo/2015/04/23/22/00/tree-736885__480.jpg",
      createBy: 1,
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
      selected: false,
      thumbnail:
          "https://cdn.pixabay.com/photo/2015/04/23/22/00/tree-736885__480.jpg",
      updateBy: 1,
      downloadKey: "test",
    ));
    totalBackgroundRecord = _allBackground.value.length;
    _allBackground.refresh();
    _loadingState.value = LoadingState.none;
    update();
    // MyCollectionRepository.instance.getBackground(
    //   requestParam: RequestGetArModel(size: _pageSize, page: _backgroundPage),
    //   onStart: () {
    //     _loadingState.value = LoadingState.loading;
    //     update();
    //   },
    //   onSuccess: (response) async {
    //     _allBackground.value.addAll(response.items);
    //     totalBackgroundRecord = response.totalElements;
    //     _allBackground.refresh();
    //     _loadingState.value = LoadingState.none;
    //     update();
    //   },
    //   onError: (error) {
    //     showSnackBar(
    //         message: error.join("\n"), snackBarType: SnackBarType.danger);
    //     _loadingState.value = LoadingState.none;
    //     update();
    //   },
    // );
  }

  @override
  Future<void> onClose() async {
    videoCapController.value.dispose();
    videoCapFocus.dispose();
    pageController.dispose();
    if (!isGoBack || (isGoBack && !isNewVideo))
      for (int i = 0; i < _layerList.value.length; i++) {
        final layer = _layerList.value[i];
        if (layer.controller != null && layer.controller!.value.isInitialized) {
          await layer.controller?.dispose();
        }
      }
    super.onClose();
  }

  void onSwitchToEditModePressed() {
    Get.back();
    switchToEditMode();
  }

  void switchToEditMode() {
    pageController.animateToPage(ViewMode.Edit.asInt()!,
        duration: Duration(milliseconds: 500), curve: Curves.ease);
  }
}
