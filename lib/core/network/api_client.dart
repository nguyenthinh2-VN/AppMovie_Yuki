import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  static const String baseUrl = 'https://phimapi.com';
  final http.Client _client;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  Future<Map<String, dynamic>> get(String path, {Map<String, String>? queryParameters}) async {
    final uri = Uri.parse('$baseUrl$path').replace(queryParameters: queryParameters);
    try {
      final response = await _client.get(uri, headers: {
        'Accept': 'application/json',
        'User-Agent': 'YukiMovieApp/1.0',
      }).timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
        throw Exception('Invalid JSON response format');
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network request failed: $e');
    }
  }
}
