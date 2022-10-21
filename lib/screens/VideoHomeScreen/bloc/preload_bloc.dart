import 'dart:async';
import 'dart:collection';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:diamon_rose_app/main.dart';
import 'package:diamon_rose_app/screens/VideoHomeScreen/core/constants.dart';
import 'package:diamon_rose_app/screens/VideoHomeScreen/service/api_service.dart';
import 'package:diamon_rose_app/services/homeScreenUserEnum.dart';
import 'package:diamon_rose_app/services/video.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:video_player/video_player.dart';

part 'preload_bloc.freezed.dart';
part 'preload_event.dart';
part 'preload_state.dart';

@injectable
@prod
class PreloadBloc extends Bloc<PreloadEvent, PreloadState> {
  PreloadBloc() : super(PreloadState.initial());

  @override
  Stream<PreloadState> mapEventToState(
    PreloadEvent event,
  ) async* {
    yield* event.map(
      updatePostsByUserGenre: (e) async* {
        state.urls.clear();
        await ApiService.loadFreeOnly();
        log("Loaded new");
        final List<Video> _urls = await ApiService.getVideos();
        state.urls
            .addAll(_urls.where((element) => element.isFree == true).toList());
        final List<Video> _genreUrls =
            await ApiService.loadBasedOnUserGenre(e.userGenre);
        log("Loaded genre vids ${_genreUrls.length}");

        for (Video video in _genreUrls) {
          var contain = state.urls.where((element) => element.id == video.id);
          if (contain.isEmpty) {
            state.urls.insert(0, video);
          }
          // //value not exists
          // else {}
        }

        log("state length in free this one == ${state.urls.length}");
        log("focused index == ${state.focusedIndex} ||");

        /// Initialize 1st video
        await _initializeControllerAtIndex(0);

        /// Play 1st video
        _playControllerAtIndex(0);

        /// Initialize 2nd video
        await _initializeControllerAtIndex(1);

        yield state.copyWith(
          urls: state.urls,
          isLoading: false,
          focusedIndex: 0,
        );
      },
      setLoadingForFilter: (e) async* {
        yield state.copyWith(isLoadingFilter: e.loadingVal);
      },
      setLoading: (e) async* {
        yield state.copyWith(isLoading: e.isLoading);
      },
      filterBetweenFreePaid: (e) async* {
        log("${e.filterOption} Anket chosen");
        switch (e.filterOption) {
          case HomeScreenOptions.Free:
            yield state.copyWith(focusedIndex: 0);
            state.urls.clear();
            await ApiService.loadFreeOnly();
            log("Loaded new");
            final List<Video> _urls = await ApiService.getVideos();
            state.urls.addAll(
                _urls.where((element) => element.isFree == true).toList());

            log("state length in free == ${state.urls.length}");
            log("focused index == ${state.focusedIndex} ||");

            /// Initialize 1st video
            await _initializeControllerAtIndex(0);

            /// Play 1st video
            _playControllerAtIndex(0);

            /// Initialize 2nd video
            await _initializeControllerAtIndex(1);

            yield state.copyWith(
              filterOption: e.filterOption,
              isLoading: false,
              focusedIndex: 0,
            );

            break;
          case HomeScreenOptions.Paid:
            state.urls.clear();
            await ApiService.loadPaidOnly();
            final List<Video> _urls = await ApiService.getVideos();
            state.urls.addAll(
                _urls.where((element) => element.isPaid == true).toList());

            log("state length in paid == ${state.urls.length}");

            /// Initialize 1st video
            await _initializeControllerAtIndex(0);

            /// Play 1st video
            _playControllerAtIndex(0);

            /// Initialize 2nd video
            await _initializeControllerAtIndex(1);
            log("in paid");

            yield state.copyWith(
                filterOption: e.filterOption, isLoading: false);

            break;

          case HomeScreenOptions.Both:
            state.urls.clear();
            await ApiService.load();
            final List<Video> _urls = await ApiService.getVideos();
            state.urls.addAll(_urls);
            log("state length in both == ${state.urls.length}");

            /// Initialize 1st video
            await _initializeControllerAtIndex(0);

            /// Play 1st video
            _playControllerAtIndex(0);

            /// Initialize 2nd video
            await _initializeControllerAtIndex(1);

            yield state.copyWith(
                filterOption: e.filterOption, isLoading: false);
            break;
        }
      },
      getVideosFromApi: (e) async* {
        log("running isolate");

        /// Fetch first 5 videos from api
        await ApiService.loadFreeOnly();
        final List<Video> _urls = await ApiService.getVideos();
        state.urls.addAll(_urls);

        log("statelen = ${state.urls.length}");

        /// Initialize 1st video
        await _initializeControllerAtIndex(0);

        /// Play 1st video
        _playControllerAtIndex(0);

        /// Initialize 2nd video
        await _initializeControllerAtIndex(1);

        yield state.copyWith(
            reloadCounter: state.reloadCounter + 1, isLoading: false);
      },
      // initialize: (e) async* {},
      onVideoIndexChanged: (e) async* {
        /// Condition to fetch new videos
        log("index == ${e.index}");

        final bool shouldFetch = (e.index + kPreloadLimit) % kNextLimit == 0 &&
            state.urls.length == e.index + kPreloadLimit;

        if (e.index == state.urls.length - 1) {
          log("running now");
          createIsolate(state.urls.length - 1);
        }

        if (shouldFetch) {
          // createIsolate(e.index);
        }

        /// Next / Prev video decider
        if (e.index > state.focusedIndex) {
          _playNext(e.index);
        } else {
          _playPrevious(e.index);
        }

        yield state.copyWith(focusedIndex: e.index);
      },
      updateUrls: (e) async* {
        /// Add new urls to current urls
        log("run now!!!!!!!!!!!");
        state.urls.addAll(e.urls);

        // /// Initialize new url
        _initializeControllerAtIndex(state.focusedIndex + 1);

        yield state.copyWith(
            reloadCounter: state.reloadCounter + 1, isLoading: false);
        log('🚀🚀🚀 NEW VIDEOS ADDED');
      },
    );
  }

