import 'dart:async';
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
import 'package:freezed_annotation/freezed_annotation.dart';

part 'following_preload_bloc.freezed.dart';
part 'following_preload_event.dart';
part 'following_preload_state.dart';

@injectable
@prod
class FollowingPreloadBloc
    extends Bloc<FollowingPreloadEvent, FollowingPreloadState> {
  FollowingPreloadBloc() : super(FollowingPreloadState.initial());

  @override
  Stream<FollowingPreloadState> mapEventToState(
    FollowingPreloadEvent event,
  ) async* {
    yield* event.map(
      setLoadingForFilter: (e) async* {
        yield state.copyWith(isLoadingFilter: e.loadingVal);
      },
      setLoading: (e) async* {
        yield state.copyWith(isLoading: e.isLoading);
      },
      userFollowsNoOne: (e) async* {
        yield state.copyWith(userFollowsNoOne: e.userFollowsNoOne);
      },
      filterBetweenFreePaid: (e) async* {
        log("${e.filterOption} Anket Following chosen");
        switch (e.filterOption) {
          case HomeScreenOptions.Free:
            yield state.copyWith(isLoading: true);
            state.urls.clear();
            await ApiService.loadFollowingFreeVideos();
            final List<Video> _urls = await ApiService.getFollowingVideos();
            state.urls.addAll(
                _urls.where((element) => element.isFree == true).toList());

            log("state length following in free == ${state.urls.length}");

            if (state.urls.isNotEmpty) {
              yield state.copyWith(noFollowingVideos: false);
            } else {
              yield state.copyWith(noFollowingVideos: true);
            }

            /// Initialize 1st video
            await _initializeControllerAtIndex(0);

            /// Play 1st video
            _playControllerAtIndex(0);

            /// Initialize 2nd video
            await _initializeControllerAtIndex(1);

            yield state.copyWith(
                filterOption: e.filterOption,
                isLoadingFilter: false,
                userFollowsNoOne: _urls.isNotEmpty ? false : true,
                noFollowingVideos: _urls.isNotEmpty ? false : true,
                isLoading: false);

            break;
          case HomeScreenOptions.Paid:
            yield state.copyWith(isLoading: true);
            state.urls.clear();
            await ApiService.loadFollowingPaidVideos();
            final List<Video> _urls = await ApiService.getFollowingVideos();
            state.urls.addAll(
                _urls.where((element) => element.isPaid == true).toList());

            log("state length following in paid == ${state.urls.length}");

            if (state.urls.isNotEmpty) {
              yield state.copyWith(noFollowingVideos: false);
            } else {
              yield state.copyWith(noFollowingVideos: true);
            }

            /// Initialize 1st video
            await _initializeControllerAtIndex(0);

            /// Play 1st video
            _playControllerAtIndex(0);

            /// Initialize 2nd video
            await _initializeControllerAtIndex(1);
            log("in paid");

            yield state.copyWith(
                filterOption: e.filterOption,
                isLoadingFilter: false,
                userFollowsNoOne: _urls.isNotEmpty ? false : true,
                noFollowingVideos: _urls.isNotEmpty ? false : true,
                isLoading: false);

            break;

          case HomeScreenOptions.Both:
            yield state.copyWith(isLoading: true);
            state.urls.clear();
            await ApiService.loadFollowingVideos();
            final List<Video> _urls = await ApiService.getFollowingVideos();

            state.urls.addAll(_urls);
            state.urls.shuffle();
            log("################# len = ${state.urls.length}");

            log("here no in both | ${state.urls.length}");

            if (state.urls.isNotEmpty) {
              log("not empty following val");
              yield state.copyWith(noFollowingVideos: false);
            } else {
              log(" empty following val");
              yield state.copyWith(noFollowingVideos: true);
            }

            /// Initialize 1st video
            await _initializeControllerAtIndex(0);

            /// Play 1st video
            _playControllerAtIndex(0);

            /// Initialize 2nd video
            await _initializeControllerAtIndex(1);

            yield state.copyWith(
                userFollowsNoOne: _urls.isNotEmpty ? false : true,
                noFollowingVideos: _urls.isNotEmpty ? false : true,
                filterOption: e.filterOption,
                isLoadingFilter: false,
                isLoading: false);
            break;
        }
      },
      getVideosFromApi: (e) async* {
        /// Fetch first 5 videos from api
        await ApiService.loadFollowingVideos();
        final List<Video> _urls = await ApiService.getFollowingVideos();
        state.urls.addAll(_urls);
        state.urls.shuffle();

        yield state.copyWith(isLoadingFilter: false);

        if (state.urls.isNotEmpty) {
          yield state.copyWith(noFollowingVideos: false);
        } else {
          yield state.copyWith(noFollowingVideos: true);
        }

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
        final bool shouldFetch = (e.index + kPreloadLimit) % kNextLimit == 0 &&
            state.urls.length == e.index + kPreloadLimit;

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
        state.urls.addAll(e.urls);

        /// Initialize new url
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
    if (state.urls.length > index && index >= 0) {
      log("we're here == ${state.urls[index].videotitle}");

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
