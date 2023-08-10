// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'init_call_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InitCallResponse _$InitCallResponseFromJson(Map<String, dynamic> json) =>
    InitCallResponse(
      data: json['data'] == null
          ? null
          : InitCallData.fromJson(json['data'] as Map<String, dynamic>),
    )
      ..status = json['status'] as bool?
      ..message = json['message'] as String?
      ..httpCode = json['httpCode'] as int?
      ..errorCode = json['errorCode'] as String?;

Map<String, dynamic> _$InitCallResponseToJson(InitCallResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'message': instance.message,
      'httpCode': instance.httpCode,
      'errorCode': instance.errorCode,
      'data': instance.data,
    };

InitCallData _$InitCallDataFromJson(Map<String, dynamic> json) => InitCallData(
      sessionId: json['sessionId'] as String?,
      key: json['key'] as String?,
      code: json['code'] as String?,
      webcamToken: json['webcamToken'] as String?,
      screenToken: json['screenToken'] as String?,
      subId: json['subId'] as String?,
    );

Map<String, dynamic> _$InitCallDataToJson(InitCallData instance) =>
    <String, dynamic>{
      'sessionId': instance.sessionId,
      'key': instance.key,
      'code': instance.code,
      'webcamToken': instance.webcamToken,
      'screenToken': instance.screenToken,
      'subId': instance.subId,
    };
