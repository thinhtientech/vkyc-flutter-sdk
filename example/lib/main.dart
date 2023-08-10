import 'package:flutter/material.dart';
import 'package:call_video/call_video.dart';

void main() => runApp(const MyHomePage());

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late CallVideoController callVideoController;
  bool _localUserJoined = false;
  bool _remoteUserJoined = false;
  bool _muted = false;

  // Build UI
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Get started with Video Calling'),
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            children: [
              // Container for the local video
            if(_localUserJoined) Container(
                height: 240,
                decoration: BoxDecoration(border: Border.all()),
                child: const Center(child: LocalVideoView()),
              ),
              const SizedBox(height: 10),
              //Container for the Remote video
              if(_remoteUserJoined) Container(
                height: 240,
                decoration: BoxDecoration(border: Border.all()),
                child: const Center(child: RemoteVideoView()),
              ),
              // Button Row
              Row(
                children: <Widget>[
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _localUserJoined
                          ? null : callVideoController.initialize,
                      child: const Text("Join"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _localUserJoined
                          ? callVideoController.leaveSession : null,
                      child: const Text("Leave"),
                    ),
                  ),
                ],
              ),
              // Button Row ends
            ],
          )),
    );
  }

  @override
  void initState() {
    initVideoCall();
    super.initState();
  }

  Future<void> initVideoCall() async {
    callVideoController = createVideoCall();

    await callVideoController.initialize();

    callVideoController.join(
        onJoinCallSuccess: (bool isJoinCall) {
          setState(() {
            _localUserJoined = isJoinCall;
          });
        },
        onUserJoined: (bool isUserJoined) {
          setState(() {
            _remoteUserJoined = isUserJoined;
          });
        },
        onUserOffline: (int uid) {
          setState(() {
            _remoteUserJoined = false;
          });
        },
        onConnectionStateChanged: (ConnectionType type) {
          print("objectvvv $type");
          if(type == ConnectionType.failed || type == ConnectionType.disconnected){
            setState(() {
              _remoteUserJoined = false;
              _localUserJoined = false;
            });
          }
        }
    );
  }

  @override
  void dispose() {
    callVideoController.dispose();
    super.dispose();
  }
}
