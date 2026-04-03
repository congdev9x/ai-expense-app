import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/api/api_config.dart';

class CategoryRepository {
  Future<List<dynamic>> getCategories() async {
    final response = await http.get(
      Uri.parse(ApiConfig.categories),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return [];
  }

  Future<dynamic> createCategory(String name, String type) async {
    final response = await http.post(
      Uri.parse(ApiConfig.categories),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'type': type
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }
}
