// ignore_for_file: cascade_invocations

import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:diamon_rose_app/constants/Constantcolors.dart';
import 'package:diamon_rose_app/providers/ffmpegProviders.dart';
import 'package:diamon_rose_app/providers/video_editor_provider.dart';
import 'package:diamon_rose_app/screens/GiphyTest/get_giphy_gifs.dart';
import 'package:diamon_rose_app/screens/PostPage/previewVideo.dart';
import 'package:diamon_rose_app/screens/feedPages/feedPage.dart';
import 'package:diamon_rose_app/screens/testVideoEditor/ArContainerClass/ArContainerClass.dart';
import 'package:diamon_rose_app/screens/testVideoEditor/GD_custom_range_slider.dart';
import 'package:diamon_rose_app/screens/testVideoEditor/TrimVideo/ui/frame/frame_slider_painter.dart';
import 'package:diamon_rose_app/screens/testVideoEditor/TrimVideo/ui/frame/frame_thumbnail_slider.dart';
import 'package:diamon_rose_app/screens/testVideoEditor/TrimVideo/ui/video_viewer.dart';
import 'package:diamon_rose_app/screens/testVideoEditor/TrimVideo/video_editor.dart';
import 'package:diamon_rose_app/screens/testVideoEditor/VideoThumbnailSelectionScreen.dart';
import 'package:diamon_rose_app/screens/testVideoEditor/testingVideoOutput.dart';
import 'package:diamon_rose_app/screens/youtubeSearchApi/loading_widget.dart';
import 'package:diamon_rose_app/screens/youtubeSearchApi/search.dart';
import 'package:diamon_rose_app/screens/youtubeSearchApi/searchResults/searchresultsservice.dart';
import 'package:diamon_rose_app/screens/youtubeTest/youtubeFileModel.dart';
import 'package:diamon_rose_app/screens/youtubeTest/youtube_utils.dart';
import 'package:diamon_rose_app/services/ArVideoCreationService.dart';
import 'package:diamon_rose_app/services/FirebaseOperations.dart';
import 'package:diamon_rose_app/services/authentication.dart';
import 'package:diamon_rose_app/services/img_seq_animator.dart';
import 'package:diamon_rose_app/services/myArCollectionClass.dart';
import 'package:diamon_rose_app/services/shared_preferences_helper.dart';
import 'package:diamon_rose_app/translations/locale_keys.g.dart';
import 'package:diamon_rose_app/widgets/extensions.dart';
import 'package:diamon_rose_app/widgets/global.dart';
import 'package:diamon_rose_app/widgets/measure_widget_size.dart';
import 'package:diamon_rose_app/widgets/utils.dart';
import 'package:dio/dio.dart' as dio;
import 'package:easy_localization/easy_localization.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_kit_config.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/ffprobe_kit.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/statistics.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart' hide Trans;
import 'package:giphy_get/giphy_get.dart';
import 'package:helpers/helpers/transition.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:just_audio/just_audio.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:nanoid/nanoid.dart';
import 'package:page_transition/page_transition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:video_player/video_player.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;

import 'package:diamon_rose_app/screens/youtubeSearchApi/searchResults/songsdataclass.dart';

enum _FrameBoundaries { left, right, inside, progress, none }

class CreateVideoScreen extends StatefulWidget {
  const CreateVideoScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<CreateVideoScreen> createState() => _CreateVideoScreenState();
}

