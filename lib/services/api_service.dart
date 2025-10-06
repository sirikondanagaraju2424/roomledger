import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/accommodation.dart';

/// ====== SET THESE AFTER AMPLIFY PUSH ======
/// Example:
/// const kApiBaseUrl = 'https://abc123.execute-api.us-east-1.amazonaws.com/dev';
/// const kApiKey = 'your-api-key-value';
const kApiBaseUrl = String.fromEnvironment('ROOMLEDGER_API_URL', defaultValue: '');
const kApiKey = String.fromEnvironment('ROOMLEDGER_API_KEY', defaultValue: '');

class ApiService {
  static Map<String, String> _headers() => {
        'Content-Type': 'application/json',
        if (kApiKey.isNotEmpty) 'x-api-key': kApiKey,
      };

  static Future<List<Accommodation>> fetchAll() async {
    final res = await http.get(Uri.parse('$kApiBaseUrl/accommodations'), headers: _headers());
    if (res.statusCode != 200) throw Exception('GET failed: ${res.statusCode} ${res.body}');
    final data = jsonDecode(res.body) as List;
    return data.map((e) => Accommodation.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<Accommodation> create(Accommodation a) async {
    final res = await http.post(
      Uri.parse('$kApiBaseUrl/accommodations'),
      headers: _headers(),
      body: jsonEncode(a.toJson()),
    );
    if (res.statusCode != 201) throw Exception('POST failed: ${res.statusCode} ${res.body}');
    return Accommodation.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  static Future<Accommodation> update(Accommodation a) async {
    final res = await http.put(
      Uri.parse('$kApiBaseUrl/accommodations/${a.id}'),
      headers: _headers(),
      body: jsonEncode(a.toJson()),
    );
    if (res.statusCode != 200) throw Exception('PUT failed: ${res.statusCode} ${res.body}');
    return Accommodation.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }
}
