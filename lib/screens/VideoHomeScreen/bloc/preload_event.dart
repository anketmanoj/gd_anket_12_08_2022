part of 'preload_bloc.dart';

@freezed
class PreloadEvent with _$PreloadEvent {
  // const factory PreloadEvent.initialize() = _Initialize;
  const factory PreloadEvent.getVideosFromApi() = _GetVideosFromApi;
  const factory PreloadEvent.setLoading(bool isLoading) = _SetLoading;
  const factory PreloadEvent.updateUrls(List<Video> urls) = _UpdateUrls;
  const factory PreloadEvent.onVideoIndexChanged(int index) =
      _OnVideoIndexChanged;
  const factory PreloadEvent.filterBetweenFreePaid(
      HomeScreenOptions filterOption) = _FilterBetweenFreePaid;
  const factory PreloadEvent.setLoadingForFilter(bool loadingVal) =
      _SetLoadingForFilter;
  const factory PreloadEvent.updatePostsByUserGenre(List<String> userGenre) =
      _UpdatePostsByUserGenre;
}
