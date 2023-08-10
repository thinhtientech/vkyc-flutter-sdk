import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:call_video/src/iml/call_video_impl.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

class ConfigAgora {
  static late RtcEngine engine;

  static const String appId = '7943438693ba44f9aa56a747d8dd27d2';
  static String? token;
  static String? chanelId;
  static int? uid;
  static int remoteUid = 0;
}

class ConfigSocket {
  static StompClient? stompClient;

  static const baseUrl = "https://test-usocket.mobifi.vn/websocket-agent";

  void onConnect(StompFrame frame) {

    final sessionKey = ConfigAgora.chanelId;
    final socketId = stompClient?.config.url.split('websocket-agent/')[1].split('/')[1] ?? '';
    print('---------socket: connected! $socketId');

    stompClient?.subscribe(
      destination: '/user/$sessionKey/notify',
      callback: (frame) {
        print('---------socket: sessionKey/notify');
        print(frame.body);
        if (frame.body?.contains(SocketCode.LEGAL_PAPERS_PASSED) == true) {
          print('---------socket: legal papers passed116!');
        }
        if (frame.body?.contains(SocketCode.END_CALL) == true) {
          print('---------socket: end call!');
          stopSocket();
        }
        if (frame.body?.contains(SocketCode.CALL_EXPIRED) == true) {
          print('---------socket: call expired!');
          stopSocket();
          VideoCallImpl().leaveSession();
        }
        if (frame.body?.contains(SocketCode.CALL_TIMEOUT) == true) {
          print('---------socket: call timeout!');
          stopSocket();
        }
      },
    );
    stompClient?.subscribe(
      destination: '/user/$socketId/notify',
      callback: (frame) {
        print('---------socket: socketId/notify');
        print(frame.body);
        if (frame.body?.contains(SocketCode.CALL_TIMEOUT) == true) {
          print('---------socket: call timeout!');
        }
      },
    );
    stompClient?.subscribe(
      destination: '/user/$socketId/health',
      callback: (frame) {
        print(frame.body);
      },
    );
    stompClient?.subscribe(
      destination: '/app/live',
      callback: (frame) {
        print(frame.body);
      },
    );
  }

  void stopSocket() {
    print('socket: disconnecting...');
    if (stompClient?.isActive == true) {
      stompClient?.deactivate();
    }
    print('socket: disconnected!');
  }
}

class SocketCode {
  // type
  static String TYPE = 'type';
  static String LEGAL_PAPERS_PASSED = 'LEGAL_PAPERS_PASSED';
  static String CALL_EXPIRED = 'CALL_EXPIRED';
  static String CALL_TIMEOUT = 'CALL_TIMEOUT';

  // event type
  static String EVENT_TYPE = 'eventType';
  static String END_CALL = 'END_CALL';
}