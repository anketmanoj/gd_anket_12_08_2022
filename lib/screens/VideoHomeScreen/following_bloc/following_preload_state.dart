part of 'following_preload_bloc.dart';

@Freezed()
class FollowingPreloadState with _$FollowingPreloadState {
  factory FollowingPreloadState({
    required List<Video> urls,
    required Map<int, VideoPlayerController> controllers,
    required int focusedIndex,
    required int reloadCounter,
    required bool isLoading,
  }) = _FollowingPreloadState;

  factory FollowingPreloadState.initial() => FollowingPreloadState(
        focusedIndex: 0,
        reloadCounter: 0,
        isLoading: false,
        urls: [],
        controllers: {},
      );
}
