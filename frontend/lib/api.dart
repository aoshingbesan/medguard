import 'dart:convert';
import 'package:http/http.dart' as http;

class MedGuardApi {
  static const baseUrl = 'http://127.0.0.1:8000';

  static Future<Map<String, dynamic>> verify(String code) async {
    final uri = Uri.parse('$baseUrl/api/verify?code=$code');
    final res = await http.get(uri);
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Verify failed (${res.statusCode})');
  }
}
