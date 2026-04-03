import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/api/api_config.dart';

class BudgetRepository {
  Future<List<dynamic>> getBudgets() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token == null) throw Exception('No authentication token found');

    final response = await http.get(
      Uri.parse(ApiConfig.budgets),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    // Backend may return 404 if no budgets found, but we treat it as empty list for simplicity or handle 200 []
    return [];
  }

  Future<dynamic> createBudget(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token == null) throw Exception('No authentication token found');

    final response = await http.post(
      Uri.parse(ApiConfig.budgets),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to create budget');
  }
}
