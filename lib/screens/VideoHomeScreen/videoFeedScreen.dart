import 'package:diamon_rose_app/services/feed_viewmodel.dart';
import 'package:diamon_rose_app/services/video.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:stacked/stacked.dart';
import 'package:cached_video_player/cached_video_player.dart' as cachedVP;

class VideoFeedScreen extends StatefulWidget {
  const VideoFeedScreen({Key? key}) : super(key: key);

  @override
  State<VideoFeedScreen> createState() => _VideoFeedScreenState();
}

class _VideoFeedScreenState extends State<VideoFeedScreen> {
  final feedViewModel = GetIt.instance<FeedViewModel>();

  @override
  void initState() {
    feedViewModel.loadVideo(0);
    feedViewModel.loadNext(1);
    feedViewModel.setInitialised(true);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<FeedViewModel>.reactive(
      disposeViewModel: false,
      builder: (context, model, child) => videoScreen(),
      viewModelBuilder: () => feedViewModel,
    );
  }

  Widget videoScreen() {
    return Scaffold(
      backgroundColor: GetIt.instance<FeedViewModel>().actualScreen == 0
          ? Colors.black
          : Colors.white,
      body: scrollFeed(),
    );
  }

  Widget currentScreen() {
    switch (feedViewModel.actualScreen) {
      case 0:
        return feedVideos();
      // case 1:
      //   return BlocProvider(
      //     create: (context) => SelectVideoBloc()..add(LoadVideos()),
      //     child: SelectVideos(),
      //   );
      // case 2:
      //   return AllVideoPage();
      default:
        return feedVideos();
    }
  }

  Widget scrollFeed() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(child: currentScreen()),
        // BottomBar(),
      ],
    );
  }

  Widget feedVideos() {
    return Stack(
      children: [
        PageView.builder(
          controller: PageController(
            initialPage: 0,
            viewportFraction: 1,
          ),
          itemCount: feedViewModel.videos.length,
          onPageChanged: (index) {
            index = index % (feedViewModel.videos.length);
            feedViewModel.changeVideo(index);
          },
          scrollDirection: Axis.vertical,
          itemBuilder: (context, index) {
            index = index % (feedViewModel.videos.length);

            return videoCard(feedViewModel.videos[index]);
          },
        ),
        SafeArea(
          child: Container(
            padding: EdgeInsets.only(top: 20),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text('Following',
                      style: TextStyle(
                          fontSize: 17.0,
                          fontWeight: FontWeight.normal,
                          color: Colors.white70)),
                  SizedBox(
                    width: 7,
                  ),
                  Container(
                    color: Colors.white70,
                    height: 10,
                    width: 1.0,
                  ),
                  SizedBox(
                    width: 7,
                  ),
                  Text('For You',
                      style: TextStyle(
                          fontSize: 17.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white))
                ]),
          ),
        ),
      ],
    );
  }

  Widget videoCard(Video video) {
    return Stack(
      children: [
        video.controller != null
            ? GestureDetector(
                onTap: () {
                  if (video.controller!.value.isPlaying) {
                    video.controller?.pause();
                  } else {
                    video.controller?.play();
                  }
                },
                child: SizedBox.expand(
                    child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: video.controller?.value.size.width ?? 0,
                    height: video.controller?.value.size.height ?? 0,
                    child: cachedVP.CachedVideoPlayer(video.controller!),
                  ),
                )),
              )
            : Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Center(
                  child: Container(
                    height: 70,
                    width: 70,
                    color: Colors.black,
                    child: Center(
                        child: CircularProgressIndicator(
                      backgroundColor: Colors.grey,
                      valueColor:
                          new AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                    )),
                  ),
                ),
              ),
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                // VideoDescription(video.user, video.videoTitle, video.songName),
                // ActionsToolbar(video.likes, video.comments,
                //     "https://www.andersonsobelcosmetic.com/wp-content/uploads/2018/09/chin-implant-vs-fillers-best-for-improving-profile-bellevue-washington-chin-surgery.jpg"),
              ],
            ),
            SizedBox(height: 20)
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    // feedViewModel.controller?.dispose();
    super.dispose();
  }
}
