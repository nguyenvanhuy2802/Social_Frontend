import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/ApiService.dart';
import 'dart:convert';

import 'chat.dart';

class DiscoveryTab extends StatefulWidget {
  const DiscoveryTab({super.key});

  @override
  _DiscoveryTabState createState() => _DiscoveryTabState();
}

class _DiscoveryTabState extends State<DiscoveryTab> {
  late Future<List<User>> _filteredUsers;

  @override
  void initState() {
    super.initState();
    _filteredUsers = _getFilteredUsers(); // Lấy danh sách người dùng đã được lọc
  }

  // Hàm lấy danh sách người dùng và loại bỏ người dùng hiện tại
  Future<List<User>> _getFilteredUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final currentUsername = prefs.getString('username') ?? ''; // Lấy username người dùng hiện tại

    // Gọi API để lấy danh sách người dùng
    final users = await ApiService().getUsers();

    // Loại bỏ người dùng hiện tại dựa trên username
    return users.where((user) => user.username != currentUsername).toList();
  }

  // Lấy tin nhắn cuối cùng của người dùng
  Future<String> _getLastMessage(String friendUsername) async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? savedMessages = prefs.getStringList(friendUsername);
    if (savedMessages == null || savedMessages.isEmpty) {
      return ''; // Nếu không có tin nhắn, trả về chuỗi rỗng
    } else {
      final lastMessage = jsonDecode(savedMessages.last); // Lấy tin nhắn cuối cùng
      return lastMessage['message'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        backgroundColor: Colors.blueAccent, // Màu nền của AppBar
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30.0), // Bo tròn góc trái dưới
            bottomRight: Radius.circular(30.0), // Bo tròn góc phải dưới
          ),
        ),
      ),
      body: FutureBuilder<List<User>>(
        future: _filteredUsers,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No users found.'));
          } else {
            final users = snapshot.data!;
            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return FutureBuilder<String>(
                  future: _getLastMessage(user.username), // Lấy tin nhắn cuối cùng
                  builder: (context, messageSnapshot) {
                    if (messageSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (messageSnapshot.hasError) {
                      return Center(child: Text('Error: ${messageSnapshot.error}'));
                    } else {
                      final lastMessage = messageSnapshot.data ?? '';
                      return Column(
                        children: [
                          ListTile(
                            title: Text(user.fullName), // Hiển thị tên người dùng
                            subtitle: Text(lastMessage),  // Hiển thị tin nhắn cuối cùng
                            onTap: () {
                              // Điều hướng đến màn hình chat với người bạn đó
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatScreen(friend: user.fullName),
                                ),
                              );
                            },
                          ),
                          Divider(color: Colors.grey), // Dấu gạch ngang phân cách các cuộc trò chuyện
                        ],
                      );
                    }
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}

class User {
  final String username;
  final String fullName;
  final String bio;

  User({required this.username, required this.fullName, required this.bio});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'],
      fullName: json['fullName'],
      bio: json['bio'],
    );
  }
}

// class ChatScreen extends StatefulWidget {
//   final String friend;
//
//   const ChatScreen({super.key, required this.friend});
//
//   @override
//   _ChatScreenState createState() => _ChatScreenState();
// }
//
// class _ChatScreenState extends State<ChatScreen> {
//   final TextEditingController _controller = TextEditingController();
//   late Future<List<Map<String, dynamic>>> _messages;
//   late String currentUsername;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadCurrentUsername();
//     _messages = fetchMessages();
//   }
//
//   Future<void> _loadCurrentUsername() async {
//     final prefs = await SharedPreferences.getInstance();
//     currentUsername = prefs.getString('username') ?? '';
//     setState(() {});
//   }
//
//   Future<List<Map<String, dynamic>>> fetchMessages() async {
//     final prefs = await SharedPreferences.getInstance();
//     List<String>? savedMessages = prefs.getStringList(widget.friend);
//     if (savedMessages == null) {
//       return [];
//     } else {
//       return savedMessages.map((msg) => Map<String, dynamic>.from(jsonDecode(msg))).toList();
//     }
//   }
//
//   void _sendMessage() async {
//     if (_controller.text.isNotEmpty) {
//       try {
//         final newMessage = {
//           'sender': currentUsername,
//           'message': _controller.text,
//         };
//
//         final prefs = await SharedPreferences.getInstance();
//         List<String> currentMessages = prefs.getStringList(widget.friend) ?? [];
//         currentMessages.add(jsonEncode(newMessage));
//         await prefs.setStringList(widget.friend, currentMessages);
//
//         setState(() {
//           _messages = fetchMessages();
//         });
//
//         _controller.clear();
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
//       }
//     }
//   }
//
//   // Hàm xóa tất cả tin nhắn
//   void _clearMessages() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove(widget.friend); // Xóa tin nhắn của người bạn này
//
//     setState(() {
//       _messages = fetchMessages(); // Cập nhật lại danh sách tin nhắn
//     });
//
//     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All messages cleared')));
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Chat with ${widget.friend}'),
//         backgroundColor: Colors.blueAccent,  // Màu nền của AppBar
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.only(
//             bottomLeft: Radius.circular(30.0), // Bo tròn góc trái dưới
//             bottomRight: Radius.circular(30.0), // Bo tròn góc phải dưới
//           ),
//         ),
//         actions: [
//           // Thêm nút xóa tin nhắn
//           IconButton(
//             icon: const Icon(Icons.delete_forever),
//             onPressed: _clearMessages, // Xóa tin nhắn khi nhấn
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: FutureBuilder<List<Map<String, dynamic>>>(
//               future: _messages,
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator());
//                 } else if (snapshot.hasError) {
//                   return Center(child: Text('Error: ${snapshot.error}'));
//                 } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                   return const Center(child: Text('No messages yet.'));
//                 } else {
//                   final messages = snapshot.data!;
//                   return ListView.builder(
//                     itemCount: messages.length,
//                     itemBuilder: (context, index) {
//                       final message = messages[index];
//                       final isCurrentUser = message['sender'] == currentUsername;
//                       return ListTile(
//                         title: Align(
//                           alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
//                           child: Container(
//                             padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
//                             decoration: BoxDecoration(
//                               color: isCurrentUser ? Colors.blue : Colors.grey[300],
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                             child: Text(
//                               message['message']!,
//                               style: TextStyle(
//                                 color: isCurrentUser ? Colors.white : Colors.black,
//                               ),
//                             ),
//                           ),
//                         ),
//                       );
//                     },
//                   );
//                 }
//               },
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _controller,
//                     decoration: const InputDecoration(
//                       hintText: 'Enter your message...',
//                       border: OutlineInputBorder(),
//                     ),
//                   ),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.send),
//                   onPressed: _sendMessage,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
