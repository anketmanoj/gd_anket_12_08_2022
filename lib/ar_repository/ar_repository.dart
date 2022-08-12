// import 'package:diamon_rose_app/my_ar_entity/get_ar_param_entity.dart';

// class ARRepository {
//   ARRepository._();

//   static final ARRepository _instance = ARRepository._();

//   static ARRepository get instance => _instance;

//   void getARList({
//     required GetARParamEntity queryParameters,
//     required HttpRequestCallBack onStart,
//     required HttpCallBack<BaseListResponseEntity<MyAREntity>> onSuccess,
//     required HttpCallBack<List<String>>? onError,
//   }) {
//     final url = HttpApi.getMyAR;
//     HttpRequest.getInstance()
//         ?.get<BaseResponseEntity, BaseListResponseEntity<MyAREntity>>(url,
//             queryParameters: queryParameters.toJson(),
//             onStart: onStart,
//             onSuccess: onSuccess,
//             onError: onError);
//   }
// }
