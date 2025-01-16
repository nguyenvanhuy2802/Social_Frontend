import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/ApiService.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Discovery Tab')),
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
                return ListTile(
                  title: Text(user.fullName), // Hiển thị fullName
                  subtitle: Text(user.bio),
                  onTap: () {
                    // Điều hướng đến màn hình chat với người bạn đó
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(friend: user.fullName),
                      ),
                    );
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
  final String username; // Thêm trường username
  final String fullName;
  final String bio;

  User({required this.username, required this.fullName, required this.bio});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'], // Parse username
      fullName: json['fullName'],
      bio: json['bio'],
    );
  }
}

class ChatScreen extends StatefulWidget {
  final String friend;

  const ChatScreen({super.key, required this.friend});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  late Future<List<Map<String, dynamic>>> _messages;
  late String currentUsername; // Lưu trữ tên người dùng hiện tại

  @override
  void initState() {
    super.initState();
    _loadCurrentUsername();
    _messages = fetchMessages();
  }

  // Lấy username người dùng hiện tại từ SharedPreferences
  Future<void> _loadCurrentUsername() async {
    final prefs = await SharedPreferences.getInstance();
    currentUsername = prefs.getString('username') ?? '';
    setState(() {});
  }

  // Lấy tin nhắn từ SharedPreferences
  Future<List<Map<String, dynamic>>> fetchMessages() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? savedMessages = prefs.getStringList(widget.friend);
    if (savedMessages == null) {
      return [];
    } else {
      return savedMessages.map((msg) => Map<String, dynamic>.from(jsonDecode(msg))).toList();
    }
  }

  // Gửi tin nhắn
  void _sendMessage() async {
    if (_controller.text.isNotEmpty) {
      try {
        final newMessage = {
          'sender': currentUsername,
          'message': _controller.text,
        };

        final prefs = await SharedPreferences.getInstance();
        List<String> currentMessages = prefs.getStringList(widget.friend) ?? [];
        currentMessages.add(jsonEncode(newMessage));
        await prefs.setStringList(widget.friend, currentMessages);

        setState(() {
          _messages = fetchMessages();
        });

        _controller.clear();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with ${widget.friend}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _messages,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No messages yet.'));
                } else {
                  final messages = snapshot.data!;
                  return ListView.builder(
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isCurrentUser = message['sender'] == currentUsername;
                      return ListTile(
                        title: Align(
                          alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                            decoration: BoxDecoration(
                              color: isCurrentUser ? Colors.blue : Colors.grey[300],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              message['message']!,
                              style: TextStyle(
                                color: isCurrentUser ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Enter your message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
