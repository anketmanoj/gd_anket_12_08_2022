//Track list for infinite Pagination with search

import 'dart:developer';
import 'dart:io';

import 'package:diamon_rose_app/screens/youtubeSearchApi/loading_widget.dart';
import 'package:diamon_rose_app/screens/youtubeSearchApi/search.dart';

import 'package:diamon_rose_app/screens/youtubeSearchApi/searchResults/searchresultsservice.dart';
import 'package:diamon_rose_app/screens/youtubeTest/download_status.dart';
import 'package:diamon_rose_app/screens/youtubeTest/youtubeData.dart';
import 'package:diamon_rose_app/screens/youtubeTest/youtube_utils.dart';
import 'package:diamon_rose_app/widgets/global.dart';
import 'package:flutter/material.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import 'searchResults/songsdataclass.dart';

class TrackList extends StatefulWidget {
  final String songQuery;

  const TrackList({Key? key, required this.songQuery}) : super(key: key);

  @override
  _TrackListState createState() => _TrackListState();
}

class _TrackListState extends State<TrackList> {
  String query = '';
  static const _pageSize = 20;

  final FloatingSearchBarController _controller = FloatingSearchBarController();

  final _pagingController = PagingController<int, Songs>(
    // 2
    firstPageKey: 1,
  );

  @override
  void initState() {
    // 3
    _pagingController.addPageRequestListener((pageKey) {
      fetchSongs(pageKey);
    });
    super.initState();
  }

  @override
  void dispose() {
    // 4
    _pagingController.dispose();
    super.dispose();
  }

  Future<void> fetchSongs(int pageKey) async {
    try {
      final List<Songs> newItems = await SearchMusic.getOnlySongs(
          query == '' ? widget.songQuery : query, _pageSize);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SearchFunction(
          liveSearch: false,
          controller: _controller,
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
                        separatorBuilder: (context, index) => const SizedBox(
                          height: 10,
                        ),
                        builderDelegate: PagedChildBuilderDelegate<Songs>(
                          animateTransitions: true,
                          transitionDuration: const Duration(milliseconds: 200),
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
                                child: TrackListItem(
                                  songs: songs,
                                  color: constantColors.bioBg,
                                ),
                              ),
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
          )),
    );
  }
}

class TrackListItem extends StatefulWidget {
  final Songs songs;
  final Color color;

  const TrackListItem({Key? key, required this.songs, required this.color})
      : super(key: key);

  @override
  _TrackListItemState createState() => _TrackListItemState();
}

class _TrackListItemState extends State<TrackListItem> {
  YoutubeUtil youtubeHandler = YoutubeUtil();

  @override
  Widget build(BuildContext context) {
    const spacer = SizedBox(width: 10.0);
    const biggerSpacer = SizedBox(width: 40.0);
    return Material(
      borderRadius: BorderRadius.circular(10),
      color: widget.color,
      child: InkWell(
        onTap: () async {
          //playerAlerts.buffering = t
          log("widget.songs.videoId == ${widget.songs.videoId}");
          log("Youtube URL == https://www.youtube.com/watch?v=${widget.songs.videoId}");
          log("widget.songs.title == ${widget.songs.title}");
          log("widget.songs.artists![0].name == ${widget.songs.artists![0].name}");

          await youtubeHandler.loadVideo(widget.songs.videoId);

          final File? success = await youtubeHandler.downloadMP3File();

          if (success != null) {
            log("DONE! == ${success.path}");
          }
          // await context.read<ActiveAudioData>().songDetails(
          //     widget.songs.videoId,
          //     widget.songs.videoId,
          //     widget.songs.artists![0].name,
          //     widget.songs.title,
          //     widget.songs.thumbnails[0].url,
          //     //widget.songs.thumbnails.map((e) => ThumbnailLocal(height: e.height, url: e.url.toString(), width: e.width)).toList(),
          //     widget.songs.thumbnails.last.url.toString());

          // await AudioControlClass.play(
          //   videoId: widget.songs.videoId.toString(),
          //   context: context,
          // );
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FadeInImage(
                  placeholder: const AssetImage('assets/images/GDlogo.png'),
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  image: NetworkImage(
                    widget.songs.thumbnails.first.url.toString(),
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
              //   imageUrl: widget.songs.thumbnails.first.url.toString(),
              //   placeholder: (context, url) => const Image(
              //       fit: BoxFit.cover,
              //       image: AssetImage('assets/cover.jpg')),
              // ),
              spacer,

              SizedBox(
                width: MediaQuery.of(context).size.width * 1 / 4,
                child: Text(
                  widget.songs.title.toString(),
                  // widget.isFromPrimarySearchPage ? widget.songs[index].title.toString() : 'Kuch is tarah',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              spacer,
              SizedBox(
                width: MediaQuery.of(context).size.width * 1 / 8,
                child: Text(
                  widget.songs.artists![0].name.toString(),
                  // widget.isFromPrimarySearchPage ? widget.songs[index].artists![0].name.toString() : 'Atif',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              spacer,
              if (MediaQuery.of(context).size.width > 500)
                SizedBox(
                  width: MediaQuery.of(context).size.width * 1 / 8,
                  child: Text(
                    widget.songs.album!.name.toString(),
                    //  widget.isFromPrimarySearchPage ? widget.songs[index].album!.name.toString() : 'The jal band',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 1 / 15,
                child: Text(
                  widget.songs.duration.toString(),
                  //widget.isFromPrimarySearchPage ? widget.songs[index].duration.toString() : '5:25',
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
    );
  }
}
