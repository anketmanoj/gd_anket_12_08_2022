part of 'preload_bloc.dart';

@Freezed()
class PreloadState with _$PreloadState {
  factory PreloadState({
    required List<Video> urls,
    required Map<int, VideoPlayerController> controllers,
    required int focusedIndex,
    required int reloadCounter,
    required bool isLoading,
    required HomeScreenOptions filterOption,
    required bool isLoadingFilter,
  }) = _PreloadState;

  factory PreloadState.initial() => PreloadState(
        focusedIndex: 0,
        reloadCounter: 0,
        isLoading: true,
        urls: [],
        controllers: {},
        filterOption: HomeScreenOptions.Free,
        isLoadingFilter: false,
      );
}
