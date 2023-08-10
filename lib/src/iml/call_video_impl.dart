import 'dart:convert';
import 'dart:io';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:call_video/src/config/app_config.dart';
import 'package:call_video/src/service/api.dart';
import 'package:call_video/src/service/common_repository.dart';
import 'package:call_video/src/service/entity/base_response.dart';
import 'package:call_video/src/service/entity/init_call_response.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';

import '../../call_video.dart';

class VideoCallImpl implements CallVideoController {
  final CommonRepository _commonRepository = CommonRepository();

  bool _isActive = false;

  @override
  Future<void> initialize() async {
    await [Permission.microphone, Permission.camera].request();
    await _initCall();

    ConfigAgora.engine = createAgoraRtcEngine();

    await ConfigAgora.engine.initialize(const RtcEngineContext(
      appId: ConfigAgora.appId,
      channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
    ));

    await ConfigAgora.engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    await ConfigAgora.engine.enableVideo();
    await ConfigAgora.engine.startPreview();

    await ConfigAgora.engine.joinChannel(
      token: ConfigAgora.token!,
      channelId: ConfigAgora.chanelId!,
      uid: ConfigAgora.uid!,
      options: const ChannelMediaOptions(),
    );

    _isActive = true;
  }

  @override
  void join({required void Function(bool) onJoinCallSuccess,
      required void Function(bool) onUserJoined,
      required void Function(int) onUserOffline,
      required void Function(ConnectionType) onConnectionStateChanged}) {
    if(!_isActive) {
      throw Exception("VideoCall has not been initialized.");
    }

    ConfigAgora.engine.registerEventHandler(
      RtcEngineEventHandler(
          onJoinChannelSuccess: (RtcConnection channel, int uid) {
            final isJoinChanel = channel.localUid == ConfigAgora.uid;

            if(isJoinChanel) _callHook();
            onJoinCallSuccess(isJoinChanel);
          },

          onUserJoined: (RtcConnection channel, int uid, int elapsed) {
            ConfigAgora.remoteUid = uid;

            final isUserJoined = ConfigAgora.remoteUid != 0;

            onUserJoined(isUserJoined);
          },

          onUserOffline: (RtcConnection rtcConnection,int uid, UserOfflineReasonType reason) {
            onUserOffline(uid);
          },

          onConnectionStateChanged: (RtcConnection rtcConnection, ConnectionStateType type, ConnectionChangedReasonType reason) {
            switch(type) {
              case ConnectionStateType.connectionStateConnecting: {
                return onConnectionStateChanged(ConnectionType.connecting);
              }

              case ConnectionStateType.connectionStateConnected: {
                return onConnectionStateChanged(ConnectionType.connected);
              }

              case ConnectionStateType.connectionStateReconnecting: {
                return onConnectionStateChanged(ConnectionType.reconnecting);
              }

              case ConnectionStateType.connectionStateDisconnected: {
                ConfigAgora.engine.leaveChannel();
                return onConnectionStateChanged(ConnectionType.disconnected);
              }

              case ConnectionStateType.connectionStateFailed: {
                ConfigAgora.engine.leaveChannel();
                return onConnectionStateChanged(ConnectionType.failed);
              }
            }
          }
      ));
  }

  @override
  void switchCamera() {
    if(!_isActive) {
      throw Exception("VideoCall has not been initialized.");
    }

    ConfigAgora.engine.switchCamera();
  }

  @override
  void leaveSession() async {
    if(!_isActive) {
      throw Exception("VideoCall has not been initialized.");
    }

    final sessionKey = ConfigAgora.chanelId!;

    final data = {
      'sessionKey': sessionKey,
      'type': 'USER',
    };

    ConfigSocket().stopSocket();
    await ConfigAgora.engine.leaveChannel();
    await _commonRepository.closeVideo(data);
    _isActive = false;
  }

  @override
  void dispose() async {
    await ConfigAgora.engine.leaveChannel();
    ConfigAgora.engine.release();
  }

