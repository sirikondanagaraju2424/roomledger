// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/accommodation.dart';

class ApiService {
  static const String _base =
    'https://wzvli0aj71.execute-api.us-east-1.amazonaws.com/dev';

  static Map<String, String> get _jsonHeaders =>
      {'Content-Type': 'application/json; charset=UTF-8'};

  /// GET /listings  (optionally pass type='AVAILABLE'|'NEEDED')
  static Future<List<Accommodation>> getListings({String? type}) async {
    final uri = Uri.parse('$_base/listings').replace(queryParameters: type != null ? {'type': type} : null);
    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Failed to load listings: ${res.body}');
    }
    final body = json.decode(res.body);
    final list = (body is Map ? body['items'] : body) as List? ?? [];
    return list.map((e) => Accommodation.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// POST /listings
  static Future<void> createListing({
    required String title,
    required String address,
    required int bhk,
    required String type, // 'AVAILABLE' | 'NEEDED'
    required String price,
    required String userName,
    String? description,
    List<String>? amenities,
  }) async {
    final uri = Uri.parse('$_base/listings');
    final body = json.encode({
      'title': title,
      'address': address,
      'bhk': bhk,
      'type': type.toUpperCase(),
      'price': price,
      'userName': userName,
      'description': description,
      'amenities': amenities ?? [],
    });
    final res = await http.post(uri, headers: _jsonHeaders, body: body);
    if (res.statusCode != 201) {
      throw Exception('Create failed: ${res.body}');
    }
  }

  /// PUT /listings/{id}
  static Future<void> updateListing(String id, Map<String, dynamic> updates) async {
    final uri = Uri.parse('$_base/listings/$id');
    // sanitize: ensure price stays string; type uppercase
    if (updates['price'] != null) updates['price'] = updates['price'].toString();
    if (updates['type'] != null) updates['type'] = '${updates['type']}'.toUpperCase();

    final res = await http.put(uri, headers: _jsonHeaders, body: json.encode(updates));
    if (res.statusCode != 200) {
      throw Exception('Update failed: ${res.body}');
    }
  }

  /// DELETE /listings/{id}
  static Future<void> deleteListing(String id) async {
    final uri = Uri.parse('$_base/listings/$id');
    final res = await http.delete(uri);
    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception('Delete failed: ${res.body}');
    }
  }
}
