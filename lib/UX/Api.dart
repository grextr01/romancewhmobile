// ignore_for_file: depend_on_referenced_packages, prefer_typing_uninitialized_variables
// ignore_for_file: file_names
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:romancewhs/UX/global.dart';
import 'dart:convert';

import '../Models/Boxes/boxes.dart';

class API {
  String apiBaseUrl = baseUrl;

  late http.Client _client;

  API() {
    _client = _createHttpClient();
  }

  /// Creates an HttpClient that ignores SSL certificate errors (for dev only)
  http.Client _createHttpClient() {
    final ioClient = HttpClient()
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
    return IOClient(ioClient);
  }

  Future<Map> getApiToMap(String url, String endpoint, String type,
      [Map? body, String? token]) async {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    if (userBox.get('activeUser') != null) {
      headers['authorization'] = 'Bearer ${userBox.get('activeUser')!.token}';
    }

    // final errorMap = {'statusCode': '500', 'message': 'Something went wrong'};
    final uri = Uri.parse('$url$endpoint');
    final jsonString = json.encode(body ?? {});
    http.Response? response;

    try {
      switch (type.toLowerCase()) {
        case 'post':
          response =
              await _client.post(uri, body: jsonString, headers: headers);
          break;
        case 'get':
          response = await _client.get(uri, headers: headers);
          break;
        case 'put':
          response = await _client.put(uri, body: jsonString, headers: headers);
          break;
        case 'delete':
          response = await _client.delete(uri, headers: headers);
          break;
        default:
          throw UnsupportedError('Unsupported request type: $type');
      }

      final Map<String, dynamic> jsonResp = jsonDecode(response.body);
      jsonResp['statusCode'] = response.statusCode;
      return jsonResp;
    } catch (e) {
      return {'statusCode': 500, 'message': e.toString()};
    }
  }
}
