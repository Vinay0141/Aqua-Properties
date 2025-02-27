import 'package:aqua_properties/features/common/ap_text_field.dart';
import 'package:aqua_properties/features/nav_bar/nav_screen.dart';
import 'package:aqua_properties/view/forgot_password.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isPasswordVisible = false;

  // Update with your backend URL and database name
  final String odooUrl = 'https://beta.aquadev.me/json-call/user_authenticate';
  final String db = 'beta_Real_18_dec';

  void toggleLoading() {
    setState(() {
      _isLoading = !_isLoading;
    });
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  bool validateInputs(String email, String password) {
    if (email.isEmpty || password.isEmpty) {
      showSnackbar('Please enter both email and password.', isError: true);
      return false;
    }

    String pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(email)) {
      showSnackbar('Please enter a valid email address.', isError: true);
      return false;
    }
    return true;
  }

  void showSnackbar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,  // Red for errors, Green for success
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> authenticate(String login, String password) async {
    if (!validateInputs(login, password)) return;

    final url = Uri.parse(odooUrl);

    Map<String, dynamic> body = {
      'login': login,
      'password': password,
      'db': db,
    };

    try {
      toggleLoading();
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);

        // Check if 'result' field exists and is not null
        if (result != null && result['result'] != null) {
          if (result['result']['token'] != null && result['result']['uid'] != null) {
            String token = result['result']['token'];
            showSnackbar('Login Successful');
            emailController.clear();
            passwordController.clear();
            onLoginSuccess(token, login);
          } else {
            showSnackbar('Unexpected response format (Missing token/uid).', isError: true);  // Error Snackbar
          }
        } else {
          showSnackbar('Error: Missing "result" in API response.', isError: true);  // Error Snackbar
        }
      } else if (response.statusCode == 401) {
        // Wrong Password or Email
        showSnackbar('Wrong Password or Email!', isError: true);  // Error Snackbar
        emailController.clear();
        passwordController.clear();
      } else {
        showSnackbar('Error: ${response.statusCode} - ${response.reasonPhrase}', isError: true);  // Error Snackbar
      }
    } catch (e) {
      showSnackbar('Error: $e', isError: true);  // Error Snackbar
    } finally {
      toggleLoading();
    }
  }

  void onLoginSuccess(String token, String email) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('authToken', token);
    await prefs.setString('email', email);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const DashboardScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.withOpacity(0.7),
      body: SafeArea(
        child: SizedBox(
          height: double.infinity,
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/images/building_image.jpg',
                  fit: BoxFit.cover,
                ),
              ),
              Positioned.fill(
                child: Container(
                  color: Colors.blue.withOpacity(0.5),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 50),
                      Center(
                        child: Container(
                          height: 140,
                          width: 140,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(100)),
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Image.asset(
                              'assets/images/aqua_logo_two.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Center(
                          child: Text(
                            'Login',
                            style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          )),
                      const Center(
                          child: Text(
                            'Login to continue using the app',
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.w400),
                          )),
                      const SizedBox(height: 40),
                      const Text('Email',
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      APTextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        hintText: 'Enter Email',
                        prefixIcon: const Icon(Icons.email),
                      ),
                      const SizedBox(height: 20),
                      const Text('Password',
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      APTextField(
                        controller: passwordController,
                        obscureText: !_isPasswordVisible,
                        hintText: 'Enter Password',
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(_isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off),
                          onPressed: _togglePasswordVisibility,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const ForgotPassword()));
                          },
                          child: const Text(
                            'Forget Password?',
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : () {
                            String login = emailController.text;
                            String password = passwordController.text;
                            authenticate(login, password);
                          },
                          child: _isLoading
                              ? const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                              : const Text(
                            'Login',
                            style: TextStyle(
                                fontSize: 16,
                                color: Color(0xff1BBAED),
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
