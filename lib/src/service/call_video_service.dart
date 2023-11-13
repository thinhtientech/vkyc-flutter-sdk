import 'dart:io';

import 'package:call_video/src/service/network/common_repository.dart';
import 'package:device_info_plus/device_info_plus.dart';

import '../config/app_config.dart';
import 'entity/base_response.dart';
import 'entity/init_call_response.dart';

class CallVideoService {
  final CommonRepository _commonRepository = CommonRepository();

  final ConfigSocket _configSocket = ConfigSocket();

  Future<void> callHook() async {
    final sessionId = ConfigAgora.chanelId!;
    final sessionKey = sessionId;

    final Map<String,dynamic> data = {
      "sessionKey" : sessionId,
      "sessionId" : sessionKey
    };

    BaseResponse res = await _commonRepository.hook(data);


    if(res.status == true) _configSocket.initSocket();
  }

  Future<void> initCall({required String phoneNumber}) async {

    /// Get Device Info
    Map<String, dynamic> deviceData = {"os": "", "browser": "", "device": "", "deviceId": ""};
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      deviceData['os'] = 'Android ${Platform.operatingSystemVersion}';
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      deviceData['device'] = androidInfo.model;
      deviceData['deviceId'] = androidInfo.id;
    } else if (Platform.isIOS) {
      deviceData['os'] = 'iOS ${Platform.operatingSystemVersion}';
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      deviceData['device'] = iosInfo.model;
      deviceData['deviceId'] = iosInfo.identifierForVendor;
    }

    Map<String,dynamic> data = {
      "phone_number": phoneNumber,
      "deviceInfo": deviceData
    };

    InitCallResponse res = await _commonRepository.initCall(data);
    if(res.status == true) {
      final agoraInfo = res.data!;

      ConfigAgora.token = agoraInfo.code;
      ConfigAgora.chanelId = agoraInfo.sessionId;
      ConfigAgora.uid = int.tryParse(agoraInfo.subId!);
    } else {
      throw Exception(res.message);
    }
  }

  Future<void> closeVideo(String sessionKey) async {
    final data = {
      'sessionKey': sessionKey,
      'type': 'USER',
    };

    await _commonRepository.closeVideo(data);
  }
}