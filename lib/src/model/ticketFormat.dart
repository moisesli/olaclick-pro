// To parse this JSON data, do
//
//     final formatModel = formatModelFromJson(jsonString);

import 'dart:convert';
// ignore: import_of_legacy_library_into_null_safe
import 'package:esc_pos_utils/esc_pos_utils.dart';

FormatModel formatModelFromJson(String str) => FormatModel.fromJson(json.decode(str));

String formatModelToJson(FormatModel data) => json.encode(data.toJson());

FormatModel formatModelFromMap(String str) => FormatModel.fromMap(json.decode(str));

String formatModelToMap(FormatModel data) => json.encode(data.toMap());

class FormatModel {
  FormatModel({
    required this.value,
    required this.align,
    required this.bold,
    required this.type,
    required this.height,
    required this.width,
  });

  String value;
  PosAlign align;
  bool bold;
  String type;
  PosTextSize height;
  PosTextSize width;

  factory FormatModel.fromJson(Map<String, dynamic> json) => FormatModel(
        value: json["value"],
        align: getStringToAlign(json["align"]),
        bold: getBoolToBold(json["bold"]),
        type: json["type"],
        height: getStringToSize(json["height"]),
        width: getStringToSize(json["width"]),
      );

  Map<String, dynamic> toJson() => {
        "value": value,
        "align": align,
        "bold": bold,
        "type": type,
        "height": height,
        "width": width,
      };

  factory FormatModel.fromMap(Map<String, dynamic> json) => FormatModel(
        value: json["value"],
        align: json["align"],
        bold: json["bold"],
        type: json["type"],
        height: json["height"],
        width: json["width"],
      );

  Map<String, dynamic> toMap() => {
        "value": value,
        "align": align,
        "bold": bold,
        "type": type,
        "height": height,
        "width": width,
      };

  static getBoolToBold(bool bold) {
    switch (bold) {
      case true:
        return true;
      case false:
        return false;
    }
  }

  static PosAlign getStringToAlign(String align) {
    PosAlign newVal = PosAlign.center;

    switch (align) {
      case 'center':
        newVal = PosAlign.center;
        return newVal;
      case 'left':
        newVal = PosAlign.left;
        return newVal;
      case 'right':
        newVal = PosAlign.right;
        return newVal;
    }
    return newVal;
  }

  static PosTextSize getStringToSize(String size) {
    PosTextSize newSize = PosTextSize.size1;

    switch (size) {
      case 'size1':
        newSize = PosTextSize.size1;
        return newSize;
      case 'size2':
        newSize = PosTextSize.size2;
        return newSize;
      case 'size3':
        newSize = PosTextSize.size3;
        return newSize;
      case 'size4':
        newSize = PosTextSize.size4;
        return newSize;
      case 'size5':
        newSize = PosTextSize.size5;
        return newSize;
      case 'size6':
        newSize = PosTextSize.size6;
        return newSize;
      case 'size7':
        newSize = PosTextSize.size7;
        return newSize;
      case 'size8':
        newSize = PosTextSize.size8;
        return newSize;
    }
    return newSize;
  }
}
