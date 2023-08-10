import 'package:call_video/src/service/entity/base_response.dart';
import 'package:call_video/src/service/entity/init_call_response.dart';
import 'package:dio/dio.dart';

import '../config/network_config.dart';
import 'api.dart';

class CommonRepository {
  Future<InitCallResponse> initCall(Map<String, dynamic> data) async {
    Response response = await API.instance().post(NetWorkConfig.initCall, data: data);
    return InitCallResponse.fromJson(response.data);
  }

  Future<BaseResponse> hook(Map<String, dynamic> data) async {
    Response response = await API.instance().post(NetWorkConfig.hook, data: data);
    return BaseResponse.fromJson(response.data);
  }

  Future<BaseResponse> closeVideo(Map<String, dynamic> data) async {
    Response response = await API.instance().post(NetWorkConfig.closeVideo, data: data);
    return BaseResponse.fromJson(response.data);
  }
}