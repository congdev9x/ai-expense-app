import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/api/api_config.dart';

class AiRepository {
  Future<Map<String, dynamic>?> parseExpense(String text) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    if (token == null) {
      print('AiRepository error: Token is null, please login again.');
      return null;
    }

    try {
      final response = await http.post(
        Uri.parse(ApiConfig.parseAi),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'text': text,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['parsed_data'];
        }
      }
      return null;
    } catch (e) {
      print('AiRepository error: \$e');
      return null;
    }
  }
}
