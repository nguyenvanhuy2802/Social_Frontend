import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:social_app/ui/login/login.dart';  // Đảm bảo đã import màn hình login

class SettingTab extends StatefulWidget {
  const SettingTab({super.key});

  @override
  _SettingTabState createState() => _SettingTabState();
}

class _SettingTabState extends State<SettingTab> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _isNotificationsEnabled = true;
  bool _isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Username field
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: "Username",
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Email field
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: "Email",
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              // Avatar field (for demonstration, let's add a placeholder text)
              Row(
                children: [
                  const Icon(Icons.image, size: 30),
                  const SizedBox(width: 10),
                  TextButton(
                    onPressed: () {
                      // Implement image picker here
                    },
                    child: const Text("Change Profile Picture"),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Notification toggle
              SwitchListTile(
                title: const Text("Enable Notifications"),
                value: _isNotificationsEnabled,
                onChanged: (bool value) {
                  setState(() {
                    _isNotificationsEnabled = value;
                  });
                },
              ),

              // Dark mode toggle
              SwitchListTile(
                title: const Text("Enable Dark Mode"),
                value: _isDarkMode,
                onChanged: (bool value) {
                  setState(() {
                    _isDarkMode = value;
                  });
                },
              ),
              const SizedBox(height: 20),

              // Save button
              ElevatedButton(
                onPressed: () {
                  // Handle the save button action here
                  _showSnackBar("Settings Saved!");
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple, // Button background color
                  padding:
                  const EdgeInsets.symmetric(vertical: 15, horizontal: 100),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  "Save Settings",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white, // Text color for the button
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Logout button
              ElevatedButton(
                onPressed: () async {
                  // Lấy instance của SharedPreferences
                  final prefs = await SharedPreferences.getInstance();

                  // Xóa username đã lưu trong SharedPreferences
                  await prefs.remove('username');

                  // Hiển thị thông báo đã đăng xuất
                  _showSnackBar("Logged Out!");

                  // Chuyển đến màn hình đăng nhập
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, // Logout button background color
                  padding:
                  const EdgeInsets.symmetric(vertical: 15, horizontal: 100),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  "Logout",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white, // Text color for the button
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Show a Snackbar for feedback
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }
}
