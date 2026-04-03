class ApiConfig {
  // Thay đổi IP này thành IP của máy chạy Backend Docker
  // Chạy trên Emulator Android thì dùng 10.0.2.2 
  // Chạy trên iOS Simulator thì dùng 127.0.0.1 hoặc localhost
  // Chạy trên Flutter Web Server thì dùng 127.0.0.1
  static const String baseUrl = 'http://192.168.2.163:8000/api/v1';

  static const String login = '$baseUrl/auth/login/access-token';
  static const String register = '$baseUrl/auth/register';
  static const String transactions = '$baseUrl/transactions';
  static const String categories = '$baseUrl/categories';
  static const String budgets = '$baseUrl/budgets';
  static const String parseAi = '$baseUrl/ai/parse-text';
}
