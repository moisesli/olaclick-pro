// To parse this JSON data, do
//
//     final pushResponseModel = pushResponseModelFromJson(jsonString);

import 'dart:convert';

PushResponseModel pushResponseModelFromJson(String str) => PushResponseModel.fromJson(json.decode(str));

String pushResponseModelToJson(PushResponseModel data) => json.encode(data.toJson());

class PushResponseModel {
  PushResponseModel({
    this.message,
    this.data,
  });

  final String? message;
  final Data? data;

  factory PushResponseModel.fromJson(Map<String, dynamic> json) => PushResponseModel(
        message: json["message"] == null ? null : json["message"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "message": message == null ? null : message,
        "data": data == null ? null : data!.toJson(),
      };
}

class Data {
  Data({
    this.companyId,
    this.pushToken,
    this.updatedAt,
    this.createdAt,
    this.id,
  });

  final String? companyId;
  final String? pushToken;
  final DateTime? updatedAt;
  final DateTime? createdAt;
  final int? id;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        companyId: json["company_id"] == null ? null : json["company_id"],
        pushToken: json["push_token"] == null ? null : json["push_token"],
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        id: json["id"] == null ? null : json["id"],
      );

  Map<String, dynamic> toJson() => {
        "company_id": companyId == null ? null : companyId,
        "push_token": pushToken == null ? null : pushToken,
        "updated_at": updatedAt == null ? null : updatedAt!.toIso8601String(),
        "created_at": createdAt == null ? null : createdAt!.toIso8601String(),
        "id": id == null ? null : id,
      };
}
