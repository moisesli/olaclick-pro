import 'dart:convert';
import 'package:http/http.dart' as http;

class NetworkUtil {
  static const String msgGenerico = "Error al recuperar datos.";
  static const String msgGenericoRed = "Comprueba tu conexión a Internet y vuelve a intentarlo.";
  static NetworkUtil _instance = new NetworkUtil.internal();
  NetworkUtil.internal();
  factory NetworkUtil() => _instance;

  Future<http.Response> get(url, {headers}) {
    try {
      return http.get(url, headers: headers).then((http.Response response) {
        final int statusCode = response.statusCode;
        print(statusCode);
        if (statusCode < 200 || statusCode > 400 || json == null) {
          print(statusCode);
          throw (msgGenerico);
        }
        return response;
      }).catchError((e) {
        print(e.toString());
        throw (e.toString());
      });
    } catch (e) {
      throw (e.toString());
    }
  }

  //204 is ok
  Future<http.Response> post(url, {headers, body, encoding}) {
    try {
      return http.post(url, headers: headers, body: body).then((http.Response response) {
        final int statusCode = response.statusCode;
        print(response);
        if (statusCode < 200 || statusCode > 400 || json == null) {
          throw (msgGenerico);
        }

        return response;
      }).catchError((e) {
        print(e.toString());

        throw (e.toString());
      });
    } catch (e) {
      throw (e.toString());
    }
  }
}
