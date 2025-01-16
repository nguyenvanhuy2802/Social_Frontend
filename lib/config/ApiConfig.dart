class ApiConfig {
  static const String baseUrl = "http://192.168.1.24:8081/api";

  // Endpoints
  static const String register = "$baseUrl/auth/register";
  static const String login = "$baseUrl/auth/login";
  static const String userProfile = "$baseUrl/user/profile";
  static const String messages = "$baseUrl/messages";  // Đảm bảo endpoint này tồn tại
  static const String sendMessage = "$baseUrl/messages/send";  // Đảm bảo endpoint này tồn tại
}
