import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_svg/flutter_svg.dart'; // Add the package flutter_svg
import 'package:social_app/config/ApiConfig.dart';
import 'package:social_app/ui/register/register.dart';
import 'package:social_app/ui/home/home.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  void _showSnackBar(String message, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
      ),
    );
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final url = Uri.parse(
          '${ApiConfig.login}?username=${_usernameController.text}&password=${_passwordController.text}');
      final response = await http.post(url,
          headers: {"Content-Type": "application/x-www-form-urlencoded"});

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _showSnackBar("Login successful!", isSuccess: true);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SocialHomePage()),
        );
      } else {
        _showSnackBar("Invalid username or password.");
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showSnackBar("An error occurred. Please try again.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0078FF), // Zalo blue color for app bar
        elevation: 0,
        toolbarHeight: 80,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ), // Rounded corners for the AppBar
        flexibleSpace: Padding(
          padding: const EdgeInsets.all(20.0), // Adding padding to the AppBar
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.white, // White background for the entire screen
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20), // Adjust padding
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start, // Aligning to the top
              children: [
                // Logo image with animation at the top
                AnimatedOpacity(
                  opacity: 1.0,
                  duration: const Duration(seconds: 1),
                  child: SvgPicture.asset(
                    'assets/icons/social_logo.svg', // Path to your SVG image
                    width: 100,  // Smaller logo size
                    height: 100,
                  ),
                ),
                const SizedBox(height: 15), // Reduced space between logo and form fields

                // "Welcome Back" Text
                const Text(
                  "Welcome Back",
                  style: TextStyle(
                    fontSize: 28,  // Slightly smaller font size
                    fontWeight: FontWeight.bold,
                    color: Colors.black, // Black color for text
                    shadows: [
                      Shadow(
                        offset: Offset(2.0, 2.0),
                        blurRadius: 3.0,
                        color: Colors.black38, // Shadow color for the text
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25), // Adjusted space between title and input fields

                // Username Field with light purple background
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: "Username",
                    prefixIcon: const Icon(Icons.person, color: Color(0xFF9C27B0)), // Light purple color for icon
                    filled: true,
                    fillColor: Color(0xFFE1BEE7), // Light purple background for the text field
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    labelStyle: const TextStyle(color: Color(0xFF9C27B0)), // Light purple for label
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your username';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12), // Reduced space between username and password fields

                // Password Field with light purple background
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Password",
                    prefixIcon: const Icon(Icons.lock, color: Color(0xFF9C27B0)), // Light purple color for icon
                    filled: true,
                    fillColor: Color(0xFFE1BEE7), // Light purple background for the text field
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    labelStyle: const TextStyle(color: Color(0xFF9C27B0)), // Light purple for label
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18), // Adjusted space between password field and login button

                // Login Button with dark purple background
                _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6A1B9A), // Dark purple color for button
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 80),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 5,
                    shadowColor: Colors.purpleAccent, // Shadow effect on button
                  ),
                  onPressed: _login,
                  child: const Text(
                    "Login",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // Signup Option
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account? ",
                      style: TextStyle(color: Colors.black), // Black text for "Don't have an account?"
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        "Sign up!",
                        style: TextStyle(
                            color: Color(0xFF9C27B0), fontWeight: FontWeight.bold), // Light purple color for "Sign up"
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
