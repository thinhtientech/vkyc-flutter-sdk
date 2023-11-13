import 'dart:convert';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:call_video/src/impl/call_video_impl.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
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

  void initSocket() {
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
        onConnect: onConnect,
        connectionTimeout: const Duration(milliseconds: 30000),
        heartbeatIncoming: const Duration(milliseconds: 5000),
        heartbeatOutgoing: const Duration(milliseconds: 5000),
        reconnectDelay: const Duration(milliseconds: 5000),
        beforeConnect: () async {},
        onWebSocketError: (dynamic error) {},
        stompConnectHeaders: stompConnectHeaders,
      ),
    );

    ConfigSocket.stompClient?.activate();
  }

  void stopSocket() {
    if (stompClient?.isActive == true) {
      stompClient?.deactivate();
    }
  }

  void onConnect(StompFrame frame) {

    final sessionKey = ConfigAgora.chanelId;
    final socketId = stompClient?.config.url.split('websocket-agent/')[1].split('/')[1] ?? '';

    stompClient?.subscribe(
      destination: '/user/$sessionKey/notify',
      callback: (frame) {
        if (frame.body?.contains(SocketCode.LEGAL_PAPERS_PASSED) == true) {

        }
        if (frame.body?.contains(SocketCode.END_CALL) == true) {

          stopSocket();
        }
        if (frame.body?.contains(SocketCode.CALL_EXPIRED) == true) {

          stopSocket();
          VideoCallImpl().leaveSession();
        }
        if (frame.body?.contains(SocketCode.CALL_TIMEOUT) == true) {

          stopSocket();
        }
      },
    );
    stompClient?.subscribe(
      destination: '/user/$socketId/notify',
      callback: (frame) {
        if (frame.body?.contains(SocketCode.CALL_TIMEOUT) == true) {

        }
      },
    );
    stompClient?.subscribe(
      destination: '/user/$socketId/health',
      callback: (frame) {

      },
    );
    stompClient?.subscribe(
      destination: '/app/live',
      callback: (frame) {

      },
    );
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