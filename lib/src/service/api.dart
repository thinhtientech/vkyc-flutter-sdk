import 'package:dio/dio.dart';

class API {
  static String baseUrl = "https://test-ucore.mobifi.vn/api/v2/vekyc";

  static Dio instance() {
    final dio = Dio();
    dio
      ..options.baseUrl = baseUrl
      ..options.connectTimeout = const Duration(seconds: 30)
      ..options.receiveTimeout = const Duration(seconds: 60)
      ..options.headers = {
        "x-api-key": "MWE3ZDM1ODMtZTBlZS00NzcyLTllMzQtYjA3ZWMwNTZkMTc5",
        "Content-Type": "application/json"
      }
      ..options.followRedirects = false
      ..options.receiveDataWhenStatusError = true;
    return dio;
  }
}