import 'dart:async';
import 'dart:ui';

import 'package:diamon_rose_app/Navigation/page.dart';
import 'package:diamon_rose_app/collection_entity/background_entity.dart';
import 'package:diamon_rose_app/collection_entity/effect_entity.dart';
import 'package:diamon_rose_app/enum/edit_video_type.dart';
import 'package:diamon_rose_app/enum/layer_type.dart';
import 'package:diamon_rose_app/enum/loading_state.dart';
import 'package:diamon_rose_app/enum/position_type.dart';
import 'package:diamon_rose_app/layer_entity/layer_entity.dart';
import 'package:diamon_rose_app/my_ar_entity/ar_dto_entity.dart';
import 'package:diamon_rose_app/my_ar_entity/collection_dto_entity.dart';
import 'package:diamon_rose_app/my_ar_entity/my_ar_entity.dart';
import 'package:diamon_rose_app/widgets/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:video_player/video_player.dart';

class CreateVideoVideoModel extends GetxController
    with WidgetsBindingObserver, SingleGetTickerProviderMixin, StateMixin {
  late final double _screenHeight;
  late final double _screenWidth;
  double _mainHeight = 0;
  double _mainWidth = 0;
  double _mainRatio = 1;
  BuildContext? context = Get.context;
  final ScrollController scrollController = ScrollController();
  late TabController tabController = TabController(vsync: this, length: 3);
  Rx<PanelController> panelController = Rx(PanelController());
  Rx<LoadingState> _loadingState = Rx(LoadingState.init);
  Rx<List<LayerEntity>> _arsSelected = Rx([]);
  Rx<List<LayerEntity>> _backgroundsSelected = Rx([]);
  Rx<List<LayerEntity>> _effectsSelected = Rx([]);
  Rx<List<MyAREntity?>> _allAr = Rx([]);
  Rx<List<BackgroundEntity?>> _allBackground = Rx([]);
  Rx<List<EffectEntity?>> _allEffect = Rx([]);
  List<Map<String, dynamic>> _history = [];
  final _pageSize = 10;
  int _arPage = 0;
  int _backgroundPage = 0;
  int _effectPage = 0;
  int? totalArRecord;
  int? totalEffectRecord;
  int? totalBackgroundRecord;
  final ACTION_KEY = 'action';
  final OBJECT_KEY = 'object';
  final REMOVE_INDEX_KEY = 'removeIndex';
  final INDEX_KEY = 'index';
  final TYPE_KEY = 'layerTypeKey';
  final videoKey = 'mp4|MP4|mov|MOV';

  double get getScreenHeight => _screenHeight;

  double get getScreenWidth => _screenWidth;

  bool get isLoading => _loadingState.value == LoadingState.loading;

  List<MyAREntity?> get getAllAR => _allAr.value;

  List<BackgroundEntity?> get getAllBackground => _allBackground.value;

  List<EffectEntity?> get getAllEffect => _allEffect.value;

  List<LayerEntity> get getARsSelected => _arsSelected.value;

  List<LayerEntity> get getBackgroundsSelected => _backgroundsSelected.value;

  List<LayerEntity> get getEffectsSelected => _effectsSelected.value;

  bool get canUndo => _history.length > 0;

  @override
  Future<void> onInit() async {
    super.onInit();
    await showLoading();
    _callArAPI();
    _callBackgroundAPI();
    // _callEffectAPI();
    _screenHeight = (window.physicalSize.height - window.padding.top) /
        window.devicePixelRatio;
    _screenWidth = window.physicalSize.width / window.devicePixelRatio;
    _mainHeight = _screenHeight;
    _mainWidth = _screenWidth;
    _mainRatio = _mainWidth / _mainHeight;
    scrollController.addListener(_onLoadMore);
    tabController.addListener(_onTabChange);
    await dismissLoading();
  }

  bool isVideo(String value) {
    return value.toLowerCase().contains(RegExp('mp4|mov'));
  }

  Future<void> onOpenPanel() async {
    _onLoadLayer();
  }

  Future<void> _onTabChange() async {
    if (tabController.indexIsChanging) {
      _onLoadLayer();
    }
  }

  void _onLoadLayer() {
    if (tabController.index == 0 && totalArRecord == null) {
      _callArAPI();
      print('call ar api');
    } else if (tabController.index == 1 && totalBackgroundRecord == null) {
      _callBackgroundAPI();
      print('call background api');
    } else if (tabController.index == 2 && totalEffectRecord == null) {
      // _callEffectAPI();
      print('call effect api');
    }
  }

  Future<void> _onLoadMore() async {
    if (!scrollController.hasClients ||
        _loadingState.value == LoadingState.loading) {
      return;
    }
    final thresholdReached = scrollController.position.extentAfter == 0;
    if (thresholdReached) {
      if (tabController.index == 0 &&
          totalArRecord != null &&
          getAllAR.length < totalArRecord!) {
        _arPage++;
        _callArAPI();
        print("Call AR API");
      } else if (tabController.index == 1 &&
          totalBackgroundRecord != null &&
          getAllBackground.length < totalBackgroundRecord!) {
        _backgroundPage++;
        _callBackgroundAPI();
        print("Call Background API");
      } else if (tabController.index == 2 &&
          totalEffectRecord != null &&
          getAllEffect.length < totalEffectRecord!) {
        _effectPage++;
        // _callEffectAPI();
        print("Call Effect API");
      }
    }
  }

  Future<void> onUndo() async {
    final historyItem = _history.removeLast();
    if (historyItem[TYPE_KEY] == LayerType.ar) {
      await _onUndoAr(historyItem);
    } else if (historyItem[TYPE_KEY] == LayerType.effect) {
      await _onUndoEffect(historyItem);
    } else if (historyItem[TYPE_KEY] == LayerType.background) {
      await _onUndoBackground(historyItem);
    }
  }

  Future<void> _onUndoAr(Map<String, dynamic> historyItem) async {
    if (historyItem[ACTION_KEY] == HistoryAction.delete) {
      final controller =
          await getVideoController(historyItem[OBJECT_KEY].itemUrl);
      getARsSelected.insert(historyItem[REMOVE_INDEX_KEY],
          historyItem[OBJECT_KEY].copyWith(controller: controller));
      getAllAR[historyItem[INDEX_KEY]] =
          getAllAR[historyItem[INDEX_KEY]]?.copyWith(selected: true);
    } else {
      await getARsSelected.last.controller?.dispose();
      getARsSelected.removeLast();
      getAllAR[historyItem[INDEX_KEY]] =
          getAllAR[historyItem[INDEX_KEY]]?.copyWith(selected: false);
    }
    _arsSelected.refresh();
    _allAr.refresh();
  }

  Future<void> _onUndoEffect(Map<String, dynamic> historyItem) async {
    if (historyItem[ACTION_KEY] == HistoryAction.delete) {
      final controller =
          await getVideoController(historyItem[OBJECT_KEY].itemUrl);
      getEffectsSelected.insert(historyItem[REMOVE_INDEX_KEY],
          historyItem[OBJECT_KEY].copyWith(controller: controller));
      getAllEffect[historyItem[INDEX_KEY]] =
          getAllEffect[historyItem[INDEX_KEY]]?.copyWith(selected: true);
      for (int i = historyItem[REMOVE_INDEX_KEY];
          i < getEffectsSelected.length;
          i++) {
        final item = getEffectsSelected[i];
        final position =
            _getPosition(_getEffectPositionType(i), item.width, item.height);
        getEffectsSelected[i] = item.copyWith(
            xcoordinates: position['x'], ycoordinates: position['y']);
      }
    } else {
      await getEffectsSelected.last.controller?.dispose();
      getEffectsSelected.removeLast();
      getAllEffect[historyItem[INDEX_KEY]] =
          getAllEffect[historyItem[INDEX_KEY]]?.copyWith(selected: false);
    }
    _effectsSelected.refresh();
    _allEffect.refresh();
  }

  Future<void> _onUndoBackground(Map<String, dynamic> historyItem) async {
    if (historyItem[ACTION_KEY] == HistoryAction.delete) {
      final controller =
          await getVideoController(historyItem[OBJECT_KEY].itemUrl);
      getBackgroundsSelected.insert(historyItem[REMOVE_INDEX_KEY],
          historyItem[OBJECT_KEY].copyWith(controller: controller));
      getAllBackground[historyItem[INDEX_KEY]] =
          getAllBackground[historyItem[INDEX_KEY]]?.copyWith(selected: true);
      if (historyItem[REMOVE_INDEX_KEY] == 0) {
        _onUpdateMainSize(_screenWidth, _screenHeight);
        if (getBackgroundsSelected.isNotEmpty) {
          _onUpdateBackgroundSelectedInfo();
        }
        if (getEffectsSelected.isNotEmpty) {
          _onUpdateEffectSelectedInfo();
        }
        if (getARsSelected.isNotEmpty) {
          _onUpdateArSelectedInfo();
        }
      }
    } else {
      await getBackgroundsSelected.last.controller?.dispose();
      getBackgroundsSelected.removeLast();
      getAllBackground[historyItem[INDEX_KEY]] =
          getAllBackground[historyItem[INDEX_KEY]]?.copyWith(selected: false);
      if (getBackgroundsSelected.isEmpty) {
        _onUpdateMainSize(_screenWidth, _screenHeight);
        if (getBackgroundsSelected.isNotEmpty) {
          _onUpdateBackgroundSelectedInfo();
        }
        if (getEffectsSelected.isNotEmpty) {
          _onUpdateEffectSelectedInfo();
        }
        if (getARsSelected.isNotEmpty) {
          _onUpdateArSelectedInfo();
        }
      }
    }
    _backgroundsSelected.refresh();
    _allBackground.refresh();
  }

  Future<void> onTapAR(int index) async {
    await showLoading();

    final MyAREntity ar = getAllAR[index]!;
    final isSelected =
        getARsSelected.indexWhere((e) => e.itemId == ar.myARDTO.id) != -1;
    if (isSelected) {
      await _onUnselectAr(ar, index);
    } else if (getARsSelected.length >= 2) {
      await dismissLoading();
      return;
    } else {
      await _onSelectAr(ar, index);
    }
    _allAr.refresh();
    _arsSelected.refresh();
    await dismissLoading();
  }

  Future<void> _onUnselectAr(MyAREntity ar, int index) async {
    final removeIndex =
        getARsSelected.indexWhere((e) => e.itemId == ar.myARDTO.id);
    await getARsSelected[removeIndex].controller?.dispose();
    _history.add({
      ACTION_KEY: HistoryAction.delete,
      OBJECT_KEY: getARsSelected[removeIndex].copyWith(),
      REMOVE_INDEX_KEY: removeIndex,
      TYPE_KEY: LayerType.ar,
      INDEX_KEY: index
    });
    getARsSelected.removeAt(removeIndex);
    getAllAR[index] = ar.copyWith(selected: false);
  }

  Future<void> _onSelectAr(MyAREntity ar, int index) async {
    final url = ar.arCollectionDTO.thumbnail;
    // final url =
    //     "https://images.unsplash.com/photo-1518684079-3c830dcef090?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8MXx8ZHViYWklMjAlMjAlMjB1bml0ZWQlMjBhcmFiJTIwZW1pcmF0ZXN8ZW58MHx8MHx8&w=1000&q=80";
    print("url: $url");
    double ratio = 1;
    VideoPlayerController? controller;
    if (isVideo(url)) {
      controller = await getVideoController(url, awaitInit: true);
      if (controller == null) {
        return;
      }
      ratio = controller.value.aspectRatio;
    } else {
      ratio = await getImageRatio(url);
    }
    final width;
    final height;
    if (_mainRatio < ratio) {
      /// Horizontal video
      width = _mainWidth * 2 / 3;
      height = width / ratio;
    } else {
      /// vertical video
      height = _mainHeight * 2 / 3;
      width = height * ratio;
    }
    final position = _getPosition(PositionType.center, width, height);
    final duration = controller?.value.duration.inSeconds.toDouble() ?? 60;
    final layer = LayerEntity(
        itemId: ar.arCollectionDTO.id,
        itemUrl: url,
        itemThumbnailUrl: url,
        itemType: LayerType.ar,
        width: width,
        height: height,
        xcoordinates: position['x'],
        ycoordinates: position['y'],
        range: RangeValues(0, duration),
        duration: duration,
        controller: controller);
    getARsSelected.add(layer);
    getAllAR[index] = ar.copyWith(selected: true);
    _history.add({
      ACTION_KEY: HistoryAction.add,
      OBJECT_KEY: layer,
      TYPE_KEY: LayerType.ar,
      INDEX_KEY: index
    });
  }

  Future<void> onTapEffect(int index) async {
    await showLoading();
    final EffectEntity effect = getAllEffect[index]!;
    final isSelected =
        getEffectsSelected.indexWhere((e) => e.itemId == effect.id) != -1;
    if (isSelected) {
      await _onUnselectEffect(effect, index);
    } else if (getEffectsSelected.length >= 2) {
      await dismissLoading();
      return;
    } else {
      await _onSelectEffect(effect, index);
    }
    _allEffect.refresh();
    _effectsSelected.refresh();
    await dismissLoading();
  }

  Future<void> _onUnselectEffect(EffectEntity effect, int index) async {
    final removeIndex =
        getEffectsSelected.indexWhere((e) => e.itemId == effect.id);
    await getEffectsSelected[removeIndex].controller?.dispose();
    _history.add({
      ACTION_KEY: HistoryAction.delete,
      OBJECT_KEY: getEffectsSelected[removeIndex].copyWith(),
      REMOVE_INDEX_KEY: removeIndex,
      TYPE_KEY: LayerType.effect,
      INDEX_KEY: index
    });
    getEffectsSelected.removeAt(removeIndex);
    getAllEffect[index] = effect.copyWith(selected: false);
    for (int i = removeIndex; i < getEffectsSelected.length; i++) {
      final item = getEffectsSelected[i];
      final position =
          _getPosition(_getEffectPositionType(i), item.width, item.height);
      getEffectsSelected[i] = item.copyWith(
          xcoordinates: position['x'],
          ycoordinates: position['y'],
          controller: item.controller);
    }
  }

  Future<void> _onSelectEffect(EffectEntity effect, int index) async {
    final url = effect.effectUrl;
    double ratio = 1;
    VideoPlayerController? controller;
    if (isVideo(url)) {
      controller = await getVideoController(url, awaitInit: true);
      if (controller == null) {
        return;
      }
      ratio = controller.value.aspectRatio;
    } else {
      ratio = await getImageRatio(url);
    }
    final width;
    final height;
    if (_mainRatio < ratio) {
      /// Horizontal video
      width = _mainWidth * 2 / 5;
      height = width / ratio;
    } else {
      /// vertical video
      height = _mainHeight * 2 / 5;
      width = height * ratio;
    }
    final position = _getPosition(
        _getEffectPositionType(getEffectsSelected.length), width, height);
    final duration = controller?.value.duration.inSeconds.toDouble() ?? 60;
    final layer = LayerEntity(
        itemId: effect.id,
        itemUrl: url,
        itemThumbnailUrl: effect.thumbnail,
        itemType: LayerType.effect,
        width: width,
        height: height,
        xcoordinates: position['x'],
        ycoordinates: position['y'],
        range: RangeValues(0, duration),
        duration: duration,
        controller: controller);
    getEffectsSelected.add(layer);
    getAllEffect[index] = effect.copyWith(selected: true);
    _history.add({
      ACTION_KEY: HistoryAction.add,
      OBJECT_KEY: layer,
      TYPE_KEY: LayerType.effect,
      INDEX_KEY: index
    });
  }

  Future<void> onTapBackground(int index) async {
    await showLoading();
    final BackgroundEntity background = getAllBackground[index]!;
    final isSelected =
        getBackgroundsSelected.indexWhere((e) => e.itemId == background.id) !=
            -1;
    if (isSelected) {
      await _onUnselectBackground(background, index);
    } else if (getBackgroundsSelected.length >= 2) {
      await dismissLoading();
      return;
    } else {
      await _onSelectBackground(background, index);
    }
    _allBackground.refresh();
    _backgroundsSelected.refresh();
    await dismissLoading();
  }

  Future<void> _onUnselectBackground(
      BackgroundEntity background, int index) async {
    final removeIndex =
        getBackgroundsSelected.indexWhere((e) => e.itemId == background.id);
    await getBackgroundsSelected[removeIndex].controller?.dispose();
    _history.add({
      ACTION_KEY: HistoryAction.delete,
      OBJECT_KEY: getBackgroundsSelected[removeIndex].copyWith(),
      REMOVE_INDEX_KEY: removeIndex,
      TYPE_KEY: LayerType.background,
      INDEX_KEY: index
    });
    getBackgroundsSelected.removeAt(removeIndex);
    getAllBackground[index] = background.copyWith(selected: false);
    if (removeIndex == 0) {
      _onUpdateMainSize(_screenWidth, _screenHeight);
      if (getBackgroundsSelected.isNotEmpty) {
        _onUpdateBackgroundSelectedInfo();
      }
      if (getEffectsSelected.isNotEmpty) {
        _onUpdateEffectSelectedInfo();
      }
      if (getARsSelected.isNotEmpty) {
        _onUpdateArSelectedInfo();
      }
    }
  }

  Future<void> _onSelectBackground(
      BackgroundEntity background, int index) async {
    final url = background.backgroundUrl;
    double ratio = 1;
    VideoPlayerController? controller;
    if (isVideo(url)) {
      controller = await getVideoController(url, awaitInit: true);
      if (controller == null) {
        return;
      }
      ratio = controller.value.aspectRatio;
    } else {
      ratio = await getImageRatio(url);
    }
    final width;
    final height;
    if (_mainRatio < ratio) {
      /// Horizontal video
      width = _mainWidth;
      height = width / ratio;
    } else {
      /// vertical video
      height = _mainHeight;
      width = height * ratio;
    }
    if (getBackgroundsSelected.isEmpty) {
      _onUpdateMainSize(width, height);
      if (getEffectsSelected.isNotEmpty) {
        _onUpdateEffectSelectedInfo();
      }
      if (getARsSelected.isNotEmpty) {
        _onUpdateArSelectedInfo();
      }
    }
    final position = _getPosition(PositionType.center, width, height);
    final duration = controller?.value.duration.inSeconds.toDouble() ?? 60;
    final layer = LayerEntity(
        itemId: background.id,
        itemUrl: url,
        itemThumbnailUrl: background.thumbnail,
        itemType: LayerType.background,
        width: width,
        height: height,
        xcoordinates: position['x'],
        ycoordinates: position['y'],
        range: RangeValues(0, duration),
        duration: duration,
        controller: controller);
    getBackgroundsSelected.add(layer);
    getAllBackground[index] = background.copyWith(selected: true);
    _history.add({
      ACTION_KEY: HistoryAction.add,
      OBJECT_KEY: layer,
      TYPE_KEY: LayerType.background,
      INDEX_KEY: index
    });
  }

  void _onUpdateBackgroundSelectedInfo() {
    for (int i = 0; i < getBackgroundsSelected.length; i++) {
      final bg = getBackgroundsSelected[i];
      final ratio = bg.width / bg.height;
      final width;
      final height;
      if (_mainRatio < ratio) {
        /// Horizontal video
        width = _mainWidth;
        height = width / ratio;
      } else {
        /// vertical video
        height = _mainHeight;
        width = height * ratio;
      }
      if (i == 0) {
        _onUpdateMainSize(width, height);
      }
      final position = _getPosition(PositionType.center, width, height);
      getBackgroundsSelected[i] = bg.copyWith(
          xcoordinates: position['x'],
          ycoordinates: position['y'],
          width: width,
          height: height,
          controller: bg.controller);
    }
  }

  void _onUpdateArSelectedInfo() {
    for (int i = 0; i < getARsSelected.length; i++) {
      final ar = getARsSelected[i];
      final ratio = ar.width / ar.height;
      final width;
      final height;
      if (_mainRatio < ratio) {
        /// Horizontal video
        width = _mainWidth * 2 / 3;
        height = width / ratio;
      } else {
        /// vertical video
        height = _mainHeight * 2 / 3;
        width = height * ratio;
      }
      final position = _getPosition(PositionType.center, width, height);
      getARsSelected[i] = ar.copyWith(
          xcoordinates: position['x'],
          ycoordinates: position['y'],
          width: width,
          height: height,
          controller: ar.controller);
    }
  }

  void _onUpdateEffectSelectedInfo() {
    for (int i = 0; i < getEffectsSelected.length; i++) {
      final effect = getEffectsSelected[i];
      final ratio = effect.width / effect.height;
      final width;
      final height;
      if (_mainRatio < ratio) {
        /// Horizontal video
        width = _mainWidth * 2 / 5;
        height = width / ratio;
      } else {
        /// vertical video
        height = _mainHeight * 2 / 5;
        width = height * ratio;
      }
      final position = _getPosition(_getEffectPositionType(i), width, height);
      getEffectsSelected[i] = effect.copyWith(
          xcoordinates: position['x'],
          ycoordinates: position['y'],
          width: width,
          height: height,
          controller: effect.controller);
    }
  }

  PositionType _getEffectPositionType(int index) {
    if (index == 0) {
      return PositionType.topLeft;
    } else if (index == 1) {
      return PositionType.topRight;
    } else if (index == 2) {
      return PositionType.bottomRight;
    } else if (index == 3) {
      return PositionType.bottomLeft;
    } else {
      return PositionType.center;
    }
  }

  Map _getPosition(PositionType type, double width, double height) {
    final residualWidth = (_screenWidth - _mainWidth) / 2;
    final residualHeight = (_screenHeight - _mainHeight) / 2;
    final position = {};
    if (type == PositionType.topLeft) {
      position['x'] = residualWidth / _screenWidth;
      position['y'] = residualHeight / _screenHeight;
    } else if (type == PositionType.topRight) {
      position['x'] = (_mainWidth - width - residualWidth) / _screenWidth;
      position['y'] = residualHeight / _screenHeight;
    } else if (type == PositionType.bottomRight) {
      position['x'] = (_mainWidth - width) / _screenWidth;
      position['y'] = (_screenHeight - height - residualHeight) / _screenHeight;
    } else if (type == PositionType.bottomLeft) {
      position['x'] = residualWidth / _screenWidth;
      position['y'] = (_screenHeight - height - residualHeight) / _screenHeight;
    } else if (type == PositionType.center) {
      position['x'] = ((_screenWidth - width) / 2) / _screenWidth;
      position['y'] = ((_screenHeight - height) / 2) / _screenHeight;
    }
    return position;
  }

  void _onUpdateMainSize(double width, double height) {
    _mainHeight = height;
    _mainWidth = width;
    _mainRatio = _mainWidth / _mainHeight;
  }

  Future<void> onDone() async {
    await showLoading();
    final List<LayerEntity> _allLayerSelected = []
      ..addAll(getBackgroundsSelected)
      ..addAll(getEffectsSelected)
      ..addAll(getARsSelected);
    final agr = {'TYPE': EditVideoType.newVideo, 'DATA': _allLayerSelected};
    await dismissLoading();

    if (_allLayerSelected.length > 0) {
      await Get.toNamed(ROUTER_EDIT_VIDEO, arguments: agr);

      for (int i = 0; i < getARsSelected.length; i++) {
        final ar = getARsSelected[i];
        if (ar.controller != null && ar.controller!.value.isInitialized) {
          await ar.controller?.dispose().catchError((e) {});
          ar.controller = null;
          final controller = await getVideoController(ar.itemUrl);
          getARsSelected[i] = ar.copyWith(controller: controller);
        }
      }
      for (int i = 0; i < getEffectsSelected.length; i++) {
        final effect = getEffectsSelected[i];
        if (effect.controller != null &&
            effect.controller!.value.isInitialized) {
          await effect.controller?.dispose().catchError((e) {});
          effect.controller = null;
          final controller = await getVideoController(effect.itemUrl);
          getEffectsSelected[i] = effect.copyWith(controller: controller);
        }
      }
      for (int i = 0; i < getBackgroundsSelected.length; i++) {
        final bg = getBackgroundsSelected[i];
        if (bg.controller != null && bg.controller!.value.isInitialized) {
          await bg.controller?.dispose().catchError((e) {});
          bg.controller = null;
          final controller = await getVideoController(bg.itemUrl);
          getBackgroundsSelected[i] = bg.copyWith(controller: controller);
        }
      }
    }
  }

  Future<VideoPlayerController?> getVideoController(String url,
      {bool awaitInit = false}) async {
    try {
      final controller = VideoPlayerController.network(url,
          videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true));
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
      debugPrint('${e}');
      await dismissLoading();
      await showErrorConfirmDialog(
          context: Get.context!, errors: [e.toString()]);
      return null;
    }
  }

  void _callArAPI() {
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
          thumbnail:
              "https://images.unsplash.com/photo-1453728013993-6d66e9c9123a?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8Mnx8dmlld3xlbnwwfHwwfHw%3D&w=1000&q=80",
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

  // void _callEffectAPI() {
  //   MyCollectionRepository.instance.getEffect(
  //     requestParam: RequestGetArModel(size: _pageSize, page: _effectPage),
  //     onStart: () {
  //       _loadingState.value = LoadingState.loading;
  //       update();
  //     },
  //     onSuccess: (response) async {
  //       _allEffect.value.addAll(response.items);
  //       totalEffectRecord = response.totalElements;
  //       _allEffect.refresh();
  //       _loadingState.value = LoadingState.none;
  //       update();
  //     },
  //     onError: (error) {
  //       showSnackBar(
  //           message: error.join("\n"), snackBarType: SnackBarType.danger);
  //       _loadingState.value = LoadingState.none;
  //       update();
  //     },
  //   );
  // }

  void _callBackgroundAPI() {
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
    for (int i = 0; i < getARsSelected.length; i++) {
      final ar = getARsSelected[i];
      if (ar.controller != null && ar.controller!.value.isInitialized) {
        await ar.controller?.dispose();
      }
    }
    for (int i = 0; i < getEffectsSelected.length; i++) {
      final effect = getEffectsSelected[i];
      if (effect.controller != null && effect.controller!.value.isInitialized) {
        await effect.controller?.dispose();
      }
    }
    for (int i = 0; i < getBackgroundsSelected.length; i++) {
      final bg = getBackgroundsSelected[i];
      if (bg.controller != null && bg.controller!.value.isInitialized) {
        await bg.controller?.dispose();
      }
    }
    super.onClose();
  }
}

enum HistoryAction { delete, add }
