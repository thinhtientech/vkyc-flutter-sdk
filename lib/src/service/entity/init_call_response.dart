import 'package:json_annotation/json_annotation.dart';

import 'base_response.dart';

part 'init_call_response.g.dart';

@JsonSerializable()
class InitCallResponse extends BaseResponse {
  InitCallData? data;

  InitCallResponse({this.data});

  factory InitCallResponse.fromJson(Map<String, dynamic> json) => _$InitCallResponseFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$InitCallResponseToJson(this);
}

@JsonSerializable()
class InitCallData {
  String? sessionId;
  String? key;
  String? code;
  String? webcamToken;
  String? screenToken;
  String? subId;

  InitCallData(
      {this.sessionId,
        this.key,
        this.code,
        this.webcamToken,
        this.screenToken,
        this.subId});

  factory InitCallData.fromJson(Map<String, dynamic> json) => _$InitCallDataFromJson(json);

  Map<String, dynamic> toJson() => _$InitCallDataToJson(this);
}