class _CreateVideoScreenState extends State<CreateVideoScreen>
    with AutomaticKeepAliveClientMixin<CreateVideoScreen> {
  ConstantColors constantColors = ConstantColors();
  final _boundary = ValueNotifier<_FrameBoundaries>(_FrameBoundaries.none);
  // final _imgSeqProgress = ValueNotifier<double>(0);
  // final _imgSeqContainerWidth = ValueNotifier<double>(0);
  // final _showAr = ValueNotifier<bool>(true);
  final _exportingProgress = ValueNotifier<double>(0.0);
  final _isExporting = ValueNotifier<bool>(false);
  bool _exported = false;
  String _exportText = "";
  final _bgProgress = ValueNotifier<double>(0);
  final _scrollController = ScrollController();
  //Gif
  GiphyGif? currentGif;
  // Giphy Client
  GiphyClient? client;
  // Random ID
  String randomId = "";
  String giphyApiKey = "0X2ffUW2nnfVcPUc2C7alPhfdrj2tA6M";
  VideoPlayerController? _finalVideoController;

  Rect _rect = Rect.zero;
  Size _trimLayout = Size.zero;
  Size _fullLayout = Size.zero;
  late VideoEditorController _controller;
  late VideoPlayerController _videoController;
  final double height = 60;

  // * for Ar videos
  bool uploadAR = false;
  bool loading = true;
  String? folderName;
  ARList? selected;

  Offset? _initPos;
  Offset? _currentPos = Offset(0, 0);
  double? _currentScale;
  double? _currentRotation;
  ValueNotifier<List<ARList>> list = ValueNotifier<List<ARList>>([]);
  int listVal = 0;
  Size? screen;
  bool onFinishedPlaying = false;
  ValueNotifier<int> arIndexVal = ValueNotifier<int>(0);
  ValueNotifier<int> musicIndexVal = ValueNotifier<int>(0);

  // * for effects
  File? _selectedGifFile;
  ValueNotifier<int> effectIndexVal = ValueNotifier<int>(0);
  PlatformFile? selectedFile;
  late File thumbnailFile;

  ValueNotifier<int> indexCounter = ValueNotifier<int>(1);

  // !############################### for Youtube Search API

  String query = 'Drake';
  static const _pageSize = 20;

  final FloatingSearchBarController _searchBarController =
      FloatingSearchBarController();

  final _pagingController = PagingController<int, Songs>(
    // 2
    firstPageKey: 1,
  );

  Future<void> fetchSongs(int pageKey) async {
    try {
      final List<Songs> newItems =
          await SearchMusic.getOnlySongs(query, _pageSize);
      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + newItems.length;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  final spacer = SizedBox(width: 10);
  final biggerSpacer = SizedBox(width: 40);

  YoutubeUtil youtubeHandler = YoutubeUtil();

  _selectAudioOption(BuildContext context) {
    return showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            height: 20.h,
            width: 100.w,
            decoration: BoxDecoration(
              color: constantColors.whiteColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 150),
                  child: Divider(
                    thickness: 4,
                    color: constantColors.greyColor,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    MaterialButton(
                      color: constantColors.navButton,
                      child: Text(
                        "Original Music",
                        style: TextStyle(
                          color: constantColors.whiteColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      onPressed: () async {
                        // Get.back();
                        // ! For picking music file from users device

                        FilePickerResult? file =
                            await FilePicker.platform.pickFiles(
                          type: FileType.custom,
                          allowedExtensions: ['mp3'],
                          allowMultiple: false,
                          allowCompression: true,
                        );

                        if (file != null) {
                          if (list.value.isNotEmpty) {
                            list.value.last.layerType == LayerType.AR
                                ? indexCounter.value = indexCounter.value + 2
                                : indexCounter.value = indexCounter.value + 1;
                          } else {
                            indexCounter.value = 1;
                          }

                          if (indexCounter.value <= 0) {
                            indexCounter.value = 1;
                          }

                          await runFFmpegForAudioOnlyFiles(
                            arVal: indexCounter.value,
                            audioFile: File(file.files.single.path!),
                            songTitle: "Original Track",
                            songArtist:
                                context.read<FirebaseOperations>().initUserName,
                            songUrl: "",
                            songAlbumCover: context
                                .read<FirebaseOperations>()
                                .initUserImage,
                          );
                        }
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
                      onPressed: () async {
                        Get.back();
                        _showYoutubeBottomSheet(context);
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        });
  }

  _showYoutubeBottomSheet(BuildContext context) {
    return showModalBottomSheet(
      isDismissible: true,
      isScrollControlled: true,
      enableDrag: true,
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: 90.h,
          width: 100.w,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Scaffold(
            body: SearchFunction(
              liveSearch: false,
              controller: _searchBarController,
              onSubmitted: (searchQuery) async {
                query = searchQuery;

                _pagingController.refresh();
                // setState(() {
                //
                // });
              },
              body: Center(
                child: RefreshIndicator(
                  onRefresh: () => Future.sync(
                    () => _pagingController.refresh(),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CustomScrollView(
                      slivers: [
                        const SliverToBoxAdapter(child: SizedBox(height: 50)),
                        SliverToBoxAdapter(
                            child: Text(
                          query,

                          // widget.songQuery == ''
                          //   ? '  Results for \"${query}\"'
                          //   : '  Results for \"${widget.songQuery}\"',

                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )),
                        const SliverToBoxAdapter(
                          child: SizedBox(
                            height: 15,
                          ),
                        ),
                        AnimationLimiter(
                          child: PagedSliverList.separated(
                            //physics: BouncingScrollPhysics(),

                            pagingController: _pagingController,
                            // padding: const EdgeInsets.all(10),
                            separatorBuilder: (context, index) =>
                                const SizedBox(
                              height: 10,
                            ),
                            builderDelegate: PagedChildBuilderDelegate<Songs>(
                              animateTransitions: true,
                              transitionDuration:
                                  const Duration(milliseconds: 200),
                              firstPageProgressIndicatorBuilder: (_) => Center(
                                child: loadingWidget(context),
                              ),
                              newPageProgressIndicatorBuilder: (_) =>
                                  Center(child: loadingWidget(context)),
                              itemBuilder: (context, songs, index) =>
                                  AnimationConfiguration.staggeredList(
                                position: index,
                                duration: const Duration(milliseconds: 370),
                                child: SlideAnimation(
                                  verticalOffset: 50.0,
                                  child: FadeInAnimation(
                                      child: Material(
                                    borderRadius: BorderRadius.circular(10),
                                    color: constantColors.bioBg,
                                    child: InkWell(
                                      onTap: () async {
                                        await Permission.storage.request();
                                        CoolAlert.show(
                                            context: context,
                                            type: CoolAlertType.loading,
                                            barrierDismissible: false);
                                        //playerAlerts.buffering = t
                                        dev.log(
                                            "songs.videoId == ${songs.videoId}");
                                        dev.log(
                                            "Youtube URL == https://www.youtube.com/watch?v=${songs.videoId}");
                                        dev.log(
                                            "songs.title == ${songs.title}");
                                        dev.log(
                                            "songs.artists![0].name == ${songs.artists![0].name}");

                                        await youtubeHandler
                                            .loadVideo(songs.videoId);

                                        final File? file = await youtubeHandler
                                            .downloadMP3File();

                                        if (file != null) {
                                          dev.log("DONE! == ${file.path}");

                                          if (list.value.isNotEmpty) {
                                            list.value.last.layerType ==
                                                    LayerType.AR
                                                ? indexCounter.value =
                                                    indexCounter.value + 2
                                                : indexCounter.value =
                                                    indexCounter.value + 1;
                                          } else {
                                            indexCounter.value = 1;
                                          }

                                          if (indexCounter.value <= 0) {
                                            indexCounter.value = 1;
                                          }

                                          Get.back();

                                          await runFFmpegForAudioOnlyFiles(
                                            arVal: indexCounter.value,
                                            audioFile: file,
                                            songTitle: songs.title,
                                            songArtist: songs.artists![0].name,
                                            songAlbumCover:
                                                songs.thumbnails[0].url,
                                            songUrl:
                                                "https://www.youtube.com/watch?v=${songs.videoId}",
                                          );
                                        } else {
                                          Get.back();
                                          Get.back();
                                          Get.dialog(
                                            SimpleDialog(
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.all(10),
                                                  child: Text(
                                                      "Error Loading this music video, it has been locked by the owner!"),
                                                ),
                                              ],
                                            ),
                                          );
                                        }
                                        // await context.read<ActiveAudioData>().songDetails(
                                        //     songs.videoId,
                                        //     songs.videoId,
                                        //     songs.artists![0].name,
                                        //     songs.title,
                                        //     songs.thumbnails[0].url,
                                        //     //songs.thumbnails.map((e) => ThumbnailLocal(height: e.height, url: e.url.toString(), width: e.width)).toList(),
                                        //     songs.thumbnails.last.url.toString());

                                        // await AudioControlClass.play(
                                        //   videoId: songs.videoId.toString(),
                                        //   context: context,
                                        // );
                                      },
                                      borderRadius: BorderRadius.circular(8),
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            5, 5, 5, 5),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            FadeInImage(
                                                placeholder: const AssetImage(
                                                    'assets/images/GDlogo.png'),
                                                width: 40,
                                                height: 40,
                                                fit: BoxFit.cover,
                                                image: NetworkImage(
                                                  songs.thumbnails.first.url
                                                      .toString(),
                                                )),
                                            // CachedNetworkImage(
                                            //   memCacheHeight: 40,
                                            //   memCacheWidth: 40,
                                            //   width: 40,
                                            //   height: 40,
                                            //   imageBuilder: (context, imageProvider) => CircleAvatar(
                                            //     backgroundColor: Colors.transparent,
                                            //     foregroundColor: Colors.transparent,
                                            //     radius: 100,
                                            //     backgroundImage: imageProvider,
                                            //   ),
                                            //   fit: BoxFit.cover,
                                            //   errorWidget: (context, _, __) => const Image(
                                            //     fit: BoxFit.cover,
                                            //     image: AssetImage('assets/cover.jpg'),
                                            //   ),
                                            //   imageUrl: songs.thumbnails.first.url.toString(),
                                            //   placeholder: (context, url) => const Image(
                                            //       fit: BoxFit.cover,
                                            //       image: AssetImage('assets/cover.jpg')),
                                            // ),
                                            spacer,

                                            SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  1 /
                                                  4,
                                              child: Text(
                                                songs.title.toString(),
                                                // widget.isFromPrimarySearchPage ? songs[index].title.toString() : 'Kuch is tarah',
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            spacer,
                                            SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  1 /
                                                  8,
                                              child: Text(
                                                songs.artists![0].name
                                                    .toString(),
                                                // widget.isFromPrimarySearchPage ? songs[index].artists![0].name.toString() : 'Atif',
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            spacer,
                                            if (MediaQuery.of(context)
                                                    .size
                                                    .width >
                                                500)
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    1 /
                                                    8,
                                                child: Text(
                                                  songs.album!.name.toString(),
                                                  //  widget.isFromPrimarySearchPage ? songs[index].album!.name.toString() : 'The jal band',
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  1 /
                                                  15,
                                              child: Text(
                                                songs.duration.toString(),
                                                //widget.isFromPrimarySearchPage ? songs[index].duration.toString() : '5:25',
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            biggerSpacer,
                                            const Icon(Icons.more_vert)
                                            // mat.IconButton(
                                            //     iconSize : 10,
                                            //     onPressed: () {}, icon: Icon(FluentIcons.play))
                                          ],
                                        ),
                                      ),
                                    ),
                                  )),
                                ),
                              ),
                              // firstPageErrorIndicatorBuilder: (context) =>
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // !############################### for Youtube Search API

  _openFileManager() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['gif'],
      allowMultiple: false,
    );
    if (result != null) {
      setState(() {
        selectedFile = result.files.first;
        effectIndexVal.value = list.value
                .where((element) => element.layerType == LayerType.Effect)
                .length +
            1;
      });

      if (effectIndexVal.value <= 2) {
        if (list.value.isNotEmpty) {
          list.value.last.layerType == LayerType.AR
              ? indexCounter.value = indexCounter.value + 2
              : indexCounter.value = indexCounter.value + 1;
        }

        await runGifFFmpegCommand(
          arVal: indexCounter.value,
          gifFile: File(selectedFile!.path!),
          fromFirebase: false,
        ).then((value) {
          setState(() {});
        });
      } else {
        CoolAlert.show(
          context: context,
          type: CoolAlertType.info,
          title: "Max Effects's Reached",
          text: "You can only have 2 effects's",
        );
      }
    }
  }

  void disposeScreen() async {
    timer.cancel();
    // CoolAlert.show(
    //     context: context,
    //     type: CoolAlertType.info,
    //     barrierDismissible: false,
    //     title: "Deleting Layers",
    //     text: "Taking you back shortly...");
    for (ARList element in list.value) {
      if (element.gifFilePath != null) {
        await deleteFile([element.gifFilePath!]);
      }

      // await deleteFile(element.pathsForVideoFrames!);
      if (element.arState != null) {
        element.arState!.dispose();
        if (element.audioFlag == true) element.audioPlayer!.dispose();
      }
    }
    await DefaultCacheManager().emptyCache();
    _exportingProgress.dispose();
    _isExporting.dispose();

    _controller.dispose();
  }

  @override
  void dispose() {
    list.value
        .where((element) => element.audioPlayer != null)
        .toList()
        .forEach((element) {
      element.audioPlayer!.dispose();
    });
    disposeScreen();
    _pagingController.dispose();

    super.dispose();
  }

  // * to get the size of the AR's
  var myChildSize = Size.zero;

  final videoContainerKey = GlobalKey();

  ImageSequenceAnimatorState? get imageSequenceAnimator =>
      onlineImageSequenceAnimator;
  ImageSequenceAnimatorState? onlineImageSequenceAnimator;

  void onOnlineReadyToPlay(ImageSequenceAnimatorState _imageSequenceAnimator) {
    onlineImageSequenceAnimator = _imageSequenceAnimator;
    setState(() {});
  }

  void onOnlinePlaying(ImageSequenceAnimatorState _imageSequenceAnimator) {
    setState(() {});
  }

  double _thumbnailPosition = 0.0;
  double? _ratio;
  // trim line width set in the style
  double _trimWidth = 0.0;

  double deg2rad(double deg) => deg * pi / 180;
  double posX = 0.0001;
  final oneSec = Duration(milliseconds: 100);
  bool gotArContainerWidth = false;
  double arContainerWidth = 0;
  bool showArContainer = false;
  // late String _videoPath;

  late Timer timer;

  @override
  void initState() {
    screen = Size(50, 50);

    // 3
    _pagingController.addPageRequestListener((pageKey) {
      fetchSongs(pageKey);
    });

    // _videoPath =
    //     context.read<VideoEditorProvider>().getBackgroundVideoFile.path;

    client = GiphyClient(apiKey: giphyApiKey, randomId: '');
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      client!.getRandomId().then((value) {
        setState(() {
          randomId = value;
        });
      });
    });

    _controller =
        context.read<VideoEditorProvider>().getBackgroundVideoController;
    _videoController =
        context.read<VideoEditorProvider>().getVideoPlayerController;

    _controller.video.setLooping(false);

    setState(() {});

    _ratio = getRatioDuration();
    _trimWidth = _controller.trimStyle.lineWidth;

    timer = Timer.periodic(oneSec, (Timer t) {
      double bgDuration = _fullLayout.width * _controller.trimPosition;

      _bgProgress.value = bgDuration;

      if (listVal < list.value.length) {
        setState(() {
          listVal = list.value.length;
        });
      }

      for (ARList arElement in list.value) {
        if (_controller.video.value.position.inMicroseconds <= 0 &&
            list.value.isNotEmpty) {
          if (arElement.finishedCaching!.value == true &&
              arElement.arState != null) {
            arElement.arState?.skip(0);
          }
          if (arElement.audioFlag == true)
            arElement.audioPlayer!.seek(Duration(milliseconds: 0));
        }

        if (arElement.startingPositon! < _bgProgress.value &&
            (arElement.endingPosition! + arElement.startingPositon!) >=
                _bgProgress.value &&
            _controller.isPlaying) {
          // _showAr.value = true;
          arElement.showAr!.value = true;
          // imageSequenceAnimator!.play();
          if (arElement.finishedCaching!.value == true)
            arElement.arState!.play();
          if (arElement.audioFlag == true) arElement.audioPlayer!.play();

          print("Show ar now ${arElement.showAr!.value}");
        } else if (arElement.showAr!.value == true &&
            (arElement.endingPosition! + arElement.startingPositon!) <=
                _bgProgress.value) {
          // _showAr.value = false;
          arElement.showAr!.value = false;

          print("Dont Show ar now ${arElement.showAr!.value}");
        }

        if (_controller.isPlaying == false &&
            arElement.startingPositon! >= bgDuration &&
            (arElement.startingPositon! + arElement.endingPosition! <=
                bgDuration)) {
          if (arElement.finishedCaching!.value == true &&
              arElement.arState != null) {
            arElement.arState!.pause();
            arElement.arState!.skip(bgDuration);
          }
          if (arElement.audioFlag == true &&
              arElement.finishedCaching!.value == true) {
            arElement.audioPlayer!.pause();
            arElement.audioPlayer!.seek(Duration(
                seconds: int.parse(
                    "${(arElement.arState!.currentTime.ceil() / 1000).toStringAsFixed(0)}")));
          }
        }

        if (arElement.arState != null && arElement.endingPosition == 0) {
          final double imgSeqTotalTime = arElement.totalDuration!;

          final double controllerTotalTime = double.parse(
              "${_fullLayout.width / _controller.video.value.duration.inSeconds}");

          final double arContainer = imgSeqTotalTime * controllerTotalTime;

          print(" arContainerWidth == $arContainer");

          setState(() {
            arContainerWidth = arContainer;
            gotArContainerWidth = true;
            arElement.endingPosition = arContainer +
                (_fullLayout.width / _controller.maxDuration.inSeconds);
          });
        }
      }
    });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  bool get wantKeepAlive => true;

  // * running ffmpeg to get video with no background
  Future<void> runFFmpegCommand({
    required int arVal,
    required MyArCollection myAr,
  }) async {
    if (await Permission.storage.request().isGranted) {
      dev.log("AR INDEX == $arVal");
      // ignore: unawaited_futures
      CoolAlert.show(
        context: context,
        type: CoolAlertType.loading,
        barrierDismissible: false,
        text: LocaleKeys.loadingar.tr(),
      );
      // Form matte file
      final Directory appDocument = await getApplicationDocumentsDirectory();
      final String rawDocument = appDocument.path;
      final String imgSeqFolder = "${rawDocument}/";

      setState(() {
        folderName = imgSeqFolder;
      });

      try {
        await FFprobeKit.execute(
                '-i ${Uri.parse(myAr.main)} -show_entries format=duration -v quiet -of json')
            .then((value) {
          value.getOutput().then((mapOutput) async {
            final Map<String, dynamic> json = jsonDecode(mapOutput!);

            final String durationString = json['format']['duration'];

            print("durationString: $durationString");

            final String setDuration = double.parse(durationString) >=
                    _controller.video.value.duration.inSeconds
                ? _controller.video.value.duration.inSeconds.toString()
                : durationString;

            //! #############################################################

            final List<String> _fullPathsOnline =
                myAr.imgSeq.map((e) => e.replaceAll("https", "http")).toList();
            _fullPathsOnline.removeLast();
            dev.log(
                "first link == ${_fullPathsOnline.first} || last = ${_fullPathsOnline.last}");

            final File arCutOutFile = await getImage(url: _fullPathsOnline[0]);
            dev.log("ArCut out ois here  = ${arCutOutFile.path}");

            File? audioFile;
            final AudioPlayer? _player = AudioPlayer();

            if (myAr.audioFlag == true) {
              try {
                await FFmpegKit.execute(
                        '-vn -sn -dn -y -i ${Uri.parse(myAr.audioFile)} -t ${double.parse(setDuration)} -vn -acodec copy ${imgSeqFolder}${arVal}audio.aac')
                    .then((rc) {
                  print("FFmpeg audio extraction success");
                  audioFile = File("${imgSeqFolder}${arVal}audio.aac");
                  print(audioFile!.path + "in");
                });
              } catch (e) {
                print("FFmpeg audio extraction Error ==== ${e.toString()}");
              }

              print(audioFile!.path + "out");

              await _player!.setFilePath(audioFile!.path);
              await _player.pause();
            }

            final containerKey = GlobalKey();

            try {
              await FFprobeKit.execute(
                      "-v error -show_streams -print_format json -i ${_fullPathsOnline[0]}")
                  .then((value) {
                value.getOutput().then((imageDetails) {
                  final Map<String, dynamic> json = jsonDecode(imageDetails!);

                  final int videoWidth = json['streams'][0]['width'];
                  final int videoHeight = json['streams'][0]['height'];

                  list.value.add(ARList(
                    arId: myAr.id,
                    arIndex: arVal,
                    height: ((videoContainerKey.globalPaintBounds!.height *
                                videoHeight) /
                            1920) /
                        1.5,
                    rotation: 0,
                    scale: 1,
                    width: ((videoContainerKey.globalPaintBounds!.width *
                                videoWidth) /
                            1080) /
                        1.5,
                    xPosition: 0,
                    yPosition: 0,
                    pathsForVideoFrames: _fullPathsOnline,
                    startingPositon: 0,
                    endingPosition: 0,
                    totalDuration: _fullPathsOnline.length / 30,
                    showAr: ValueNotifier(false),
                    audioPlayer: _player,
                    layerType: LayerType.AR,
                    arKey: containerKey,
                    fromFirebase: true,
                    mainFile: myAr.main,
                    alphaFile: myAr.alpha,
                    audioFlag: myAr.audioFlag,
                    finishedCaching: ValueNotifier(false),
                    ownerId: myAr.ownerId,
                    ownerName: myAr.ownerName,
                    selectedMaterial: ValueNotifier<bool>(true),
                    arCutOutFile: arCutOutFile,
                  ));

                  _controllerSeekTo(0);
                  if (!mounted) return;

                  arIndexVal.value += 1;

                  dev.log(
                      "list AR ${arIndexVal.value} | index counter == $arVal");
                  Get.back();
                  Get.back();
                  setState(() {});
                });
              });
            } catch (e) {
              print("error running ffprobe on image == ${e.toString()}");
            }

            // setState(() {
            //   loading = false;
            // });
            // print("folder name $folderName");

            //! #############################################################
          });
        });
      } catch (e) {
        print("FFmpeg Error ==== ${e.toString()}");
      }
    } else if (await Permission.storage.request().isDenied) {
      await openAppSettings();
    }
  }

  // * running ffmpeg to get video with no background
  Future<void> runFFmpegForAudioOnlyFiles({
    required int arVal,
    required File audioFile,
    required String songTitle,
    required String songArtist,
    required String songUrl,
    required String songAlbumCover,
  }) async {
    if (await Permission.storage.request().isGranted) {
      dev.log("AR INDEX == $arVal");
      // ignore: unawaited_futures
      CoolAlert.show(
        context: context,
        type: CoolAlertType.loading,
        barrierDismissible: false,
        text: "Loading Music file",
      );
      // Form matte file

      try {
        await FFprobeKit.execute(
                '-i \'${audioFile.path}\' -show_entries format=duration -v quiet -of json')
            .then((value) async {
          dev.log("OUTPUT! ==  ${await value.getOutput()}");
          await value.getOutput().then((mapOutput) async {
            final Map<String, dynamic> json = jsonDecode(mapOutput!);

            final String durationString = json['format']['duration'];

            print("durationString: $durationString");

            final String setDuration = double.parse(durationString) >=
                    _controller.video.value.duration.inSeconds
                ? _controller.video.value.duration.inSeconds.toString()
                : durationString;

            //! #############################################################

            final AudioPlayer? _player = AudioPlayer();

            final List<String> _fullPathsOnline = [songAlbumCover];

            final File musicFile = await saveMusicFiletoDevice(
                fileBytes: audioFile.readAsBytesSync(),
                fileName: audioFile.path);

            final File arCutOutFile = await getImage(url: _fullPathsOnline[0]);
            dev.log("ArCut out ois here  = ${arCutOutFile.path}");

            await _player!.setFilePath(audioFile.path);

            await _player.pause();

            final containerKey = GlobalKey();

            final String idValue = nanoid();

            list.value.add(ARList(
                arId: idValue,
                arIndex: arVal,
                height: 0,
                rotation: 0,
                scale: 1,
                width: 0,
                xPosition: 0,
                yPosition: 0,
                pathsForVideoFrames: _fullPathsOnline,
                startingPositon: 0,
                endingPosition: 0,
                totalDuration: double.parse(durationString),
                showAr: ValueNotifier(false),
                audioPlayer: _player,
                layerType: LayerType.Music,
                arKey: containerKey,
                fromFirebase: true,
                audioFlag: true,
                finishedCaching: ValueNotifier(true),
                ownerId: context.read<Authentication>().getUserId,
                ownerName: context.read<FirebaseOperations>().initUserName,
                selectedMaterial: ValueNotifier<bool>(true),
                musicFile: musicFile,
                youtubeArtistName: songArtist,
                youtubeTitle: songTitle,
                youtubeUrl: songUrl,
                youtubeAlbumCover: songAlbumCover,
                audioStart: 0,
                audioEnd: _player.duration!.inSeconds));

            _controllerSeekTo(1);
            if (!mounted) return;

            musicIndexVal.value += 1;

            dev.log(
                "list Music ${musicIndexVal.value} | index counter == $arVal");
            Get.back();
            Get.back();
            setState(() {});
          });
        });
      } catch (e) {
        print("FFmpeg Error ==== ${e.toString()}");
      }
    } else if (await Permission.storage.request().isDenied) {
      await openAppSettings();
    }
  }

  Future<File> saveMusicFiletoDevice(
      {required String fileName, required Uint8List fileBytes}) async {
    final Directory appDir = await getApplicationDocumentsDirectory();

    /// Generate Image Name
    final String imageName = fileName.split('/').last;
    final String timeNow = Timestamp.now().millisecondsSinceEpoch.toString();

    /// Create Empty File in app dir & fill with new image
    final File file = File(path.join(appDir.path, timeNow + imageName));
    file.writeAsBytesSync(fileBytes);

    return file;
  }

  Future<File> getImage({required String url}) async {
    /// Get Image from server
    final dio.Response res = await dio.Dio().get<List<int>>(
      url,
      options: dio.Options(
        responseType: dio.ResponseType.bytes,
      ),
    );

    /// Get App local storage
    final Directory appDir = await getApplicationDocumentsDirectory();

    /// Generate Image Name
    final String imageName = url.split('/').last;
    final String timeNow = Timestamp.now().millisecondsSinceEpoch.toString();

    /// Create Empty File in app dir & fill with new image
    final File file = File(path.join(appDir.path, timeNow + imageName));
    file.writeAsBytesSync(res.data as List<int>);

    return file;
  }

  // * running ffmpeg for Gif to add as Effect
  Future<void> runGifFFmpegCommand({
    required File gifFile,
    required int arVal,
    required bool fromFirebase,
    String? arId,
    String? ownerId,
    String? ownerName,
  }) async {
    final PermissionStatus req = await Permission.storage.request();
    dev.log("req == ${req}");

    if (req.isGranted) {
      dev.log("Owner id == $ownerId | OwnerName == $ownerName");
      // ignore: unawaited_futures
      CoolAlert.show(
        context: context,
        type: CoolAlertType.loading,
        barrierDismissible: false,
        text: "Loading Effect",
      );
      // Form matte file
      final Directory appDocument = await getTemporaryDirectory();
      final String rawDocument = appDocument.path;
      final String gifSeqFolder = "${rawDocument}/";

      final String timeNow = Timestamp.now().millisecondsSinceEpoch.toString();

      setState(() {
        folderName = gifSeqFolder;
      });

      try {
        await FFprobeKit.execute(
                '-i ${gifFile.path} -show_entries format=duration -v quiet -of json')
            .then((value) {
          value.getOutput().then((mapOutput) async {
            final Map<String, dynamic> json = jsonDecode(mapOutput!);

            String durationString = json['format']['duration'];

            print("durationString: $durationString");

            durationString =
                double.parse(durationString) < 1 ? "1" : durationString;

            final String setDuration = double.parse(durationString) >=
                    _controller.video.value.duration.inSeconds
                ? _controller.video.value.duration.inSeconds.toString()
                : durationString;

            //! #############################################################
            final String commandForGifSeqFile =
                '-y -i ${gifFile.path} -filter_complex "fps=30,scale=360:-1"  -preset ultrafast  ${gifSeqFolder}${arVal}${timeNow}gifSeq%d.png';

            final List<String> _fullPathsOffline = [];

            try {
              await FFmpegKit.execute(commandForGifSeqFile).then((rc) async {
                for (int i = 0;
                    i < (double.parse(setDuration).floor() * 30);
                    i++) {
                  _fullPathsOffline
                      .add("${gifSeqFolder}${arVal}${timeNow}gifSeq$i.png");
                }
              });

              _fullPathsOffline.removeAt(0);

              final _player = AudioPlayer();

              _player.pause();

              final containerKey = GlobalKey();

              await FFmpegKit.execute(
                      "-i ${gifFile.path} -crf 30 -preset ultrafast -filter_complex \"[0:v] split [a][b]; [a] palettegen=reserve_transparent=on [p]; [b][p] paletteuse\" -y ${gifSeqFolder}gifFile${timeNow}${arVal}.gif")
                  .then((vv) async {
                try {
                  await FFprobeKit.execute(
                          "-v error -show_streams -print_format json -i ${_fullPathsOffline[0]}")
                      .then((value) {
                    value.getOutput().then((imageDetails) {
                      final Map<String, dynamic> json =
                          jsonDecode(imageDetails!);

                      final int videoWidth = json['streams'][0]['width'];
                      final int videoHeight = json['streams'][0]['height'];

                      list.value.add(ARList(
                        arId: arId,
                        fromFirebase: fromFirebase,
                        arIndex: arVal,
                        height: ((videoContainerKey.globalPaintBounds!.height *
                                    videoHeight) /
                                960) /
                            1.3,
                        rotation: 0,
                        scale: 1,
                        width: ((videoContainerKey.globalPaintBounds!.width *
                                    videoWidth) /
                                540) /
                            1.3,
                        xPosition: 0,
                        yPosition: 0,
                        pathsForVideoFrames: _fullPathsOffline,
                        startingPositon: 0,
                        endingPosition: 0,
                        totalDuration: _fullPathsOffline.length / 30,
                        showAr: ValueNotifier(false),
                        audioPlayer: _player,
                        layerType: LayerType.Effect,
                        gifFilePath:
                            "${gifSeqFolder}gifFile${timeNow}${arVal}.gif",
                        arKey: containerKey,
                        finishedCaching: ValueNotifier(true),
                        ownerId: ownerId ??
                            Provider.of<Authentication>(context, listen: false)
                                .getUserId,
                        ownerName: ownerName ??
                            Provider.of<FirebaseOperations>(context,
                                    listen: false)
                                .initUserName,
                        selectedMaterial: ValueNotifier<bool>(true),
                      ));

                      _controllerSeekTo(0);

                      if (!mounted) return;

                      effectIndexVal.value += 1;
                      dev.log(
                          "list effect = ${effectIndexVal.value} || index counter == $arVal");
                      Get.back();
                      // Get.back();
                      setState(() {});
                    });
                  });
                } catch (e) {
                  print("error running ffprobe on image == ${e.toString()}");
                }
              });

              // Navigator.pop(context);

            } catch (e) {
              Navigator.pop(context);
              CoolAlert.show(
                context: context,
                type: CoolAlertType.error,
                text: "Error in loading effect",
              );
            }
            //! #############################################################
          });
        });
      } catch (e) {
        print("FFmpeg gif Error ==== ${e.toString()}");
      }
    } else if (await Permission.storage.request().isPermanentlyDenied) {
      await openAppSettings();
    }
  }

  //--------//
  //GESTURES//
  //--------//
  void _onHorizontalDragStart(DragStartDetails details) {
    final double margin = 25.0 + 0.0;
    final double pos = details.localPosition.dx;
    final double max = _rect.right;
    final double min = _rect.left;
    final double progressTrim = _getTrimPosition();
    final List<double> minMargin = [min - margin, min + margin];
    final List<double> maxMargin = [max - margin, max + margin];

    //IS TOUCHING THE GRID
    if (pos >= minMargin[0] && pos <= maxMargin[1]) {
      //TOUCH BOUNDARIES
      if (pos >= minMargin[0] && pos <= minMargin[1]) {
        _boundary.value = _FrameBoundaries.left;
      } else if (pos >= maxMargin[0] && pos <= maxMargin[1]) {
        _boundary.value = _FrameBoundaries.right;
      } else if (pos >= progressTrim - margin && pos <= progressTrim + margin) {
        _boundary.value = _FrameBoundaries.progress;
      } else if (pos >= minMargin[1] && pos <= maxMargin[0]) {
        _boundary.value = _FrameBoundaries.inside;
      } else {
        _boundary.value = _FrameBoundaries.none;
      }
      _updateControllerIsTrimming(true);
    } else {
      _boundary.value = _FrameBoundaries.none;
    }
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    final Offset delta = details.delta;
    switch (_boundary.value) {
      case _FrameBoundaries.left:
        final pos = _rect.topLeft + delta;
        // avoid minTrim to be bigger than maxTrim
        if (pos.dx > 0.0 && pos.dx < _rect.right - _trimWidth * 2) {
          _changeTrimRect(left: pos.dx, width: _rect.width - delta.dx);
        }
        break;
      case _FrameBoundaries.right:
        final pos = _rect.topRight + delta;
        // avoid maxTrim to be smaller than minTrim
        if (pos.dx < _trimLayout.width + 0.0 &&
            pos.dx > _rect.left + _trimWidth * 2) {
          _changeTrimRect(width: _rect.width + delta.dx);
        }
        break;
      case _FrameBoundaries.inside:
        final pos = _rect.topLeft + delta;
        // Move thumbs slider when the trimmer is on the edges
        if (_rect.topLeft.dx + delta.dx < 0.0 ||
            _rect.topRight.dx + delta.dx > _trimLayout.width) {
          _scrollController.position.moveTo(
            _scrollController.offset + delta.dx,
          );
        }
        if (pos.dx > 0.0 && pos.dx < _rect.right) {
          _changeTrimRect(left: pos.dx);
        }
        break;
      case _FrameBoundaries.progress:
        final double pos = details.localPosition.dx;
        if (pos >= _rect.left && pos <= _rect.right) _controllerSeekTo(pos);
        break;
      case _FrameBoundaries.none:
        break;
    }
  }

  void _onHorizontalDragEnd(_) {
    if (_boundary.value != _FrameBoundaries.none) {
      final double _progressTrim = _getTrimPosition();
      if (_progressTrim >= _rect.right || _progressTrim < _rect.left) {
        _controllerSeekTo(_progressTrim);
      }
      _updateControllerIsTrimming(false);
      if (_boundary.value != _FrameBoundaries.progress) {
        if (_boundary.value != _FrameBoundaries.right) {
          _controllerSeekTo(_rect.left);
        }
        _updateControllerTrim();
      }
    }
  }

  //----//
  //RECT//
  //----//
  void _changeTrimRect({double? left, double? width}) {
    left = left ?? _rect.left;
    width = width ?? _rect.width;

    final Duration diff = _getDurationDiff(left, width);

    if (left >= 0 &&
        left + width - 0.0 <= _trimLayout.width &&
        diff <= _controller.maxDuration) {
      // _rect = Rect.fromLTWH(left, _rect.top, width, _rect.height);
      // _updateControllerTrim();
    }
  }

  void _createTrimRect() {
    _rect = Rect.fromPoints(
      Offset(_controller.minTrim * _fullLayout.width + 0.0, 0.0),
      Offset(_controller.maxTrim * _fullLayout.width + 0.0, height),
    );
  }

  //----//
  //MISC//
  //----//
  void _controllerSeekTo(double position) async {
    await _videoController.seekTo(
      _videoController.value.duration * (position / _fullLayout.width),
    );

    for (ARList ar in list.value) {
      if (position >= ar.startingPositon! &&
          position <= ar.startingPositon! + ar.endingPosition!) {
        _controller.video.pause();
        if (ar.finishedCaching!.value == true && ar.arState != null) {
          ar.arState!.pause();
          ar.arState!.skip(position);
        }
        if (ar.audioFlag == true && ar.finishedCaching!.value == true) {
          ar.audioPlayer!.pause();
          ar.audioPlayer!.seek(Duration(
              seconds: int.parse(
                  "${(ar.arState!.currentTime.ceil() / 1000).toStringAsFixed(0)}")));
        }
        ar.showAr!.value = true;
      } else if (position < ar.startingPositon!) {
        _controller.video.pause();
        ar.arState!.pause();
        if (ar.audioFlag == true) {
          ar.audioPlayer!.pause();
          ar.audioPlayer!.seek(Duration(seconds: 0));
        }
        ar.showAr!.value = false;
        ar.arState!.skip(0);
      } else if (position > ar.startingPositon! + ar.endingPosition!) {
        _controller.video.pause();
        ar.arState!.pause();
        if (ar.audioFlag == true) {
          ar.audioPlayer!.pause();
          ar.audioPlayer!.seek(Duration(
              seconds: int.parse(
                  "${(ar.arState!.totalTime.ceil() / 1000).toStringAsFixed(0)}")));
        }
        ar.showAr!.value = false;
        ar.arState!.skip(ar.arState!.totalTime);
      }
    }
  }

  void _updateControllerTrim() {
    final double width = _fullLayout.width;
    _controller.updateTrim((_rect.left + _thumbnailPosition - 0.0) / width,
        (_rect.right + _thumbnailPosition - 0.0) / width);
  }

  void _updateControllerIsTrimming(bool value) {
    if (_boundary.value != _FrameBoundaries.none &&
        _boundary.value != _FrameBoundaries.progress) {
      _controller.isTrimming = value;
    }
  }

  double _getTrimPosition() {
    _bgProgress.value =
        _fullLayout.width * _controller.trimPosition - _thumbnailPosition + 0.0;
    // print(
    //     "thumbnail position ${_fullLayout.width * _controller.trimPosition - _thumbnailPosition + 0.0}");
    // print("total width ${_fullLayout.width}");
    // print(_controller.video.value.position);
    return _fullLayout.width * _controller.trimPosition -
        _thumbnailPosition +
        0.0;
  }

  double getRatioDuration() {
    return _controller.videoDuration.inMilliseconds /
        _controller.maxDuration.inMilliseconds;
  }

  Duration _getDurationDiff(double left, double width) {
    final double min = (left - 0.0) / _fullLayout.width;
    final double max = (left + width - 0.0) / _fullLayout.width;
    final Duration duration = _videoController.value.duration;
    return (duration * max) - (duration * min);
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final maxWidth = MediaQuery.of(context).size.width * 0.9;
    final ArVideoCreation arVideoCreation =
        Provider.of<ArVideoCreation>(context, listen: false);
    return AnketGiphyGetWrapper(
        giphy_api_key: giphyApiKey,
        builder: (stream, giphyGetWrapper) {
          stream.listen((gif) async {
            // ! USe this link format https://i.giphy.com/media/${URL_PART}/giphy.gif
            CoolAlert.show(
                context: context,
                type: CoolAlertType.loading,
                barrierDismissible: false,
                text: "Connecting Giphy ");
            dev.log("here");

            if (effectIndexVal.value <= 10) {
              if (list.value.isNotEmpty) {
                list.value.last.layerType == LayerType.AR
                    ? indexCounter.value = indexCounter.value + 2
                    : indexCounter.value = indexCounter.value + 1;
              }

              if (indexCounter.value <= 0) {
                indexCounter.value = 1;
              }

              dev.log("index value before in gif == ${indexCounter.value}");

              final File gifFile = await getImage(
                  url: "https://i.giphy.com/media/${gif.id}/giphy.gif");
              Get.back();

              await runGifFFmpegCommand(
                arVal: indexCounter.value,
                gifFile: File(gifFile.path),
                fromFirebase: false,
              );
            } else {
              CoolAlert.show(
                context: context,
                type: CoolAlertType.info,
                title: "Max Effects's Reached",
                text: "You can only have 10 effects's",
              );
            }

            // setState(() {
            //   currentGif = gif;
            // });
          });
          return Scaffold(
            backgroundColor: Colors.grey,
            body: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            _videoController.value.isInitialized
                                ? Container(
                                    key: videoContainerKey,
                                    child: AspectRatio(
                                      aspectRatio:
                                          _videoController.value.aspectRatio,
                                      child: VideoViewer(
                                        controller: _controller,
                                      ),
                                    ),
                                  )
                                : Center(child: CircularProgressIndicator()),
                            Positioned(
                              top: 0,
                              left: 0,
                              right: 0,
                              bottom: 0,
                              child: LayoutBuilder(
                                  builder: (context, videoConstaints) {
                                return Stack(
                                  children: list.value.map((value) {
                                    return ValueListenableBuilder<Object>(
                                        valueListenable: value.showAr!,
                                        builder: (context, boolVal, _) {
                                          return value.pathsForVideoFrames !=
                                                  null
                                              ? Opacity(
                                                  opacity:
                                                      boolVal == true ? 1 : 0,
                                                  child: GestureDetector(
                                                    onScaleStart: (details) {
                                                      if (value == null) return;
                                                      _initPos =
                                                          details.focalPoint;
                                                      _currentPos = Offset(
                                                          value.xPosition!,
                                                          value.yPosition!);
                                                      _currentScale =
                                                          value.scale;
                                                      _currentRotation =
                                                          value.rotation;
                                                    },
                                                    onScaleUpdate: (details) {
                                                      if (value == null) return;
                                                      final delta =
                                                          details.focalPoint -
                                                              _initPos!;
                                                      final left = (delta.dx /
                                                              screen!.width) +
                                                          _currentPos!.dx;
                                                      final top = (delta.dy /
                                                              screen!.height) +
                                                          _currentPos!.dy;

                                                      setState(() {
                                                        value.xPosition =
                                                            Offset(left, top)
                                                                .dx;
                                                        value.yPosition =
                                                            Offset(left, top)
                                                                .dy;
                                                        value.rotation = details
                                                                .rotation +
                                                            _currentRotation!;
                                                        value.scale =
                                                            details.scale *
                                                                _currentScale!;
                                                      });

                                                      // !Found rotation in degrees here
                                                      dev.log(
                                                          "scale == ${value.scale}");
                                                      dev.log(
                                                          "rot = ${value.rotation! * 180 / pi}");
                                                    },
                                                    child: Stack(
                                                      children: [
                                                        Positioned(
                                                          right: -value
                                                                  .xPosition! *
                                                              screen!.width,
                                                          bottom: -value
                                                                  .yPosition! *
                                                              screen!.height,
                                                          child:
                                                              Transform.scale(
                                                            scale: value.scale,
                                                            child: Transform
                                                                .rotate(
                                                              angle: value
                                                                  .rotation!,
                                                              child: Container(
                                                                key:
                                                                    value.arKey,
                                                                height: value
                                                                    .height,
                                                                width:
                                                                    value.width,
                                                                child:
                                                                    FittedBox(
                                                                  fit: BoxFit
                                                                      .cover,
                                                                  child:
                                                                      Listener(
                                                                    onPointerDown:
                                                                        (details) {
                                                                      // _initPos = details.position;
                                                                      // _currentPos = Offset(
                                                                      //     value.xPosition!, value.yPosition!);
                                                                      // _currentScale = value.scale;
                                                                      // _currentRotation = value.rotation;
                                                                      // print(" _initPos = ${_initPos!.dx}");
                                                                      setState(
                                                                          () {
                                                                        _controller
                                                                            .video
                                                                            .pause();

                                                                        selected =
                                                                            value;

                                                                        for (ARList arPlaying
                                                                            in list.value) {
                                                                          if (arPlaying.showAr!.value ==
                                                                              true) {
                                                                            arPlaying.arState!.pause();
                                                                            if (arPlaying.audioFlag ==
                                                                                true) {
                                                                              arPlaying.audioPlayer!.pause();
                                                                            }
                                                                          }
                                                                        }
                                                                      });
                                                                    },
                                                                    onPointerUp:
                                                                        (details) {
                                                                      _initPos =
                                                                          details
                                                                              .position;
                                                                      _currentPos = Offset(
                                                                          value
                                                                              .xPosition!,
                                                                          value
                                                                              .yPosition!);
                                                                      _currentScale =
                                                                          value
                                                                              .scale;
                                                                      _currentRotation =
                                                                          value
                                                                              .rotation;
                                                                    },
                                                                    child:
                                                                        InkWell(
                                                                      onTap:
                                                                          () {},
                                                                      child:
                                                                          Container(
                                                                        height:
                                                                            value.height,
                                                                        width: value
                                                                            .width,
                                                                        child:
                                                                            ImageSequenceAnimator(
                                                                          "",
                                                                          "imgSeq",
                                                                          1,
                                                                          0,
                                                                          "png",
                                                                          30,
                                                                          isOnline: value.layerType == LayerType.AR
                                                                              ? true
                                                                              : false,
                                                                          key: value.layerType == LayerType.AR
                                                                              ? Key("online")
                                                                              : Key("offline"),
                                                                          fullPaths:
                                                                              value.pathsForVideoFrames,
                                                                          onReadyToPlay:
                                                                              (ImageSequenceAnimatorState _imageSequenceAnimator) {
                                                                            dev.log("Its ready now lad!");
                                                                            value.arState =
                                                                                _imageSequenceAnimator;
                                                                            if (value.layerType ==
                                                                                LayerType.AR)
                                                                              value.finishedCaching = ValueNotifier(true);
                                                                          },
                                                                          // cacheProgressIndicatorBuilder:
                                                                          //     (context,
                                                                          //         progress) {
                                                                          //   return CircularProgressIndicator(
                                                                          //     value: progress !=
                                                                          //             null
                                                                          //         ? progress
                                                                          //         : 1,
                                                                          //     backgroundColor:
                                                                          //         constantColors.navButton,
                                                                          //   );
                                                                          // },
                                                                          waitUntilCacheIsComplete:
                                                                              true,
                                                                          fps:
                                                                              35,
                                                                          frameHeight:
                                                                              value.height!,
                                                                          frameWidth:
                                                                              value.width!,
                                                                          isAutoPlay:
                                                                              false,
                                                                          onPlaying: value.layerType == LayerType.AR
                                                                              ? onOnlinePlaying
                                                                              : null,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    // child: Image.network(value.name),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                )
                                              : SizedBox();
                                        });
                                  }).toList(),
                                );
                              }),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Container(
                      width: size.width,
                      height: 2,
                      color: Colors.white,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _controller.isPlaying
                                  ? _controller.video.pause()
                                  : _controller.video.play();

                              for (ARList arPlaying in list.value) {
                                if (arPlaying.showAr!.value == true) {
                                  arPlaying.arState!.isPlaying &&
                                          arPlaying.finishedCaching!.value ==
                                              true
                                      ? arPlaying.arState!.pause()
                                      : arPlaying.arState!.play();

                                  arPlaying.audioPlayer!.playing &&
                                          arPlaying.audioFlag == true
                                      ? arPlaying.audioPlayer!.pause()
                                      : arPlaying.audioPlayer!.play();
                                }
                              }
                            });
                          },
                          icon: Icon(
                            !_controller.isPlaying
                                ? Icons.play_arrow
                                : Icons.pause,
                            color: constantColors.whiteColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          // For Foreground videos
                          Row(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.only(right: 20, left: 10),
                                child: Icon(
                                  Icons.collections,
                                  color: Colors.white,
                                  size: 25,
                                ),
                              ),
                              Expanded(
                                child: ValueListenableBuilder<List<ARList>>(
                                  valueListenable: list,
                                  builder: (context, arListValFull, child) {
                                    return LayoutBuilder(
                                        builder: (context, constaints) {
                                      final Size trimLayout = Size(
                                          constaints.maxWidth - 0.0 * 2,
                                          constaints.maxHeight);
                                      final Size fullLayout = Size(
                                          trimLayout.width *
                                              (_ratio! > 1 ? _ratio! : 1),
                                          constaints.maxHeight);

                                      return Column(
                                        children: [
                                          Column(
                                            children:
                                                arListValFull.map((arVal) {
                                              return InkWell(
                                                onDoubleTap: () {
                                                  dev.log("this");
                                                  setState(() {
                                                    selected = arVal;
                                                  });
                                                },
                                                onTap: () async {
                                                  if (arVal.audioFlag == true &&
                                                      arVal.layerType !=
                                                          LayerType.Music) {
                                                    showAlertDialog(
                                                        context: context,
                                                        ar: arVal);
                                                  } else {
                                                    _controllerSeekTo(1);
                                                    setState(() {
                                                      _controller.video.pause();

                                                      for (ARList arPlaying
                                                          in list.value) {
                                                        if (arPlaying.showAr!
                                                                .value ==
                                                            true) {
                                                          arPlaying.arState!
                                                              .pause();

                                                          arPlaying.audioPlayer!
                                                              .pause();
                                                        }
                                                      }
                                                    });
                                                    await showMusicAdjustBottomSheet(
                                                        context: context,
                                                        ar: arVal);
                                                  }
                                                },
                                                child: Container(
                                                  width: fullLayout.width,
                                                  height: 50,
                                                  color:
                                                      constantColors.greyColor,
                                                  child: Stack(
                                                    alignment: Alignment.center,
                                                    children: [
                                                      AnimatedPositioned(
                                                        duration:
                                                            const Duration(
                                                                milliseconds:
                                                                    100),
                                                        left: arVal
                                                            .startingPositon,
                                                        key: Key("This"),
                                                        child: Container(
                                                          height: 50,
                                                          width: arVal.finishedCaching!
                                                                      .value ==
                                                                  true
                                                              ? arVal
                                                                  .endingPosition
                                                              : 30.w,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: arVal.layerType ==
                                                                    LayerType.AR
                                                                ? constantColors
                                                                    .mainColor
                                                                : arVal.layerType ==
                                                                        LayerType
                                                                            .Effect
                                                                    ? constantColors
                                                                        .darkColor
                                                                    : constantColors
                                                                        .black,
                                                            border: Border.all(
                                                              color:
                                                                  Colors.white,
                                                              width: selected ==
                                                                      arVal
                                                                  ? 3
                                                                  : 1,
                                                            ),
                                                          ),
                                                          alignment:
                                                              Alignment.center,
                                                          child: Container(
                                                            child: arVal.finishedCaching!
                                                                            .value ==
                                                                        true &&
                                                                    arVal.layerType ==
                                                                        LayerType
                                                                            .AR
                                                                ? Image.file(arVal
                                                                    .arCutOutFile!)
                                                                : arVal.layerType ==
                                                                        LayerType
                                                                            .Effect
                                                                    ? Image
                                                                        .file(
                                                                        File(arVal
                                                                            .pathsForVideoFrames![1]),
                                                                      )
                                                                    : arVal.layerType ==
                                                                            LayerType.Music
                                                                        ? Row(
                                                                            children: [
                                                                              Container(
                                                                                width: 50,
                                                                                child: ImageNetworkLoader(imageUrl: arVal.youtubeAlbumCover!),
                                                                              ),
                                                                              SizedBox(
                                                                                width: 10,
                                                                              ),
                                                                              Text(
                                                                                "${arVal.youtubeArtistName} - ${arVal.youtubeTitle!}",
                                                                                style: TextStyle(color: constantColors.whiteColor),
                                                                              ),
                                                                            ],
                                                                          )
                                                                        : Center(
                                                                            child:
                                                                                CircularProgressIndicator(),
                                                                          ),
                                                          ),
                                                        ),
                                                      ),
                                                      GestureDetector(
                                                        onPanStart: (details) {
                                                          _controller.video
                                                              .pause();
                                                        },
                                                        onPanUpdate: (details) {
                                                          if (details.localPosition
                                                                      .dx >=
                                                                  0 &&
                                                              details.localPosition
                                                                      .dx <=
                                                                  fullLayout
                                                                          .width -
                                                                      arVal
                                                                          .endingPosition!) {
                                                            setState(() {
                                                              arVal.startingPositon =
                                                                  details
                                                                      .localPosition
                                                                      .dx;
                                                            });
                                                          }

                                                          // ! to get the starting point in seconds

                                                          // print((arVal.startingPositon! /
                                                          //         _fullLayout.width) *
                                                          //     _videoController.value
                                                          //         .duration.inSeconds);
                                                          // ^ this gives the starting point of the AR video in seconds
                                                          // next we need to convert it from seconds to HH:mm:ss

                                                          // _controller.video.pause();

                                                          // print(
                                                          //     "ending time ${arVal.pathsForVideoFrames!.length / 30}");

                                                          for (ARList arElement
                                                              in list.value) {
                                                            if (arElement
                                                                    .arState!
                                                                    .isPlaying ||
                                                                arElement
                                                                    .audioPlayer!
                                                                    .playing) {
                                                              arElement.arState!
                                                                  .pause();
                                                              if (arElement
                                                                      .audioFlag ==
                                                                  true) {
                                                                arElement
                                                                    .audioPlayer!
                                                                    .pause();
                                                              }
                                                            }
                                                          }
                                                        },
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10),
                                            child: Container(
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                    child: ElevatedButton(
                                                      style: ButtonStyle(
                                                        foregroundColor:
                                                            MaterialStateProperty
                                                                .all<Color>(
                                                                    Colors
                                                                        .white),
                                                        backgroundColor:
                                                            MaterialStateProperty.all<
                                                                    Color>(
                                                                constantColors
                                                                    .navButton),
                                                        shape: MaterialStateProperty
                                                            .all<
                                                                RoundedRectangleBorder>(
                                                          RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20),
                                                          ),
                                                        ),
                                                      ),
                                                      onPressed: () async {
                                                        setState(() {
                                                          _controller.video
                                                              .pause();
                                                        });
                                                        final bool showMessage =
                                                            SharedPreferencesHelper
                                                                .getBool(
                                                                    "dontShowMessage");

                                                        if (showMessage ==
                                                            false) {
                                                          final ValueNotifier<
                                                                  bool>
                                                              dontShowMessage =
                                                              ValueNotifier<
                                                                  bool>(false);
                                                          await Get.dialog(
                                                            SimpleDialog(
                                                              children: [
                                                                Container(
                                                                  width: 100.w,
                                                                  child: Text(
                                                                    "AR Quality in the Video Editor may seem low resolution.\nThis is to be able to process multiple layers together.\nPlease go to the next page to see the actual quality",
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  height: 10,
                                                                ),
                                                                ValueListenableBuilder<
                                                                        bool>(
                                                                    valueListenable:
                                                                        dontShowMessage,
                                                                    builder:
                                                                        (context,
                                                                            messageOpt,
                                                                            _) {
                                                                      return ListTile(
                                                                        title: Text(
                                                                            "Dont show message again"),
                                                                        trailing:
                                                                            Checkbox(
                                                                          value:
                                                                              dontShowMessage.value,
                                                                          onChanged:
                                                                              (v) {
                                                                            dontShowMessage.value =
                                                                                !dontShowMessage.value;
                                                                          },
                                                                        ),
                                                                      );
                                                                    }),
                                                                SizedBox(
                                                                  height: 10,
                                                                ),
                                                                Padding(
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              10),
                                                                  child:
                                                                      ElevatedButton(
                                                                    style:
                                                                        ButtonStyle(
                                                                      foregroundColor: MaterialStateProperty.all<
                                                                              Color>(
                                                                          Colors
                                                                              .white),
                                                                      backgroundColor: MaterialStateProperty.all<
                                                                              Color>(
                                                                          constantColors
                                                                              .navButton),
                                                                      shape: MaterialStateProperty
                                                                          .all<
                                                                              RoundedRectangleBorder>(
                                                                        RoundedRectangleBorder(
                                                                          borderRadius:
                                                                              BorderRadius.circular(20),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    onPressed:
                                                                        () {
                                                                      SharedPreferencesHelper.setBool(
                                                                          "dontShowMessage",
                                                                          dontShowMessage
                                                                              .value);
                                                                      Get.back();
                                                                    },
                                                                    child: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        Icon(
                                                                          Icons
                                                                              .check,
                                                                          color:
                                                                              Colors.white,
                                                                        ),
                                                                        Text(
                                                                          LocaleKeys
                                                                              .understood
                                                                              .tr(),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          );
                                                        }
                                                        selectArBottomSheet(
                                                            context, size);
                                                      },
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Icon(
                                                            Icons.add,
                                                            color: Colors.white,
                                                          ),
                                                          Text(
                                                            LocaleKeys.addar
                                                                .tr(),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 10,
                                                  ),
                                                  Expanded(
                                                    child: AnimatedBuilder(
                                                        animation:
                                                            Listenable.merge([
                                                          effectIndexVal,
                                                          arIndexVal,
                                                          musicIndexVal,
                                                        ]),
                                                        builder: (context, _) {
                                                          return ElevatedButton(
                                                            style: ButtonStyle(
                                                              foregroundColor:
                                                                  MaterialStateProperty.all<
                                                                          Color>(
                                                                      Colors
                                                                          .white),
                                                              backgroundColor:
                                                                  MaterialStateProperty.all<
                                                                          Color>(
                                                                      constantColors
                                                                          .navButton),
                                                              shape: MaterialStateProperty
                                                                  .all<
                                                                      RoundedRectangleBorder>(
                                                                RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              20),
                                                                ),
                                                              ),
                                                            ),
                                                            onPressed:
                                                                () async {
                                                              setState(() {
                                                                _controller
                                                                    .video
                                                                    .pause();
                                                              });
                                                              // _openFileManager();
                                                              // ! get giphy here
                                                              giphyGetWrapper
                                                                  .getGif(
                                                                '',
                                                                context,
                                                              );
                                                              // selectEffectBottomSheet(
                                                              //   context: context,
                                                              //   size: size,
                                                              //   effectValIndex:
                                                              //       effectIndexVal
                                                              //           .value,
                                                              //   arValIndex:
                                                              //       arIndexVal.value,
                                                              // );
                                                            },
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Icon(
                                                                  Icons.add,
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                                Text(LocaleKeys
                                                                    .addeffect
                                                                    .tr()),
                                                              ],
                                                            ),
                                                          );
                                                        }),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10),
                                            child: Container(
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                    child: ElevatedButton(
                                                      style: ButtonStyle(
                                                        foregroundColor:
                                                            MaterialStateProperty
                                                                .all<Color>(
                                                                    Colors
                                                                        .white),
                                                        backgroundColor:
                                                            MaterialStateProperty.all<
                                                                    Color>(
                                                                constantColors
                                                                    .navButton),
                                                        shape: MaterialStateProperty
                                                            .all<
                                                                RoundedRectangleBorder>(
                                                          RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20),
                                                          ),
                                                        ),
                                                      ),
                                                      onPressed: () async {
                                                        if (list
                                                            .value.isNotEmpty) {
                                                          if (musicIndexVal
                                                                  .value <=
                                                              1) {
                                                            dev.log(musicIndexVal
                                                                .value
                                                                .toString());
                                                            setState(() {
                                                              _controller.video
                                                                  .pause();
                                                            });

                                                            _selectAudioOption(
                                                                context);
                                                          } else {
                                                            await Get.dialog(
                                                              SimpleDialog(
                                                                children: [
                                                                  Padding(
                                                                    padding:
                                                                        EdgeInsets.all(
                                                                            10),
                                                                    child: Text(
                                                                        "You can only add 2 Music Layers"),
                                                                  ),
                                                                ],
                                                              ),
                                                            );
                                                          }
                                                        } else {
                                                          await Get.dialog(
                                                            SimpleDialog(
                                                              children: [
                                                                Padding(
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              10),
                                                                  child: Text(
                                                                      "Please add an AR or Effect first before adding the Music Layer"),
                                                                ),
                                                              ],
                                                            ),
                                                          );
                                                        }
                                                      },
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Icon(
                                                            Icons.add,
                                                            color: Colors.white,
                                                          ),
                                                          Text(
                                                            "Add Music",
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      );

                                      // return Container(
                                      //   color: constantColors.greyColor,
                                      //   child: Row(
                                      //     mainAxisAlignment: MainAxisAlignment.center,
                                      //     children: [
                                      //       ElevatedButton(
                                      //         onPressed: () async {
                                      //           await runFFmpegCommand();
                                      //           setState(() {
                                      //             _showAr.value = false;
                                      //           });
                                      //         },
                                      //         child: Text("Select AR"),
                                      //       ),
                                      //     ],
                                      //   ),
                                      // );

                                      // return arContainerWidth != 0
                                      //     ? Container(
                                      //         width: fullLayout.width,
                                      //         height: 50,
                                      //         color: constantColors.greyColor,
                                      //         child: Stack(
                                      //           alignment: Alignment.center,
                                      //           children: [
                                      //             AnimatedPositioned(
                                      //               duration:
                                      //                   const Duration(milliseconds: 100),
                                      //               left: posX,
                                      //               key: const ValueKey("item 1"),
                                      //               child: Container(
                                      //                 height: 50,
                                      //                 width: arContainerWidth,
                                      //                 decoration: BoxDecoration(
                                      //                   color: constantColors.mainColor,
                                      //                   border: Border.all(
                                      //                     color: Colors.white,
                                      //                     width: 1,
                                      //                   ),
                                      //                 ),
                                      //                 alignment: Alignment.center,
                                      //                 child: Container(
                                      //                   child: Image.file(
                                      //                       File(_fullPathsOffline[0])),
                                      //                 ),
                                      //               ),
                                      //             ),
                                      //             GestureDetector(
                                      //               onPanStart: (details) {
                                      //                 _controller.video.pause();
                                      //               },
                                      //               onPanUpdate: (details) {
                                      //                 if (details.localPosition.dx > 0 &&
                                      //                     details.localPosition.dx <=
                                      //                         fullLayout.width -
                                      //                             arContainerWidth) {
                                      //                   setState(() {
                                      //                     posX = details.localPosition.dx;
                                      //                   });
                                      //                 }

                                      //                 _imgSeqProgress.value = posX;

                                      //                 print(
                                      //                     "posX == ${_imgSeqProgress.value}");
                                      //               },
                                      //             )
                                      //           ],
                                      //         ),
                                      //       )
                                      //     : Container(
                                      //         color: constantColors.greyColor,
                                      //         child: Row(
                                      //           mainAxisAlignment:
                                      //               MainAxisAlignment.center,
                                      //           children: [
                                      //             ElevatedButton(
                                      //               onPressed: () async {
                                      //                 await runFFmpegCommand();
                                      //                 setState(() {
                                      //                   _showAr.value = false;
                                      //                 });
                                      //               },
                                      //               child: Text("Select AR"),
                                      //             ),
                                      //           ],
                                      //         ),
                                      //       );
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),

                          // For background videos
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      right: 20, left: 10),
                                  child: Icon(
                                    EvaIcons.videoOutline,
                                    color: Colors.white,
                                    size: 25,
                                  ),
                                ),
                                Expanded(
                                  child: _controller.video.value.isInitialized
                                      ? Container(
                                          margin: EdgeInsets.symmetric(
                                              vertical: height / 4),
                                          child: LayoutBuilder(
                                              builder: (_, contrainst) {
                                            final Size trimLayout = Size(
                                                contrainst.maxWidth - 0.0 * 2,
                                                contrainst.maxHeight);
                                            final Size fullLayout = Size(
                                                trimLayout.width *
                                                    (_ratio! > 1 ? _ratio! : 1),
                                                contrainst.maxHeight);
                                            _fullLayout = fullLayout;

                                            if (_trimLayout != trimLayout) {
                                              _trimLayout = trimLayout;
                                              _createTrimRect();
                                            }

                                            return InkWell(
                                              onLongPress: () {
                                                showBgAlertDialog(
                                                    context: context,
                                                    controller: _controller);
                                              },
                                              child: SizedBox(
                                                  width: _fullLayout.width,
                                                  child: Stack(children: [
                                                    NotificationListener<
                                                        ScrollNotification>(
                                                      child:
                                                          SingleChildScrollView(
                                                        controller:
                                                            _scrollController,
                                                        scrollDirection:
                                                            Axis.horizontal,
                                                        child: Container(
                                                          margin: EdgeInsets
                                                              .symmetric(
                                                                  horizontal:
                                                                      0.0),
                                                          child: Column(
                                                            children: [
                                                              SizedBox(
                                                                height: height,
                                                                width:
                                                                    _fullLayout
                                                                        .width,
                                                                child: FrameThumbnailSlider(
                                                                    controller:
                                                                        _controller,
                                                                    height:
                                                                        height,
                                                                    quality: 1),
                                                              ),
                                                              SizedBox(
                                                                width:
                                                                    _fullLayout
                                                                        .width,
                                                                child:
                                                                    FrameTimeline(
                                                                  controller:
                                                                      _controller,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      onNotification:
                                                          (notification) {
                                                        _boundary.value =
                                                            _FrameBoundaries
                                                                .inside;
                                                        _updateControllerIsTrimming(
                                                            true);
                                                        if (notification
                                                            is ScrollEndNotification) {
                                                          _thumbnailPosition =
                                                              notification
                                                                  .metrics
                                                                  .pixels;
                                                          _controllerSeekTo(
                                                              _rect.left);
                                                          for (ARList element
                                                              in list.value) {
                                                            element.arState!
                                                                .skip(
                                                                    _rect.left);
                                                            if (element
                                                                    .audioFlag ==
                                                                true) {
                                                              element
                                                                  .audioPlayer!
                                                                  .seek(Duration(
                                                                      seconds: _rect
                                                                          .left
                                                                          .toInt()));
                                                            }
                                                          }
                                                          _updateControllerIsTrimming(
                                                              false);
                                                          _updateControllerTrim();
                                                        }
                                                        return true;
                                                      },
                                                    ),
                                                    GestureDetector(
                                                      onHorizontalDragUpdate:
                                                          _onHorizontalDragUpdate,
                                                      onHorizontalDragStart:
                                                          _onHorizontalDragStart,
                                                      onHorizontalDragEnd:
                                                          _onHorizontalDragEnd,
                                                      behavior: HitTestBehavior
                                                          .opaque,
                                                      child: AnimatedBuilder(
                                                        animation:
                                                            Listenable.merge([
                                                          _controller,
                                                          _videoController,
                                                        ]),
                                                        builder: (_, __) {
                                                          return CustomPaint(
                                                            size:
                                                                Size.fromHeight(
                                                                    height),
                                                            painter:
                                                                FrameSliderPainter(
                                                              _rect,
                                                              _getTrimPosition(),
                                                              _controller
                                                                  .trimStyle,
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    )
                                                  ])),
                                            );
                                          }),
                                        )
                                      : Container(
                                          height: 90,
                                          child: Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                        ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: BottomAppBar(
              color: constantColors.navButton,
              child: Container(
                height: 60,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 25,
                      ),
                      onPressed: () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => FeedPage(
                                      pageIndexValue: 2,
                                    )));
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        FontAwesomeIcons.trashAlt,
                        color: Colors.white,
                        size: 25,
                      ),
                      onPressed: () {
                        _controllerSeekTo(0);
                        if (selected != null) {
                          CoolAlert.show(
                            context: context,
                            type: CoolAlertType.warning,
                            title:
                                "Delete ${selected!.layerType == LayerType.Effect ? 'Effect' : selected!.layerType == LayerType.AR ? 'AR' : 'Music'}?",
                            showCancelBtn: true,
                            onConfirmBtnTap: () async {
                              dev.log(
                                  "start indexcounter == ${indexCounter.value}");

                              final indexVal = list.value.indexWhere(
                                  (element) =>
                                      element.arIndex! == selected!.arIndex!);

                              dev.log(
                                  "selected arindex = ${selected!.arIndex} | || ar type == ${selected!.layerType} || index val; = $indexVal ");
                              // if (selected!.layerType == LayerType.AR) {
                              //   final indexVal = list.value.indexWhere(
                              //       (element) =>
                              //           element.arIndex! == selected!.arIndex!);

                              //   final int lastAtIndex = indexCounter.value;

                              //   for (int i = indexVal + 1;
                              //       i < lastAtIndex;
                              //       i++) {
                              //     // "list index $i goes from arIndex of ${list.value[i].arIndex} to ${list.value[i].arIndex! - 2}"
                              //     list.value[i].arIndex =
                              //         list.value[i].arIndex! - 2;
                              //   }
                              // } else {
                              // final indexVal = list.value.indexWhere(
                              //     (element) =>
                              //         element.arIndex! == selected!.arIndex!);

                              //   final int lastAtIndex = indexCounter.value;

                              //   for (int i = indexVal; i < lastAtIndex; i++) {
                              //     // "list index $i goes from arIndex of ${list.value[i].arIndex} to ${list.value[i].arIndex! - 1}"
                              //     list.value[i].arIndex =
                              //         list.value[i].arIndex! - 1;
                              //   }
                              // }

                              // await deleteFile(selected!.pathsForVideoFrames!);

                              // Future.delayed(Duration(seconds: 2));

                              for (final ARList element in list.value) {
                                if (selected!.arIndex! > element.arIndex!) {
                                  dev.log(
                                      "arIndex == ${element.arIndex!} || ar type == ${element.layerType} ignore this");
                                }

                                if (selected!.arIndex! < element.arIndex!) {
                                  switch (selected!.layerType!) {
                                    case LayerType.AR:
                                      dev.log(
                                          "arIndex == ${element.arIndex!} || ar type == ${element.layerType} === move - 2 places (before moving)");
                                      element.arIndex = element.arIndex! - 2;
                                      dev.log(
                                          "arIndex == ${element.arIndex! - 2} || ar type == ${element.layerType} === moved (after moving)");

                                      break;
                                    case LayerType.Effect:
                                      dev.log(
                                          "arIndex == ${element.arIndex!} || ar type == ${element.layerType} === move - 1 place (before moving)");
                                      element.arIndex = element.arIndex! - 1;
                                      dev.log(
                                          "arIndex == ${element.arIndex! - 1} || ar type == ${element.layerType} === moved (after moving)");

                                      break;
                                    case LayerType.Music:
                                      dev.log(
                                          "arIndex == ${element.arIndex!} || ar type == ${element.layerType} === move - 1 place (before moving)");
                                      element.arIndex = element.arIndex! - 1;
                                      dev.log(
                                          "arIndex == ${element.arIndex! - 1} || ar type == ${element.layerType} === moved (after moving)");

                                      break;
                                  }
                                }

                                if (selected!.arIndex! == element.arIndex) {
                                  dev.log(
                                      "arIndex == ${element.arIndex!} || ar type == ${element.layerType} === remove this");
                                  dev.log(
                                      "len before removing == ${list.value.length}");

                                  // list.value.remove(selected);
                                  dev.log(
                                      "len after removing == ${list.value.length - 1}");
                                }
                              }

                              switch (selected!.layerType!) {
                                case LayerType.AR:
                                  dev.log(
                                      "AR INDEX BEFORE = ${arIndexVal.value}");
                                  if (list.value.length > 1 &&
                                      list.value.last == selected &&
                                      list.value[list.value.length - 1]
                                              .layerType ==
                                          LayerType.Effect) {
                                    indexCounter.value = indexCounter.value - 1;
                                  } else if (list.value.length > 1 &&
                                      list.value.last == selected &&
                                      list.value[list.value.length - 1]
                                              .layerType ==
                                          LayerType.AR) {
                                    indexCounter.value = indexCounter.value - 2;
                                  } else {
                                    indexCounter.value = indexCounter.value - 2;
                                  }
                                  arIndexVal.value -= 1;
                                  dev.log(
                                      "AR INDEX NOW = ${arIndexVal.value} | indexCounter.value = ${indexCounter.value}");
                                  break;
                                case LayerType.Effect:
                                  dev.log(
                                      "EFFECT INDEX BEFORE = ${effectIndexVal.value}");
                                  if (list.value.first.layerType ==
                                          LayerType.AR &&
                                      list.value.last == selected &&
                                      list.value.length == 2) {
                                    indexCounter.value = indexCounter.value - 2;
                                  } else {
                                    indexCounter.value = indexCounter.value - 1;
                                  }
                                  effectIndexVal.value -= 1;
                                  await deleteFile(
                                      selected!.pathsForVideoFrames!);
                                  dev.log(
                                      "EFFECT INDEX NOW = ${effectIndexVal.value} | indexCounter.value = ${indexCounter.value}");
                                  break;
                                case LayerType.Music:
                                  dev.log(
                                      "MUSIC INDEX BEFORE = ${musicIndexVal.value}");
                                  if (list.value.first.layerType ==
                                          LayerType.AR &&
                                      list.value.last == selected &&
                                      list.value.length == 2) {
                                    indexCounter.value = indexCounter.value - 2;
                                  } else {
                                    indexCounter.value = indexCounter.value - 1;
                                  }
                                  musicIndexVal.value -= 1;
                                  await deleteFile(
                                      selected!.pathsForVideoFrames!);
                                  dev.log(
                                      "Music INDEX NOW = ${musicIndexVal.value} | indexCounter.value = ${indexCounter.value}");
                                  break;
                              }

                              // var appDir = (await getTemporaryDirectory()).path;
                              // new Directory(appDir).delete(recursive: true);

                              // setState(() {
                              // selected!.layerType == LayerType.AR
                              //     ? indexCounter.value =
                              //         indexCounter.value - 2
                              //     : indexCounter.value =
                              //         indexCounter.value - 1;

                              // _controllerSeekTo(0);
                              // });
                              list.value.remove(selected);
                              selected = null;
                              setState(() {});

                              dev.log(
                                  "end indexcounter == ${indexCounter.value}");

                              Navigator.pop(context);
                            },
                            onCancelBtnTap: () {
                              Navigator.pop(context);
                            },
                          );
                        } else {
                          CoolAlert.show(
                            context: context,
                            type: CoolAlertType.info,
                            title: LocaleKeys.noarselected.tr(),
                            onConfirmBtnTap: () {
                              Navigator.pop(context);
                            },
                          );
                        }
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.done,
                        color: Colors.white,
                        size: 25,
                      ),
                      onPressed: list.value.isNotEmpty
                          ? list.value.any((element) =>
                                      element.layerType == LayerType.AR) ==
                                  false
                              ? () {
                                  Get.dialog(
                                    SimpleDialog(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: Column(
                                            children: [
                                              Text(
                                                "No AR has been detected",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: constantColors.black,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Text(
                                                "In order to create content, please include at least 1 AR in your video!",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: constantColors.black,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              ElevatedButton(
                                                style: ButtonStyle(
                                                  foregroundColor:
                                                      MaterialStateProperty.all<
                                                          Color>(Colors.white),
                                                  backgroundColor:
                                                      MaterialStateProperty.all<
                                                              Color>(
                                                          constantColors
                                                              .navButton),
                                                  shape:
                                                      MaterialStateProperty.all<
                                                          RoundedRectangleBorder>(
                                                    RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                    ),
                                                  ),
                                                ),
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      Icons.check,
                                                      color: Colors.white,
                                                    ),
                                                    Text(
                                                      LocaleKeys.understood
                                                          .tr(),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              : () async {
                                  await _controller.video.seekTo(Duration.zero);
                                  await _controller.video.pause();
                                  // ! for x = W - w (and the final bit for Ar position on screen)
                                  double finalVideoContainerPointX =
                                      videoContainerKey
                                          .globalPaintBounds!.bottomRight.dx;
                                  double finalVideoContainerPointY =
                                      videoContainerKey
                                          .globalPaintBounds!.bottomRight.dy;

                                  // * to calculate videoContainer Height
                                  double videoContainerHeight =
                                      videoContainerKey
                                          .globalPaintBounds!.height;

                                  // * to calculate videoContainer Width
                                  double videoContainerWidth = videoContainerKey
                                      .globalPaintBounds!.width;

                                  // *ffmpeg list string
                                  List<String> ffmpegInputList = [];
                                  List<String> alphaTransparencyLayer = [];
                                  List<String> ffmpegStartPointList = [];
                                  List<String> ffmpegArFiltercomplex = [];
                                  List<String> ffmpegOverlay = [];
                                  List<String> ffmpegVolumeList = [];
                                  List<String> ffmpegSoundInputs = [];
                                  ValueNotifier<int> lastVal =
                                      ValueNotifier<int>(0);

                                  for (ARList arElement in list.value) {
                                    dev.log(
                                        "rotations for ${arElement.arId} = rot = ${arElement.rotation}");
                                    double finalArContainerPointX = arElement
                                        .arKey!
                                        .globalPaintBounds!
                                        .bottomRight
                                        .dx;
                                    double finalArContainerPointY = arElement
                                        .arKey!
                                        .globalPaintBounds!
                                        .bottomRight
                                        .dy;
                                    // print(
                                    //     "arIndexhere = ${arElement.arIndex} |finalVideoContainerPointX $finalVideoContainerPointX | finalVideoContainerPointY $finalVideoContainerPointY");
                                    // print(
                                    //     "arIndex = ${arElement.arIndex} |finalArContainerPointX $finalArContainerPointX | finalArContainerPointY $finalArContainerPointY");
                                    // * move x pixels to the right (minus) / left (plus) from left border of video
                                    double x = ((finalVideoContainerPointX -
                                            finalArContainerPointX) *
                                        (1080 / videoContainerWidth) *
                                        -1);
                                    // print("ar ${arElement.arIndex} x = $x");
                                    // * move y pixels to the top (minus) / bottom (plus) from bottom border of video
                                    double y = ((finalVideoContainerPointY -
                                            finalArContainerPointY) *
                                        (1920 / videoContainerHeight) *
                                        -1);

                                    //  videoContainerHeight (322.5) = 1920
                                    // videoContainerWidth (177.375) = 1080
                                    // (finalVideoContainerPointX - finalArContainerPointX) is x =

                                    // ar start time
                                    double arStartTime =
                                        (arElement.startingPositon! /
                                                _fullLayout.width) *
                                            _videoController
                                                .value.duration.inSeconds;

                                    // ar end time
                                    double arEndTime =
                                        (arElement.totalDuration!) +
                                            arStartTime;

                                    // * to calculate arContainer Height & Width

                                    double arScaleWidth =
                                        (arElement.width! * arElement.scale!)
                                            .floorToDouble();
                                    double arScaleHeigth =
                                        (arElement.height! * arElement.scale!)
                                            .floorToDouble();

                                    double arContainerHeight = arElement
                                        .arKey!.globalPaintBounds!.height;

                                    double arScaleHeightVal =
                                        arContainerHeight *
                                            1920 /
                                            videoContainerHeight;

                                    double arContainerWidth = arElement
                                        .arKey!.globalPaintBounds!.width;

                                    double arScaleWidthVal = arContainerWidth *
                                        1080 /
                                        videoContainerWidth;
                                    print("x = $x | y = $y");
                                    print(
                                        "ar point x $finalArContainerPointX | screen height $videoContainerHeight");

                                    switch (arElement.layerType!) {
                                      case LayerType.AR:
                                        ffmpegInputList.add(
                                            " -i ${arElement.mainFile} -i ${arElement.alphaFile}");

                                        break;
                                      case LayerType.Effect:
                                        ffmpegInputList.add(
                                            " -i '${arElement.gifFilePath!}'");
                                        break;
                                      case LayerType.Music:
                                        ffmpegInputList.add(
                                            " -i '${arElement.musicFile!.path}'");
                                        break;
                                    }

                                    if (arElement.layerType == LayerType.AR) {
                                      alphaTransparencyLayer.add(
                                          "[${arElement.arIndex! + 1}][${arElement.arIndex}]scale2ref[mask][main];[main][mask]alphamerge[vid${arElement.arIndex}];");
                                    }

                                    switch (arElement.layerType!) {
                                      case LayerType.AR:
                                        ffmpegStartPointList.add(
                                            "[vid${arElement.arIndex}]setpts=PTS-STARTPTS+${arStartTime.toStringAsFixed(10)}/TB[top${arElement.arIndex}];");

                                        ffmpegArFiltercomplex.add(
                                            "[top${arElement.arIndex}]rotate=${arElement.rotation! * 180 / pi}*PI/180:c=none:ow=rotw(${arElement.rotation! * 180 / pi}*PI/180):oh=roth(${arElement.rotation! * 180 / pi}*PI/180),scale=${arScaleWidthVal}:${arScaleHeightVal}:force_original_aspect_ratio=decrease[${arElement.arIndex}ol_vid];");

                                        if (arElement.arIndex == 1) {
                                          ffmpegOverlay.add(
                                              "[bg_vid][${arElement.arIndex}ol_vid]overlay=x=(W-w)${x <= 0 ? "$x" : "+${x}"}:y=(H-h)${y <= 0 ? "$y" : "+${y}"}:enable='between(t\\,\"${arStartTime.toStringAsFixed(10)}\"\\,\"${arEndTime.toStringAsFixed(10)}\")':eof_action=pass[${arElement.arIndex}out];");
                                          lastVal.value = arElement.arIndex!;
                                        } else {
                                          ffmpegOverlay.add(
                                              "[${lastVal.value}out][${arElement.arIndex}ol_vid]overlay=x=(W-w)${x <= 0 ? "$x" : "+${x}"}:y=(H-h)${y <= 0 ? "$y" : "+${y}"}:enable='between(t\\,\"${arStartTime.toStringAsFixed(10)}\"\\,\"${arEndTime.toStringAsFixed(10)}\")':eof_action=pass[${arElement.arIndex}out];");
                                          lastVal.value = arElement.arIndex!;
                                        }
                                        break;
                                      case LayerType.Effect:
                                        ffmpegStartPointList.add(
                                            "[${arElement.arIndex}]setpts=PTS-STARTPTS+${arStartTime.toStringAsFixed(0)}/TB[top${arElement.arIndex}];");
                                        ffmpegArFiltercomplex.add(
                                            "[top${arElement.arIndex}]rotate=${arElement.rotation! * 180 / pi}*PI/180:c=none:ow=rotw(${arElement.rotation! * 180 / pi}*PI/180):oh=roth(${arElement.rotation! * 180 / pi}*PI/180),scale=${arScaleWidthVal}:${arScaleHeightVal}:force_original_aspect_ratio=decrease[${arElement.arIndex}ol_vid];");

                                        if (arElement.arIndex == 1) {
                                          ffmpegOverlay.add(
                                              "[bg_vid][${arElement.arIndex}ol_vid]overlay=x=(W-w)${x <= 0 ? "$x" : "+${x}"}:y=(H-h)${y <= 0 ? "$y" : "+${y}"}:enable='between(t\\,\"${arStartTime.toStringAsFixed(10)}\"\\,\"${arEndTime.toStringAsFixed(10)}\")':eof_action=pass[${arElement.arIndex}out];");
                                          lastVal.value = arElement.arIndex!;
                                        } else {
                                          ffmpegOverlay.add(
                                              "[${lastVal.value}out][${arElement.arIndex}ol_vid]overlay=x=(W-w)${x <= 0 ? "$x" : "+${x}"}:y=(H-h)${y <= 0 ? "$y" : "+${y}"}:enable='between(t\\,\"${arStartTime.toStringAsFixed(10)}\"\\,\"${arEndTime.toStringAsFixed(10)}\")':eof_action=pass[${arElement.arIndex}out];");
                                          lastVal.value = arElement.arIndex!;
                                        }

                                        break;
                                      case LayerType.Music:
                                        break;
                                    }

                                    if (arElement.layerType == LayerType.AR &&
                                        arElement.audioFlag == true) {
                                      ffmpegVolumeList.add(
                                          "[${arElement.arIndex}:a]volume=${arElement.audioPlayer!.volume},adelay=${arStartTime.toStringAsFixed(10)}s:all=1[a${arElement.arIndex}];");
                                      ffmpegSoundInputs
                                          .add("[a${arElement.arIndex}]");
                                    }

                                    if (arElement.layerType ==
                                            LayerType.Music &&
                                        arElement.audioFlag == true) {
                                      ffmpegVolumeList.add(
                                          "[${arElement.arIndex}:a]volume=${arElement.audioPlayer!.volume},atrim=start=${arElement.audioStart}:end=${arElement.audioEnd},asetpts=PTS-STARTPTS[a${arElement.arIndex}];");
                                      ffmpegSoundInputs
                                          .add("[a${arElement.arIndex}]");
                                    }

                                    if (arElement.finishedCaching!.value ==
                                        true) arElement.arState!.skip(0);
                                    arElement.arState!.pause();
                                    if (arElement.audioFlag == true)
                                      arElement.audioPlayer!
                                          .seek(Duration(milliseconds: 0));
                                    arElement.audioPlayer!.pause();

                                    // print("arIndex = ${arElement.arIndex} | x = $x | y = $y");

                                  }

                                  // list.value.forEach((arElement) {
                                  // });

                                  String commandNoBgAudio =
                                      "${ffmpegInputList.join()} -t ${_videoController.value.duration} -filter_complex \"${alphaTransparencyLayer.join()}${ffmpegStartPointList.join()}[0:v]scale=1080:1920:force_original_aspect_ratio=decrease,pad=1080:1920:-1:-1,setsar=1[bg_vid];${ffmpegArFiltercomplex.join()}${ffmpegOverlay.join()}${ffmpegVolumeList.join()}${ffmpegSoundInputs.join()}${ffmpegSoundInputs.isEmpty ? '' : 'amix=inputs=${ffmpegSoundInputs.length + 1}[a]'}\" -map ''[${lastVal.value}out]'' ${ffmpegSoundInputs.isEmpty ? '' : '-map ' '[a]' ''} -y ";

                                  String command =
                                      "${ffmpegInputList.join()} -t ${_videoController.value.duration} -filter_complex \"${alphaTransparencyLayer.join()}${ffmpegStartPointList.join()}[0:v]scale=1080:1920:force_original_aspect_ratio=decrease,pad=1080:1920:-1:-1,setsar=1[bg_vid];${ffmpegArFiltercomplex.join()}${ffmpegOverlay.join()}${ffmpegVolumeList.join()}[0:a]volume=${_controller.video.value.volume}[a0];[a0]${ffmpegSoundInputs.join()}amix=inputs=${ffmpegSoundInputs.length + 1}[a]\" -map ''[${lastVal.value}out]'' -map ''[a]'' -y ";

                                  dev.log(
                                      arVideoCreation.getArAudioFlagGeneral == 1
                                          ? command
                                          : commandNoBgAudio);
                                  // * for combining Ar with BG
                                  // ignore: unawaited_futures
                                  CoolAlert.show(
                                    context: context,
                                    type: CoolAlertType.loading,
                                    text: LocaleKeys.processingvideo.tr(),
                                    barrierDismissible: false,
                                  );
                                  try {
                                    await combineBgAr(
                                      bgVideoFile: context
                                          .read<VideoEditorProvider>()
                                          .getBackgroundVideoFile,
                                      ffmpegArCommand: arVideoCreation
                                                  .getArAudioFlagGeneral ==
                                              1
                                          ? command
                                          : commandNoBgAudio,
                                      bgVideoDuartion:
                                          _videoController.value.duration,
                                      onProgress: (stats, value) =>
                                          _exportingProgress.value = value,
                                      onCompleted: (file) async {
                                        if (file != null) {
                                          dev.log("we're here now");

                                          await context
                                              .read<VideoEditorProvider>()
                                              .setAfterEditorVideoController(
                                                  file);

                                          dev.log("Done!!!!!");

                                          await context
                                              .read<VideoEditorProvider>()
                                              .setBgMaterialThumnailFile();

                                          // context
                                          //     .read<VideoEditorProvider>()
                                          //     .setBackgroundVideoFile(file);

                                          dev.log("Send!");
                                          Get.back();
                                          await Get.to(
                                            () => VideothumbnailSelector(
                                              arList: list.value,
                                            ),
                                          );

                                          // Navigator.pushReplacement(
                                          //     context,
                                          //     PageTransition(
                                          //         child: VideothumbnailSelector(
                                          //           arList: list.value,
                                          //           file: file,
                                          //           bgMaterialThumnailFile:
                                          //               bgMaterialThumnailFile,
                                          //         ),
                                          //         type: PageTransitionType.fade));

                                          dev.log("we're here?");
                                        } else {
                                          Navigator.pop(context);
                                          CoolAlert.show(
                                            context: context,
                                            type: CoolAlertType.error,
                                            title: LocaleKeys
                                                .errorprocessingvideo
                                                .tr(),
                                            text:
                                                "Device RAM issue. Main Please free up space on your phone to be able to process the video properly",
                                          );
                                          dev.log("hello ?? ");
                                        }

                                        setState(() => _exported = true);
                                        Future.delayed(
                                            const Duration(seconds: 2),
                                            () => setState(
                                                () => _exported = false));
                                      },
                                    );
                                  } catch (e) {
                                    Navigator.pop(context);
                                    CoolAlert.show(
                                      context: context,
                                      type: CoolAlertType.error,
                                      title: "Error processing video",
                                      text: e.toString(),
                                    );
                                  }

                                  // * for combining effect with BG
                                  // await combineBgEffect(
                                  //   bgVideoFile: widget.file,
                                  //   effectFile: File(selectedFile!.path!),
                                  //   arScaleWidth: "${arScaleWidthVal.floor()}",
                                  //   arScaleHeight: "${arScaleHeightVal.floor()}",
                                  //   arXCoordinate: x < 0 ? "-$x" : "+$x",
                                  //   arYCoordinate: y < 0 ? "-$y" : "+$y",
                                  //   arStartTime: arStartTime.toString(),
                                  //   arEndTime: "${arEndTime + arStartTime}",
                                  //   bgVideoDuartion: _videoController.value.duration,
                                  //   onProgress: (stats, value) =>
                                  //       _exportingProgress.value = value,
                                  //   onCompleted: (file) async {
                                  //     _isExporting.value = false;
                                  //     if (!mounted) return;
                                  //     if (file != null) {
                                  //       final VideoPlayerController _videoController =
                                  //           VideoPlayerController.file(file);

                                  //       // ignore: unawaited_futures
                                  //       _videoController.initialize().then((value) async {
                                  //         setState(() {});

                                  //         _videoController.setLooping(true);
                                  //         await showDialog(
                                  //           context: context,
                                  //           builder: (_) => Padding(
                                  //             padding: const EdgeInsets.all(30),
                                  //             child: Container(
                                  //               color: Colors.black,
                                  //               child: Column(
                                  //                 children: [
                                  //                   Container(
                                  //                     height: 50,
                                  //                     color: Colors.white,
                                  //                     child: Row(
                                  //                       mainAxisAlignment:
                                  //                           MainAxisAlignment.center,
                                  //                       children: [
                                  //                         Text(
                                  //                           "Preview",
                                  //                           style: TextStyle(
                                  //                             color: Colors.black,
                                  //                             fontSize: 20,
                                  //                           ),
                                  //                         ),
                                  //                       ],
                                  //                     ),
                                  //                   ),
                                  //                   Container(
                                  //                     height:
                                  //                         MediaQuery.of(context).size.height *
                                  //                             0.6,
                                  //                     child: Center(
                                  //                       child: GestureDetector(
                                  //                         onTap: () {
                                  //                           _videoController.value.isPlaying
                                  //                               ? _videoController.pause()
                                  //                               : _videoController.play();
                                  //                         },
                                  //                         child: AspectRatio(
                                  //                           aspectRatio: _videoController
                                  //                               .value.aspectRatio,
                                  //                           child:
                                  //                               VideoPlayer(_videoController),
                                  //                         ),
                                  //                       ),
                                  //                     ),
                                  //                   ),
                                  //                   Container(
                                  //                     color: Colors.white,
                                  //                     child: Row(
                                  //                       mainAxisAlignment:
                                  //                           MainAxisAlignment.spaceEvenly,
                                  //                       children: [
                                  //                         ElevatedButton(
                                  //                           onPressed: () {
                                  //                             Navigator.pop(context);
                                  //                           },
                                  //                           child: Text(
                                  //                             "Cancel",
                                  //                           ),
                                  //                         ),
                                  //                         ElevatedButton(
                                  //                           onPressed: () {
                                  //                             Navigator.push(
                                  //                                 context,
                                  //                                 PageTransition(
                                  //                                     child: PreviewVideoScreen(
                                  //                                         thumbnailFile:
                                  //                                             thumbnailfile,
                                  //                                         videoFile:
                                  //                                             File(file.path),
                                  //                                         videoPlayerController:
                                  //                                             _videoController),
                                  //                                     type: PageTransitionType
                                  //                                         .fade));
                                  //                           },
                                  //                           child: Text(
                                  //                             "Next",
                                  //                           ),
                                  //                         ),
                                  //                       ],
                                  //                     ),
                                  //                   ),
                                  //                 ],
                                  //               ),
                                  //             ),
                                  //           ),
                                  //         );
                                  //         await _videoController.pause();
                                  //         _videoController.dispose();
                                  //       });

                                  //       _exportText = "Video success export!";
                                  //     } else {
                                  //       _exportText = "Error on export video :(";
                                  //     }

                                  //     setState(() => _exported = true);
                                  //     Future.delayed(const Duration(seconds: 2),
                                  //         () => setState(() => _exported = false));
                                  //   },
                                  // );
                                }
                          : () {
                              Get.dialog(
                                SimpleDialog(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Column(
                                        children: [
                                          Text(
                                            LocaleKeys.noareffectadded.tr(),
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: constantColors.black,
                                              fontSize: 16,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Text(
                                            LocaleKeys.OneAROrOneEffect.tr(),
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: constantColors.black,
                                              fontSize: 16,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          ElevatedButton(
                                            style: ButtonStyle(
                                              foregroundColor:
                                                  MaterialStateProperty.all<
                                                      Color>(Colors.white),
                                              backgroundColor:
                                                  MaterialStateProperty.all<
                                                          Color>(
                                                      constantColors.navButton),
                                              shape: MaterialStateProperty.all<
                                                  RoundedRectangleBorder>(
                                                RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                              ),
                                            ),
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.check,
                                                  color: Colors.white,
                                                ),
                                                Text(
                                                  LocaleKeys.understood.tr(),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  customHandler(IconData icon) {
    return FlutterSliderHandler(
      decoration: BoxDecoration(),
      child: Container(
        height: 60,
        width: 5,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.blue.withOpacity(0.3),
                spreadRadius: 0.05,
                blurRadius: 5,
                offset: Offset(0, 1))
          ],
        ),
      ),
    );
  }

  Future<dynamic> showMusicAdjustBottomSheet(
      {required BuildContext context, required ARList ar}) async {
    final point = ValueNotifier<double>(ar.audioPlayer!.volume);
    await ar.audioPlayer!.setClip(start: null, end: null);
    final Duration maxAudioDuration = ar.audioPlayer!.duration!;

    final ValueNotifier<List<double>> _currentRangeValues =
        ValueNotifier<List<double>>(
            [ar.audioStart!.toDouble(), ar.audioEnd!.toDouble()]);

    final ValueNotifier<bool> audioPlaying =
        ValueNotifier<bool>(ar.audioPlayer!.playing);

    dev.log("audio duration == ${ar.audioPlayer!.duration!.inSeconds}");
    return showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: false,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          width: 100.w,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              color: constantColors.whiteColor),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 150),
                child: Divider(
                  thickness: 4,
                  color: constantColors.greyColor,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Text("Set Music Volume"),
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Icon(Icons.volume_down),
                  Expanded(
                    child: ValueListenableBuilder<double>(
                      valueListenable: point,
                      builder: (context, mark, _) {
                        return CupertinoSlider(
                          activeColor: constantColors.navButton,
                          value: mark,
                          min: 0,
                          max: 1,
                          onChanged: (double value) async {
                            point.value = value;
                            print(point.value);
                            await ar.audioPlayer!.setVolume(point.value);
                            // await ar.audioPlayer!.setVolume(value);
                          },
                        );
                      },
                    ),
                  ),
                  Icon(Icons.volume_up_rounded),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Text("Select clip from music layer"),
              SizedBox(
                height: 10,
              ),
              ValueListenableBuilder<List<double>>(
                valueListenable: _currentRangeValues,
                builder: (context, rangeVal, _) {
                  return Container(
                      alignment: Alignment.centerLeft,
                      child: FlutterSlider(
                        values: _currentRangeValues.value,
                        rangeSlider: true,
//rtl: true,

//                ignoreSteps: [
//                  FlutterSliderIgnoreSteps(from: 8000, to: 12000),
//                  FlutterSliderIgnoreSteps(from: 18000, to: 22000),
//                ],
                        max: maxAudioDuration.inSeconds.toDouble(),
                        min: 0,
                        step: FlutterSliderStep(step: 1),
                        jump: true,
                        trackBar: FlutterSliderTrackBar(
                          inactiveTrackBarHeight: 2,
                          activeTrackBarHeight: 60,
                          activeTrackBar: BoxDecoration(
                            color: constantColors.bioBg.withOpacity(0.5),
                          ),
                          centralWidget: Container(
                            height: 80,
                            width: 100.w,
                            margin: EdgeInsets.symmetric(horizontal: 10),
                            color: constantColors.navButton,
                            child: ListView.separated(
                              controller: _scrollController,
                              itemCount: 40,
                              separatorBuilder: (_, __) => const Divider(
                                indent: 1,
                              ),
                              itemBuilder: (_, index) => Container(
                                child: Image.network(ar.youtubeAlbumCover!),
                                height: 50,
                              ),
                              scrollDirection: Axis.horizontal,
                            ),
                          ),
                        ),

                        disabled: false,

                        handler: customHandler(Icons.chevron_right),
                        rightHandler: customHandler(Icons.chevron_left),
                        tooltip: FlutterSliderTooltip(
                            custom: (value) {
                              // dev.log("value is $value");
                              // int valueChange = int.parse(value.toString());
                              // dev.log(valueChange.toString());
                              return Text(
                                  formatter(Duration(seconds: value.toInt())));
                            },
                            textStyle:
                                TextStyle(fontSize: 17, color: Colors.white),
                            boxStyle: FlutterSliderTooltipBox(
                                decoration: BoxDecoration(
                                    color: Colors.redAccent.withOpacity(0.7)))),

                        minimumDistance: _controller
                            .video.value.duration.inSeconds
                            .toDouble(),
                        onDragging: (handlerIndex, lowerValue, upperValue) {
                          dev.log("lower - $lowerValue");
                          dev.log("upper - $upperValue");

                          ar.audioPlayer!.setClip(
                            start: Duration(seconds: lowerValue.truncate()),
                            end: Duration(seconds: upperValue.truncate()),
                          );

                          ar.audioStart = lowerValue.truncate();
                          ar.audioEnd = upperValue.truncate();
                          dev.log(
                              "ar start == ${ar.audioStart} | end == ${ar.audioEnd}");

                          if (ar.audioPlayer!.playing)
                            setState(() {
                              audioPlaying.value = false;
                              ar.audioPlayer!.pause();
                            });

                          // _lowerValue = lowerValue;
                          // _upperValue = upperValue;
                          // setState(() {});
                        },
                      ));
                },
              ),
              SizedBox(
                height: 10,
              ),
              StatefulBuilder(builder: (context, innerState) {
                return ValueListenableBuilder<bool>(
                    valueListenable: audioPlaying,
                    builder: (context, playingAudio, _) {
                      return Center(
                        child: IconButton(
                            onPressed: () {
                              innerState(() {
                                if (ar.audioPlayer!.playing) {
                                  ar.audioPlayer!.pause();
                                  audioPlaying.value = false;
                                } else {
                                  audioPlaying.value = true;
                                  ar.audioPlayer!.play();
                                }
                              });
                            },
                            icon: Icon(
                                playingAudio ? Icons.pause : Icons.play_arrow)),
                      );
                    });
              }),
              Expanded(
                child: Center(
                  child: SubmitButton(
                    function: () {
                      ar.audioPlayer!.pause();
                      Navigator.pop(context);
                    },
                    text: "Done",
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String formatter(Duration duration) => [
        duration.inMinutes.remainder(60).toString().padLeft(2, '0'),
        duration.inSeconds.remainder(60).toString().padLeft(2, '0')
      ].join(":");

  Future<void> combineBgAr({
    required File bgVideoFile,
    required String ffmpegArCommand,
    required Duration bgVideoDuartion,
    required void Function(File? file) onCompleted,
    void Function(Statistics, double)? onProgress,
    VideoExportPreset preset = VideoExportPreset.none,
    bool isFiltersEnabled = true,
  }) async {
    _exportingProgress.value = 0;
    _isExporting.value = true;
    final String tempPath = (await getApplicationDocumentsDirectory()).path;
    final String bgVideoPath = bgVideoFile.path;
    // final String arPath = arFile;

    final int epoch = DateTime.now().millisecondsSinceEpoch;
    final String outputPath = "$tempPath/output.mp4";
    final String thumbnailPath = "$tempPath/output.gif";

    print("path : $bgVideoPath");

    final String commandToExecute = "-v error -y -i ${bgVideoPath}" +
        ffmpegArCommand +
        " -crf 30 -preset faster ${outputPath}";

    dev.log("command : $commandToExecute");

    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        dev.log(' network connected');
        // PROGRESS CALLBACKS
        // PROGRESS CALLBACKS

        await FFmpegKit.execute(commandToExecute).then((value) async {
          final state =
              FFmpegKitConfig.sessionStateToString(await value.getState());
          final code = await value.getReturnCode();
          final failStackTrace = await value.getFailStackTrace();

          dev.log("OUTPUT! ==  ${await value.getOutput()}");

          debugPrint(
              "FFmpeg process exited with state $state and return code $code.${(failStackTrace == null) ? "" : "\\n" + failStackTrace}");
          dev.log("code value == ${code!.isValueSuccess()}");

          if (code.isValueError()) {
            Navigator.pop(context);
            CoolAlert.show(
              context: context,
              type: CoolAlertType.error,
              title: LocaleKeys.errorprocessingvideo.tr(),
              text:
                  "Device RAM issue. FFMPEG Please free up space on your phone to be able to process the video properly",
            );
          }

          onCompleted(code.isValueSuccess() == true ? File(outputPath) : null);
        });
        // await FFmpegKit.executeAsync(
        //   commandToExecute,
        //   (session) async {
        //     final state =
        //         FFmpegKitConfig.sessionStateToString(await session.getState());
        //     final code = await session.getReturnCode();
        //     final failStackTrace = await session.getFailStackTrace();

        //     debugPrint(
        //         "FFmpeg process exited with state $state and return code $code.${(failStackTrace == null) ? "" : "\\n" + failStackTrace}");

        //     if (code!.isValueError()) {
        //       Navigator.pop(context);
        //       CoolAlert.show(
        //         context: context,
        //         type: CoolAlertType.error,
        //         title: "Error Processing Video",
        //       );
        //     }

        //     onCompleted(
        //         code.isValueSuccess() == true ? File(outputPath) : null);
        //   },
        //   null,
        //   onProgress != null
        //       ? (stats) {
        //           // Progress value of encoded video
        //           double progressValue = stats.getTime() /
        //               (Duration.zero - bgVideoDuartion).inMilliseconds;
        //           onProgress(stats, progressValue.clamp(0.0, 1.0));
        //         }
        //       : null,
        // );
      }
    } on SocketException catch (_) {
      dev.log('network not connected');
      Navigator.pop(context);
      CoolAlert.show(
        context: context,
        type: CoolAlertType.error,
        title: LocaleKeys.errorprocessingvideo.tr(),
        text:
            "This is due to poor network  / wifi connection. Please ensure you have a strong stable connection and try again!",
      );
    }
  }

  // Future<void> combineBgEffect({
  //   required File bgVideoFile,
  //   required File effectFile,
  //   required String arScaleWidth,
  //   required String arScaleHeight,
  //   required String arXCoordinate,
  //   required String arYCoordinate,
  //   required String arStartTime,
  //   required String arEndTime,
  //   required Duration bgVideoDuartion,
  //   String? name,
  //   required void Function(File? file) onCompleted,
  //   void Function(Statistics, double)? onProgress,
  //   VideoExportPreset preset = VideoExportPreset.none,
  //   bool isFiltersEnabled = true,
  // }) async {
  //   _exportingProgress.value = 0;
  //   _isExporting.value = true;
  //   final String tempPath = (await getTemporaryDirectory()).path;
  //   final String bgVideoPath = bgVideoFile.path;
  //   final String arEffectPath = effectFile.path;
  //   name ??= path.basenameWithoutExtension(bgVideoPath);
  //   final int epoch = DateTime.now().millisecondsSinceEpoch;
  //   final String outputPath = "$tempPath/${name}_$epoch.mp4";
  //   final String thumbnailPath = "$tempPath/${name}_$epoch.gif";

  //   final String commandToExecute =
  //       "-v error -i ${bgVideoPath} -i ${arEffectPath} -t ${bgVideoDuartion.inSeconds} -filter_complex \"[0:v]scale=1080:1920:force_original_aspect_ratio=decrease,pad=1080:1920:-1:-1,setsar=1[bg_vid];[1:v]scale=${arScaleWidth}:$arScaleHeight:force_original_aspect_ratio=decrease[ol_vid];[bg_vid][ol_vid]overlay=x=W-w${arXCoordinate}:y=H-h${arYCoordinate}:enable='between(t,${arStartTime},${arEndTime})'\" ${outputPath}";

  //   // PROGRESS CALLBACKS
  //   await FFmpegKit.executeAsync(
  //     commandToExecute,
  //     (session) async {
  //       final state =
  //           FFmpegKitConfig.sessionStateToString(await session.getState());
  //       final code = await session.getReturnCode();
  //       final failStackTrace = await session.getFailStackTrace();

  //       await FFmpegKit.execute(
  //               "-y -i ${outputPath} -to 00:00:02 -vf scale=-2:480 -r 20/1 ${thumbnailPath}")
  //           .then((value) {
  //         setState(() {
  //           thumbnailfile = File(thumbnailPath);
  //         });
  //       });

  //       debugPrint(
  //           "FFmpeg process exited with state $state and return code $code.${(failStackTrace == null) ? "" : "\\n" + failStackTrace}");

  //       onCompleted(code?.isValueSuccess() == true ? File(outputPath) : null);
  //     },
  //     null,
  //     onProgress != null
  //         ? (stats) {
  //             // Progress value of encoded video
  //             double progressValue = stats.getTime() /
  //                 (Duration.zero - bgVideoDuartion).inMilliseconds;
  //             onProgress(stats, progressValue.clamp(0.0, 1.0));
  //           }
  //         : null,
  //   );
  // }

  showAlertDialog({required BuildContext context, required ARList ar}) {
    final point = ValueNotifier<double>(ar.audioPlayer!.volume);
    // set up the button
    Widget okButton = TextButton(
      child: Text(
        "OK",
        style: TextStyle(
          color: constantColors.navButton,
        ),
      ),
      onPressed: () async {
        print(point.value);
        await ar.audioPlayer!.setVolume(point.value);
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(
        ar.layerType == LayerType.AR
            ? LocaleKeys.arvolume.tr()
            : "Music Volume",
      ),
      content: Row(
        children: [
          Icon(Icons.volume_down),
          ValueListenableBuilder<double>(
            valueListenable: point,
            builder: (context, mark, _) {
              return CupertinoSlider(
                activeColor: constantColors.navButton,
                value: mark,
                min: 0,
                max: 1,
                onChanged: (double value) async {
                  point.value = value;
                  print(point.value);
                  await ar.audioPlayer!.setVolume(point.value);
                  // await ar.audioPlayer!.setVolume(value);
                },
              );
            },
          ),
          Icon(Icons.volume_up_rounded),
        ],
      ),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  showBgAlertDialog(
      {required BuildContext context,
      required VideoEditorController controller}) {
    final point = ValueNotifier<double>(controller.video.value.volume);
    // set up the button
    Widget okButton = TextButton(
      child: Text(
        "OK",
        style: TextStyle(
          color: constantColors.navButton,
        ),
      ),
      onPressed: () async {
        print(point.value);
        await controller.video.setVolume(point.value);
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(
        LocaleKeys.bgvolume.tr(),
      ),
      content: Row(
        children: [
          Icon(Icons.volume_down),
          ValueListenableBuilder<double>(
            valueListenable: point,
            builder: (context, mark, _) {
              return CupertinoSlider(
                activeColor: constantColors.navButton,
                value: mark,
                min: 0,
                max: 1,
                onChanged: (double value) async {
                  point.value = value;
                  print(point.value);
                  await controller.video.setVolume(point.value);

                  // await ar.audioPlayer!.setVolume(value);
                },
              );
            },
          ),
          Icon(Icons.volume_up_rounded),
        ],
      ),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  PersistentBottomSheetController<dynamic> selectArBottomSheet(
      BuildContext context, Size size) {
    return showBottomSheet(
        context: context,
        builder: (context) {
          return ValueListenableBuilder<int>(
              valueListenable: arIndexVal,
              builder: (context, arIndex, _) {
                return Container(
                  height: size.height * 0.5,
                  width: size.width,
                  decoration: BoxDecoration(
                    color: constantColors.navButton,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 150),
                        child: Divider(
                          thickness: 4,
                          color: constantColors.whiteColor,
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: FutureBuilder<QuerySnapshot>(
                              future: FirebaseFirestore.instance
                                  .collection("users")
                                  // .doc("ijdI08UkGadVifmUcvS2KPjmuAE2")
                                  .doc(Provider.of<Authentication>(context,
                                          listen: false)
                                      .getUserId)
                                  .collection("MyCollection")
                                  .where("layerType", isEqualTo: "AR")
                                  .where("usage", isEqualTo: "Material")
                                  .orderBy("timestamp", descending: true)
                                  .get(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }

                                if (snapshot.data!.docs.isEmpty) {
                                  return Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "No AR Materials have been created yet",
                                        softWrap: true,
                                        style: TextStyle(
                                          color: constantColors.whiteColor,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        "To create your first Material AR:",
                                        softWrap: true,
                                        style: TextStyle(
                                          color: constantColors.whiteColor,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        "AR Options > Select Video > Submit as Material",
                                        softWrap: true,
                                        style: TextStyle(
                                          color: constantColors.whiteColor,
                                        ),
                                      ),
                                    ],
                                  );
                                }

                                return GridView.builder(
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    crossAxisSpacing: 10,
                                    mainAxisSpacing: 5,
                                  ),
                                  itemCount: snapshot.data!.docs.length,
                                  itemBuilder: (context, index) {
                                    var myArCollectionSnap =
                                        snapshot.data!.docs[index];
                                    MyArCollection myArCollection =
                                        MyArCollection.fromJson(
                                            snapshot.data!.docs[index].data()
                                                as Map<String, dynamic>);

                                    return InkWell(
                                      onTap: () async {
                                        dev.log("arIndexVal = ${arIndex}");

                                        var contain = list.value.where(
                                            (element) =>
                                                element.arId ==
                                                myArCollection.id);

                                        if (contain.isEmpty) {
                                          if (arIndexVal.value <= 2) {
                                            if (list.value.isNotEmpty) {
                                              list.value.last.layerType ==
                                                      LayerType.AR
                                                  ? indexCounter.value =
                                                      indexCounter.value + 2
                                                  : indexCounter.value =
                                                      indexCounter.value + 1;
                                            } else {
                                              indexCounter.value = 1;
                                            }

                                            if (indexCounter.value <= 0) {
                                              indexCounter.value = 1;
                                            }

                                            await runFFmpegCommand(
                                              arVal: indexCounter.value,
                                              myAr: myArCollection,
                                            );
                                          } else {
                                            CoolAlert.show(
                                              context: context,
                                              type: CoolAlertType.info,
                                              title: "Max AR's Reached",
                                              text: "You can only have 2 AR's",
                                            );
                                          }
                                        } else {
                                          dev.log(
                                              "myArCollection.id = ${myArCollection.id}");
                                          await Get.dialog(
                                            SimpleDialog(
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.all(10),
                                                  child: Text(
                                                      "You've already added this AR!"),
                                                ),
                                              ],
                                            ),
                                          );
                                        }
                                      },
                                      child: Container(
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          child: ImageNetworkLoader(
                                            imageUrl: myArCollection.imgSeq[0],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }),
                        ),
                      ),
                    ],
                  ),
                );
              });
        });
  }

  PersistentBottomSheetController<dynamic> selectEffectBottomSheet(
      {required BuildContext context,
      required Size size,
      required int effectValIndex,
      required int arValIndex}) {
    return showBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            height: size.height * 0.5,
            width: size.width,
            decoration: BoxDecoration(
              color: constantColors.navButton,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 150),
                  child: Divider(
                    thickness: 4,
                    color: constantColors.whiteColor,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: InkWell(
                    onTap: _openFileManager,
                    child: Container(
                      alignment: Alignment.center,
                      height: 50,
                      width: size.width,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: constantColors.bioBg,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        LocaleKeys.selectneweffect.tr(),
                        style: TextStyle(
                          color: constantColors.whiteColor,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection("users")
                            .doc(Provider.of<Authentication>(context,
                                    listen: false)
                                .getUserId)
                            .collection("MyCollection")
                            .where("layerType", isEqualTo: "Effect")
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          if (snapshot.data!.docs.isEmpty) {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "No Effects previously used",
                                  softWrap: true,
                                  style: TextStyle(
                                    color: constantColors.whiteColor,
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  "To use Effect, they must be saved on your phone in GIF Format",
                                  textAlign: TextAlign.center,
                                  softWrap: true,
                                  style: TextStyle(
                                    color: constantColors.whiteColor,
                                  ),
                                ),
                              ],
                            );
                          }

                          return GridView.builder(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 5,
                            ),
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: (context, index) {
                              var myArCollectionSnap =
                                  snapshot.data!.docs[index];

                              return InkWell(
                                onTap: () async {
                                  setState(() {
                                    effectIndexVal.value = list.value
                                        .where((element) =>
                                            element.layerType ==
                                            LayerType.Effect)
                                        .length;
                                  });
                                  if (effectIndexVal.value <= 2) {
                                    CoolAlert.show(
                                      context: context,
                                      type: CoolAlertType.loading,
                                    );
                                    final http.Response responseData =
                                        await http.get(Uri.parse(
                                            "${myArCollectionSnap['gif']}"));
                                    var uint8list = responseData.bodyBytes;
                                    var buffer = uint8list.buffer;
                                    ByteData byteData = ByteData.view(buffer);
                                    var tempDir = await getTemporaryDirectory();
                                    File gifFileVal =
                                        await File('${tempDir.path}/img')
                                            .writeAsBytes(buffer.asUint8List(
                                                byteData.offsetInBytes,
                                                byteData.lengthInBytes));

                                    Navigator.pop(context);

                                    if (list.value.isNotEmpty) {
                                      list.value.last.layerType == LayerType.AR
                                          ? indexCounter.value =
                                              indexCounter.value + 2
                                          : indexCounter.value =
                                              indexCounter.value + 1;
                                    }

                                    await runGifFFmpegCommand(
                                      fromFirebase: true,
                                      arVal: indexCounter.value,
                                      gifFile: gifFileVal,
                                      arId: myArCollectionSnap['id'],
                                      ownerId: myArCollectionSnap['ownerId'],
                                      ownerName:
                                          myArCollectionSnap['ownerName'] ??
                                              Provider.of<FirebaseOperations>(
                                                      context,
                                                      listen: false)
                                                  .initUserName,
                                    ).then((value) {
                                      setState(() {});
                                    });
                                  } else {
                                    CoolAlert.show(
                                      context: context,
                                      type: CoolAlertType.info,
                                      title: "Max Effects's Reached",
                                      text: "You can only have 2 Effect's",
                                    );
                                  }
                                },
                                child: Container(
                                  child: ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: ImageNetworkLoader(
                                          imageUrl:
                                              "${myArCollectionSnap['gif']}")),
                                ),
                              );
                            },
                          );
                        }),
                  ),
                ),
              ],
            ),
          );
        });
  }
}
