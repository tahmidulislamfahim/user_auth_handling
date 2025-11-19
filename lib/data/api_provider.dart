import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiProvider {
  static const String baseLink = "https://www.pqstec.com/InvoiceApps/Values/";
  static const String imageBaseLink = "https://www.pqstec.com/InvoiceApps/";

  final Map<String, String> defaultHeaders = {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  Future<dynamic> get(String endpoint, {Map<String, String>? headers}) async {
    final uri = Uri.parse(baseLink + endpoint);
    final merged = {...defaultHeaders, if (headers != null) ...headers};
    final response = await http.get(uri, headers: merged);

    return _processResponse(response);
  }

  Future<dynamic> post(
    String endpoint, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    final uri = Uri.parse(baseLink + endpoint);
    final merged = {...defaultHeaders, if (headers != null) ...headers};
    final response = await http.post(uri, headers: merged, body: body);

    return _processResponse(response);
  }

  dynamic _processResponse(http.Response response) {
    final code = response.statusCode;
    if (code >= 200 && code < 300) {
      if (response.body.isEmpty) return null;
      try {
        return json.decode(response.body);
      } catch (e) {
        return response.body;
      }
    } else {
      throw ApiException(code, response.body);
    }
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;
  ApiException(this.statusCode, this.message);

  @override
  String toString() => 'ApiException($statusCode): $message';
}
