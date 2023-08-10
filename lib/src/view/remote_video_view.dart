import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:call_video/src/config/app_config.dart';
import 'package:flutter/material.dart';

/// A AgoraVideoView controller for rendering remote video.
class RemoteVideoView extends StatelessWidget {
  const RemoteVideoView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AgoraVideoView(
      controller: VideoViewController.remote(
        rtcEngine: ConfigAgora.engine,
        canvas: VideoCanvas(uid: ConfigAgora.remoteUid),
        connection: RtcConnection(channelId: ConfigAgora.chanelId),
      ),
    );
  }
}