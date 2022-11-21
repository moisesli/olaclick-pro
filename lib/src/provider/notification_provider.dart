import 'dart:convert';

import 'package:olaclick/resources/network_util.dart';
import 'package:olaclick/src/model/pushNotification.dart';

class NotificationProvider {
  late final String url;

  NetworkUtil _networkUtil = NetworkUtil();
  //verificar de shared preferences la url de prod O DEV

  Future<PushResponseModel> registerTokenPush(
      String url, String companyId, String pushToken) async {
    var urlPost = url + "/notifications/pushs/register-token";
    var headers = {
      "Accept": "application/json",
    };
    var body = {'company_id': companyId, 'push_token': pushToken};

    final response = await _networkUtil
        .post(urlPost, headers: headers, body: body)
        .then((res) {
      print(PushResponseModel.fromJson(json.decode(res.body)));
      return PushResponseModel.fromJson(json.decode(res.body));
    }).catchError((e) {
      throw (e.toString());
    });
    return response;
  }

  Future<PushResponseModel> unRegisterTokenPush(
      String url, String companyId, String pushToken) async {
    var urlPost = url + "/notifications/pushs/unregister-token";
    var headers = {
      "Accept": "application/json",
    };
    var body = {'company_id': companyId, 'push_token': pushToken};

    final response = await _networkUtil
        .post(urlPost, headers: headers, body: body)
        .then((res) {
      print(PushResponseModel.fromJson(json.decode(res.body)));
      // return PushResponseModel.fromJson(json.decode(res.body));
    }).catchError((e) {
      throw (e.toString());
    });
    return response;
  }
}
