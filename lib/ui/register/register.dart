import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:flutter/foundation.dart';
import 'package:social_app/ui/login/login.dart';

import '../../config/ApiConfig.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  File? _selectedImage;
  bool _isLoading = false;

  final _formKey = GlobalKey<FormState>(); // Form key for validation
  final ImagePicker _picker = ImagePicker();

  // Pick an image from the gallery
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  // Register the user
  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return; // If the form is invalid, stop the registration process
    }

    if (_selectedImage == null) {
      _showSnackBar("Please select an avatar image.");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final uri = Uri.parse(ApiConfig.register);
      final request = http.MultipartRequest("POST", uri);

      // Add form fields
      request.fields['username'] = _usernameController.text;
      request.fields['fullName'] = _fullNameController.text;
      request.fields['bio'] = _bioController.text;
      request.fields['email'] = _emailController.text;
      request.fields['password'] = _passwordController.text;

      // Add image file
      final mimeTypeData = lookupMimeType(_selectedImage!.path)?.split('/');
      final imageFile = await http.MultipartFile.fromPath(
        'imgFile',
        _selectedImage!.path,
        contentType:
            MediaType(mimeTypeData?[0] ?? 'image', mimeTypeData?[1] ?? 'jpeg'),
      );

      request.files.add(imageFile);

      // Send the request
      final response = await request.send();

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        _showSnackBar("Registration successful!", isSuccess: true);
      } else {
        _showSnackBar("Registration failed. Please try again.");
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showSnackBar("An error occurred. Please try again.");
      print('Error: $e'); // Print error for debugging
    }
  }

  // Show snack bar
  void _showSnackBar(String message, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Register"),
        backgroundColor: Colors.deepPurple, // Stylish AppBar color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey, // Bind form key for validation
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Username Field
                _buildTextField(
                  controller: _usernameController,
                  label: "Username",
                  icon: Icons.person,
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter a username' : null,
                ),
                // Full Name Field
                _buildTextField(
                  controller: _fullNameController,
                  label: "Full Name",
                  icon: Icons.person_outline,
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter your full name' : null,
                ),
                // Bio Field
                _buildTextField(
                  controller: _bioController,
                  label: "Bio",
                  icon: Icons.text_fields,
                  validator: (value) => null,
                ),
                // Email Field with email validation
                _buildTextField(
                  controller: _emailController,
                  label: "Email",
                  icon: Icons.email,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an email';
                    }
                    String pattern =
                        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
                    RegExp regex = RegExp(pattern);
                    if (!regex.hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                // Password Field with password validation
                _buildTextField(
                  controller: _passwordController,
                  label: "Password",
                  icon: Icons.lock,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                // Avatar image preview inside a circle
                _selectedImage != null
                    ? ClipOval(
                        child: kIsWeb
                            ? Image.network(
                                _selectedImage!.path,
                                height: 100,
                                width: 100,
                                fit: BoxFit.cover,
                              )
                            : Image.file(
                                _selectedImage!,
                                height: 100,
                                width: 100,
                                fit: BoxFit.cover,
                              ),
                      )
                    : const Text("No avatar image selected",
                        style: TextStyle(color: Colors.grey)),
                // Pick Image button
                TextButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.image),
                  label: const Text("Pick Image"),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.deepPurple,
                    // Text color (formerly 'primary')
                    side: BorderSide(color: Colors.deepPurple),
                  ),
                ),
                const SizedBox(height: 20),

// Loading indicator or Register button
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          // Button background color (formerly 'primary')
                          padding: const EdgeInsets.symmetric(
                              vertical: 15, horizontal: 100),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          "Register",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white, // Chữ sáng hơn với màu trắng
                            fontWeight: FontWeight.bold, // Tăng độ đậm cho chữ
                          ),
                        ),
                      ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("You already have an account?"),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                      child: const Text("Sign in!",
                          style: TextStyle(color: Colors.deepPurple)),
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

  // Helper method to build text fields
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        validator: validator,
      ),
    );
  }
}
