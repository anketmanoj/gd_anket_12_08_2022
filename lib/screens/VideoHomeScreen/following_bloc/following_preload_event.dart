part of 'following_preload_bloc.dart';

@freezed
class FollowingPreloadEvent with _$FollowingPreloadEvent {
  // const factory FollowingPreloadEvent.initialize() = _Initialize;
  const factory FollowingPreloadEvent.getVideosFromApi() = _GetVideosFromApi;
  const factory FollowingPreloadEvent.setLoading() = _SetLoading;
  const factory FollowingPreloadEvent.updateUrls(List<Video> urls) =
      _UpdateUrls;
  const factory FollowingPreloadEvent.onVideoIndexChanged(int index) =
      _OnVideoIndexChanged;
}
