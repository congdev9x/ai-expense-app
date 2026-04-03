import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConfig {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000/api/v1';
    }
    if (Platform.isAndroid) {
      // 10.0.2.2 là địa chỉ đặc biệt để Emulator Android truy cập localhost của máy tính chủ
      // Nếu dùng điện thoại thật, bạn có thể đổi thành IP LAN (192.168.2.163)
      return 'http://10.0.2.2:8000/api/v1'; 
    }
    return 'http://127.0.0.1:8000/api/v1';
  }

  static String get login => '$baseUrl/auth/login/access-token';
  static String get register => '$baseUrl/register';
  static String get transactions => '$baseUrl/transactions';
  static String get categories => '$baseUrl/categories';
  static String get budgets => '$baseUrl/budgets';
  static String get parseAi => '$baseUrl/ai/parse-text';
}
