import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;

getHttpClient() {
  Dio client = Dio();
  client.options.headers['content-Type'] = 'application/json';
  return client;
}
