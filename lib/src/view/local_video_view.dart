import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:call_video/src/config/app_config.dart';
import 'package:flutter/material.dart';

/// A AgoraVideoView controller for rendering local video.
class LocalVideoView extends StatelessWidget {
  const LocalVideoView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AgoraVideoView(
      controller: VideoViewController(
        rtcEngine: ConfigAgora.engine,
        canvas: const VideoCanvas(uid: 0),
      ),
    );
  }
}