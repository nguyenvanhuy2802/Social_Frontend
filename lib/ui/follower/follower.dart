import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FollowerTab extends StatefulWidget {
  const FollowerTab({super.key});

  @override
  State<FollowerTab> createState() => _FollowerTabState();
}

class _FollowerTabState extends State<FollowerTab> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  List<String> _followers = [];
  List<String> _following = [];
  List<Map<String, String>> _filteredFollowing = [];
  List<Map<String, String>> _filteredFollowers = [];
  List<Map<String, String>> _searchResults = [];
  bool _isSearching = false;
  String _searchError = "";
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchData();
  }

  void _fetchData() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId') ?? '';

    try {
      final userProfile = await fetchUserProfile(userId);
      setState(() {
        _followers = List<String>.from(userProfile['followers']);
        _following = List<String>.from(userProfile['following']);
        _filteredFollowers = _followers.map((e) => {'username': e, 'fullName': ''}).toList();
        _filteredFollowing = _following.map((e) => {'username': e, 'fullName': ''}).toList();
      });
    } catch (e) {
      print('Error fetching user profile: $e');
    }
  }

  Future<Map<String, dynamic>> fetchUserProfile(String userId) async {
    final response = await http.get(Uri.parse('http://192.168.1.208:8081/api/profile/$userId'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch user profile');
    }
  }

  Future<void> _searchUser(String keyword) async {
    if (keyword.isEmpty) {
      setState(() {
        _searchResults = [];
        _searchError = "";
      });
      return;
    }

    try {
      final response = await http.get(Uri.parse('http://192.168.1.208:8081/api/search?keyword=$keyword'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data is List) {
          setState(() {
            _searchResults = data.map((item) {
              return {
                'username': item['username']?.toString() ?? '', // Đảm bảo là chuỗi
                'fullName': item['fullName']?.toString() ?? '', // Đảm bảo là chuỗi
              };
            }).toList();
            _searchError = _searchResults.isEmpty ? "No users found" : "";
          });
        } else {
          setState(() {
            _searchError = "Invalid response from server";
          });
        }
      } else {
        setState(() {
          _searchError = "Error searching users";
        });
      }
    } catch (e) {
      setState(() {
        _searchError = "Connection error with server";
      });
      print('Error searching users: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.teal,
        elevation: 2,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(
            MediaQuery.of(context).size.height * 0.15,
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _isSearching = value.isNotEmpty;
                    });
                    _searchUser(value);
                  },
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search, color: Colors.white),
                    hintText: 'Search users...',
                    hintStyle: const TextStyle(color: Colors.white70),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: const BorderSide(color: Colors.white, width: 2.0),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                  ),
                ),
              ),
              if (!_isSearching)
                Container(
                  color: Colors.white,
                  child: TabBar(
                    controller: _tabController,
                    tabs: [
                      Tab(
                        icon: const Icon(Icons.person, color: Colors.teal),
                        text: 'Following',
                      ),
                      Tab(
                        icon: const Icon(Icons.group, color: Colors.teal),
                        text: 'Followers',
                      ),
                    ],
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                    labelColor: Colors.teal,
                    unselectedLabelColor: Colors.teal,
                    unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
                    indicatorSize: TabBarIndicatorSize.tab,
                  ),
                ),
            ],
          ),
        ),
      ),
      body: _isSearching
          ? _searchResults.isNotEmpty
          ? _buildUserList(
        users: _searchResults,
        actionIcon: Icons.add_circle_outline,
        actionLabel: "Follow",
      )
          : Center(
        child: Text(
          _searchError,
          style: const TextStyle(color: Colors.grey, fontSize: 16),
        ),
      )
          : TabBarView(
        controller: _tabController,
        children: [
          _buildUserList(
            users: _filteredFollowing,
            actionIcon: Icons.remove_circle_outline,
            actionLabel: "Unfollow",
          ),
          _buildUserList(
            users: _filteredFollowers,
            actionIcon: Icons.add_circle_outline,
            actionLabel: "Follow Back",
          ),
        ],
      ),
    );
  }

  Widget _buildUserList({
    required List<Map<String, String>> users,
    required IconData actionIcon,
    required String actionLabel,
  }) {
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.teal,
              child: Text(
                users[index]['username']![0], // First letter of the username
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(users[index]['username']!),
            subtitle: Text(users[index]['fullName']!),
            trailing: TextButton.icon(
              onPressed: () {
                // Handle follow/unfollow action
              },
              icon: Icon(actionIcon, color: Colors.teal),
              label: Text(
                actionLabel,
                style: const TextStyle(color: Colors.teal),
              ),
            ),
          ),
        );
      },
    );
  }
}
