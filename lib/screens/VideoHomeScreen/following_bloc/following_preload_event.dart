part of 'following_preload_bloc.dart';

@freezed
class FollowingPreloadEvent with _$FollowingPreloadEvent {
  // const factory FollowingPreloadEvent.initialize() = _Initialize;
  const factory FollowingPreloadEvent.getVideosFromApi() = _GetVideosFromApi;
  const factory FollowingPreloadEvent.setLoading(bool isLoading) = _SetLoading;
  const factory FollowingPreloadEvent.updateUrls(List<Video> urls) =
      _UpdateUrls;
  const factory FollowingPreloadEvent.onVideoIndexChanged(int index) =
      _OnVideoIndexChanged;
  const factory FollowingPreloadEvent.filterBetweenFreePaid(
      HomeScreenOptions filterOption) = _FilterBetweenFreePaid;
  const factory FollowingPreloadEvent.setLoadingForFilter(bool loadingVal) =
      _SetLoadingForFilter;
  const factory FollowingPreloadEvent.userFollowsNoOne(bool userFollowsNoOne) =
      _UserFollowsNoOne;
}
