// import 'package:diamon_rose_app/screens/VideoWorkAll/create_wk_video_request/create_wk_video_request.dart';
// import 'package:dio/dio.dart' as dio;

// class VideoCreateRepository {
//   VideoCreateRepository._();

//   static final VideoCreateRepository _instance = VideoCreateRepository._();

//   static VideoCreateRepository get instance => _instance;

//   Future<void> requestUploadVideo({
//     required String filePath,
//     required String videoCaption,
//     required HttpRequestCallBack onStart,
//     required HttpCallBack onSuccess,
//     required HttpCallBack<List<String>> onError,
//   }) async {
//     onStart();
//     try {
//       final dio.FormData formData = dio.FormData.fromMap({
//         "file": await dio.MultipartFile.fromFile(filePath),
//         "videoCaption": videoCaption,
//       });
//       final token = await TokenLocalStorage.getToken();
//       final response = await dio.Dio().post(
//         "${NetworkConfig.getBaseUrl}${HttpApi.uploadLiveVideo}",
//         data: formData,
//         options: dio.Options(headers: {
//           '${NetworkConfig.authorization}': '${NetworkConfig.bearer} ${token}'
//         }),
//       );
//       final result = BaseResponseEntity<
//           BaseItemResponseEntity<VideoCreateEntity>>.fromJson(response.data);
//       if (result.status == true) {
//         onSuccess(result);
//       } else {
//         onError([result.messages.toString()]);
//       }
//     } on Exception catch (e) {
//       onError([e.toString()]);
//     }
//   }

//   void requestCreateWkVideo({
//     required String videoId,
//     required RequestCreateWkVideoModel requestCreateWkVideo,
//     required HttpRequestCallBack onStart,
//     required HttpCallBack onSuccess,
//     required HttpCallBack<List<String>>? onError,
//   }) {
//     final url = '${HttpApi.wkVideo}$videoId';
//     HttpRequest.getInstance()?.post<BaseResponseEntity<dynamic>, dynamic>(url,
//         data: BaseRequestEntity(data: requestCreateWkVideo.toJson()).encode(),
//         onStart: onStart,
//         onSuccess: onSuccess,
//         onError: onError);
//   }

//   void requestGetDraftVideo(
//       {required DraftVideoRequest draftVideoRequest,
//       required HttpRequestCallBack onStart,
//       required HttpCallBack<BaseListResponseEntity<MyDraftVideoEntity>>
//           onSuccess,
//       required HttpCallBack<List<String>>? onError}) {
//     final url = "${HttpApi.getDraftVideos}?sort=id,desc";

//     HttpRequest.getInstance()
//         ?.get<BaseResponseEntity, BaseListResponseEntity<MyDraftVideoEntity>>(
//             url,
//             queryParameters: draftVideoRequest.toJson(),
//             onStart: onStart,
//             onSuccess: onSuccess,
//             onError: onError);
//   }

//   void requestDeleteVideo(
//       {required int id,
//       required HttpRequestCallBack onStart,
//       required HttpCallBack onSuccess,
//       required HttpCallBack<List<String>>? onError}) {
//     final url = '${HttpApi.wkVideo}/$id';

//     HttpRequest.getInstance()?.delete<BaseResponseEntity<String>, dynamic>(
//       url,
//       onStart: onStart,
//       onSuccess: onSuccess,
//       onError: onError,
//       reLoginCallBack: (response) {},
//     );
//   }
// }
