import 'package:call_video/src/config/connection_state.dart';
import 'package:flutter/cupertino.dart';

import '../impl/call_video_impl.dart';

/// Creates one CallVideo object.
///
/// Currently, the Call Video SDK supports creating only one CallVideo object for each app.
///
/// Returns
/// One CallVideo object.
CallVideoController createVideoCall(){
  return VideoCallImpl();
}

abstract class CallVideoController {

  /// Initializes CallVideoController.
  ///
  /// All called methods provided by the CallVideoController class are executed asynchronously. We recommends calling these methods in the same thread. Before calling other APIs, you must call createVideoCall and initialize to create and initialize the CallVideo object. The SDK supports creating only one CallVideo instance for an app.
  ///
  /// * [context] Configurations for the CallVideoController instance.
  ///
  /// Returns
  /// When the method call succeeds, there is no return value; when fails, the Exception exception is thrown; and you need to catch the exception and handle it accordingly.
  Future<void> initialize({required String phoneNumber});

  /// Adds event handlers
  ///
  /// The app inherits the methods of this class to receive these callbacks. All methods in this class have default (empty) implementations. Therefore, apps only need to inherits callbacks according to the scenarios. In the callbacks, avoid time-consuming tasks or calling APIs that can block the thread, such as the sendStreamMessage method.
  /// Otherwise, the SDK may not work properly.
  ///
  /// Returns
  /// When the method call succeeds, there is no return value; when fails, the Exception exception is thrown; and you need to catch the exception and handle it accordingly. < 0: Failure.
  void join({required void Function(bool) onJoinCallSuccess,
    required void Function(bool) onUserJoined,
    required void Function(int) onUserOffline,
    required void Function(ConnectionType) onConnectionStateChanged});

  /// Switches between front and rear cameras.
  ///
  /// This method needs to be called after the camera is started (for example, by calling startPreview or joinChannel ). This method is for Android and iOS only.
  ///
  /// Returns
  /// When the method call succeeds, there is no return value; when fails, the Exception exception is thrown; and you need to catch the exception and handle it accordingly. < 0: Failure.
  void switchCamera();

  /// Sets channel options and leaves the channel.
  ///
  /// If you call release immediately after calling this method, the SDK does not trigger the onLeaveChannel callback. This method will release all resources related to the session, leave the channel, that is, hang up or exit the call. This method can be called whether or not a call is currently in progress. After joining the channel, you must call this method or to end the call, otherwise, the next call cannot be started. This method call is asynchronous. When this method returns, it does not necessarily mean that the user has left the channel. After actually leaving the channel, the local user triggers the onLeaveChannel callback; after the user in the communication scenario and the host in the live streaming scenario leave the channel, the remote user triggers the onUserOffline callback.
  ///
  /// Returns
  /// When the method call succeeds, there is no return value; when fails, the Exception exception is thrown; and you need to catch the exception and handle it accordingly. < 0: Failure.
  void leaveSession();

  void checkKyc({required String id,required String dob, required String doe,required Function(String) onError});

  /// Release the resources used by your app
  ///
  /// Returns
  /// When the method call succeeds, there is no return value; when fails, the Exception exception is thrown; and you need to catch the exception and handle it accordingly. < 0: Failure.
  void dispose();

  /// Save documents, photos to your device's files
  ///
  /// * [context] Configurations for the CallVideoController instance.
  Future<void> saveFile ({required String uri, required BuildContext context});
}