  @override
  Future<void> saveFile({required String uri, required BuildContext context}) async {
    if(!_isActive) {
      throw Exception("VideoCall has not been initialized.");
    }

    // bool _isDownloaded = false;
    String progress = '0';

    String savePath = await _getFilePath(uri);
    API.instance().download(
      uri,
      savePath,
      onReceiveProgress: (rcv, total) {
        progress = ((rcv / total) * 100).toStringAsFixed(0);
        print(progress);

        if (progress == '100') {
          // _isDownloaded = true;
        } else if (double.parse(progress) < 100) {}
      },
      deleteOnError: true,
    ).then((_) {
      if (progress == '100' && context.mounted) {
        // _isDownloaded = true;

        const snackBar = SnackBar(
          content: Text('Save File Success'),
        );

        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    });
  }

  Future<void> _callHook () async {
    final sessionId = ConfigAgora.chanelId!;
    final sessionKey = sessionId;

    final Map<String,dynamic> data = {
      "sessionKey" : sessionId,
      "sessionId" : sessionKey
    };

    BaseResponse res = await _commonRepository.hook(data);


    if(res.status == true) _initSocket();
  }

  void _initSocket() {
    if (ConfigSocket.stompClient?.isActive == true) {
      return;
    }

    final Map<String, String> stompConnectHeaders = {
      'Access-Control-Allow-Origin': '*',
      'deviceInfo': json.encode(
        {
          'os': 'os',
          'browser': 'browser',
          'device': 'device',
        },
      ),
    };

    ConfigSocket.stompClient = StompClient(
      config: StompConfig.SockJS(
        url: ConfigSocket.baseUrl,
        onConnect: ConfigSocket().onConnect,
        connectionTimeout: const Duration(milliseconds: 30000),
        heartbeatIncoming: const Duration(milliseconds: 5000),
        heartbeatOutgoing: const Duration(milliseconds: 5000),
        reconnectDelay: const Duration(milliseconds: 5000),
        beforeConnect: () async => print('---------connecting...'),
        onWebSocketError: (dynamic error) => print('SocketError: ${error.toString()}'),
        stompConnectHeaders: stompConnectHeaders,
      ),
    );

    ConfigSocket.stompClient?.activate();
  }

  Future<void> _initCall() async {

    /// Get Device Info
    Map<String, dynamic> deviceData = {"os": "", "browser": "", "device": "", "deviceId": ""};
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      deviceData['os'] = 'Android ' + Platform.operatingSystemVersion;
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      deviceData['device'] = androidInfo.model;
      deviceData['deviceId'] = androidInfo.id;
    } else if (Platform.isIOS) {
      deviceData['os'] = 'iOS ' + Platform.operatingSystemVersion;
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      deviceData['device'] = iosInfo.model;
      deviceData['deviceId'] = iosInfo.identifierForVendor;
    }

    /// Hash Code appointmentId
    final appointmentId = "6bebdd2a-4a23-419d-8049-f0216ea2157f";

    Map<String,dynamic> data = {
      "appointmentId": appointmentId,
      "deviceInfo": deviceData
    };

    InitCallResponse res = await _commonRepository.initCall(data);
    if(res.status == true) {
      final agoraInfo = res.data!;

      ConfigAgora.token = agoraInfo.code;
      ConfigAgora.chanelId = agoraInfo.sessionId;
      ConfigAgora.uid = int.tryParse(agoraInfo.subId!);
    } else return;
  }

  Future<String> _getFilePath(String uri) async {
    String path = '';
    Directory? dir;
    String filename = uri.split('/').last;
    if (Platform.isIOS) {
      dir = await getApplicationDocumentsDirectory();
    } else {
      const downloadsFolderPath = '/storage/emulated/0/Download/';
      dir = Directory(downloadsFolderPath);
    }

    path = '${dir.path}/$filename';

    return path;
  }

}