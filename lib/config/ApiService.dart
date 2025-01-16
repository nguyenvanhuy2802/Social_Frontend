import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:social_app/ui/discovery/discovery.dart';

class ApiService {
  // Địa chỉ URL cơ bản của API
  static const String baseUrl = 'http://192.168.1.24:8081/api';

  // Phương thức gửi tin nhắn
  Future<void> sendMessage(String friend, String message) async {
    final url = Uri.parse('$baseUrl/messages/send'); // Endpoint gửi tin nhắn

    // Dữ liệu gửi đi (có thể thay đổi tùy vào API của bạn)
    final data = {
      'friend': friend,
      'message': message,
    };

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json', // Đảm bảo gửi dữ liệu dạng JSON
        },
        body: json.encode(data),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to send message');
      }
    } catch (e) {
      throw Exception('Error sending message: $e');
    }
  }

  // Phương thức lấy tin nhắn (giả sử)
  Future<List<Map<String, dynamic>>> getMessages(String friend) async {
    final url = Uri.parse('$baseUrl/messages/$friend'); // Endpoint lấy tin nhắn

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // Giả sử API trả về danh sách tin nhắn dưới dạng JSON
        List<Map<String, dynamic>> messages = List<Map<String, dynamic>>.from(
            json.decode(response.body));
        return messages;
      } else {
        throw Exception('Failed to load messages');
      }
    } catch (e) {
      throw Exception('Error fetching messages: $e');
    }
  }

  Future<List<User>> getUsers() async {
    final url = Uri.parse(
        '$baseUrl/auth/total'); // Endpoint lấy danh sách người dùng

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // Nếu thành công, phân tích cú pháp JSON và trả về danh sách người dùng
        List<dynamic> data = json.decode(response.body);
        return data.map((userJson) => User.fromJson(userJson)).toList();
      } else {
        // Trả về một danh sách rỗng nếu có lỗi
        return [];
      }
    } catch (e) {
      // Trong trường hợp có lỗi, trả về danh sách rỗng
      return [];
    }
  }
}