  void testBloc() {}

  void _playNext(int index) {
    /// Stop [index - 1] controller
    _stopControllerAtIndex(index - 1);

    /// Dispose [index - 2] controller
    _disposeControllerAtIndex(index - 2);

    /// Play current video (already initialized)
    _playControllerAtIndex(index);

    /// Initialize [index + 1] controller
    _initializeControllerAtIndex(index + 1);
  }

  void _playPrevious(int index) {
    /// Stop [index + 1] controller
    _stopControllerAtIndex(index + 1);

    /// Dispose [index + 2] controller
    _disposeControllerAtIndex(index + 2);

    /// Play current video (already initialized)
    _playControllerAtIndex(index);

    /// Initialize [index - 1] controller
    _initializeControllerAtIndex(index - 1);
  }

  Future _initializeControllerAtIndex(int index) async {
    log("Check this?");
    if (state.urls.length > index && index >= 0) {
      log("Now initalizing");

      /// Create new controller
      final VideoPlayerController _controller =
          VideoPlayerController.network(state.urls[index].videourl);

      /// Add to [controllers] list
      state.controllers[index] = _controller;

      /// Initialize
      await _controller.initialize();

      log('🚀🚀🚀 INITIALIZED $index');
    }
  }

  void _playControllerAtIndex(int index) {
    if (state.urls.length > index && index >= 0) {
      /// Get controller at [index]
      final VideoPlayerController _controller = state.controllers[index]!;
      log("Loaded now come back to homescreen to play");

      /// Play controller
      // _controller.play();
      _controller.setLooping(true);

      log('🚀🚀🚀 PLAYING $index');
    }
  }

  void _stopControllerAtIndex(int index) {
    if (state.urls.length > index && index >= 0) {
      /// Get controller at [index]
      final VideoPlayerController _controller = state.controllers[index]!;

      /// Pause
      _controller.pause();

      /// Reset postiton to beginning
      _controller.seekTo(const Duration());

      log('🚀🚀🚀 STOPPED $index');
    }
  }

  void _disposeControllerAtIndex(int index) {
    if (state.urls.length > index && index >= 0) {
      /// Get controller at [index]
      final VideoPlayerController? _controller = state.controllers[index];

      /// Dispose controller
      _controller?.dispose();

      if (_controller != null) {
        state.controllers.remove(_controller);
      }

      log('🚀🚀🚀 DISPOSED $index');
    }
  }
}
