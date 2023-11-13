import 'dart:convert';
import 'dart:io';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:call_video/src/config/app_config.dart';
import 'package:call_video/src/service/network/api.dart';
import 'package:call_video/src/service/call_video_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../call_video.dart';
import '../config/methods.dart';

class VideoCallImpl implements CallVideoController {
  final CallVideoService _callVideoService = CallVideoService();

  final ConfigSocket _configSocket = ConfigSocket();
  bool _isActive = false;

  @override
  Future<void> initialize({required String phoneNumber}) async {
    await [Permission.microphone, Permission.camera].request();
    await _callVideoService.initCall(phoneNumber: phoneNumber);

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

            if(isJoinChanel) _callVideoService.callHook();
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

    _configSocket.stopSocket();
    await ConfigAgora.engine.leaveChannel();
    await _callVideoService.closeVideo(sessionKey);
    _isActive = false;
  }

  @override
  void checkKyc({required String id,required String dob, required String doe,required Function(String) onError}) async {
    if(!_isActive) {
      throw Exception("VideoCall has not been initialized.");
    }

    final MethodChannel _channel = const MethodChannel(Methods.channelName);

    try {
      final String? startNFC = await _channel.invokeMethod(Methods.startNFC, {
            "id" : id,
            'dob': dob,
            'doe': doe
          });

      // Check json data from IOS.
      final jsonData = startNFC?.replaceAll("[", "{").replaceAll("]", "}");

      if(jsonData!.contains("{")){
        final result = json.decode(jsonData);

        print("success");
        print(result);
      } else {
        onError(jsonData);
      }
    } catch(e){
      onError(e.toString());
    }
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