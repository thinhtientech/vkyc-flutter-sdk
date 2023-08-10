import 'package:json_annotation/json_annotation.dart';

part 'base_response.g.dart';

@JsonSerializable()
class BaseResponse {
  bool? status;
  String? message;
  int? httpCode;
  String? errorCode;

  BaseResponse(
      {this.status, this.message, this.httpCode, this.errorCode});

  factory BaseResponse.fromJson(Map<String, dynamic> json) => _$BaseResponseFromJson(json);

  Map<String, dynamic> toJson() => _$BaseResponseToJson(this);
}