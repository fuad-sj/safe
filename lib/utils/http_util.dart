import 'dart:convert';

import 'package:http/http.dart' as http;

class HttpUtil {
  static Future<dynamic> getHttpsRequest(
      String domain, String path, Map<String, dynamic>? params) async {
    Uri uri = Uri.https(domain, path, params);
    http.Response response = await http.get(uri);

    if (response.statusCode == 200) {
      String jsonData = response.body;
      var decodeData = jsonDecode(jsonData);
      return decodeData;
    } else {
      throw "Failed, No Response for $uri request";
    }
  }
}
