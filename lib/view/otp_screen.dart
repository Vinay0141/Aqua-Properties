import 'dart:convert';
import 'package:aqua_properties/view/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import '../features/common/ap_text_field.dart';

class OtpScreen extends StatefulWidget {
  final String email;
  final String otp;
  OtpScreen({super.key, required this.email, required this.otp});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  TextEditingController passwordController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  final String odooUrl = 'https://beta.aquadev.me/json-call/set_password';
  final String dbName = 'beta_Real_18_dec';

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  void toggleLoading() {
    setState(() {
      _isLoading = !_isLoading;
    });
  }

  Future<void> authenticate(String password, String otp) async {
    if (password.isEmpty || otp.isEmpty) {
      Fluttertoast.showToast(msg: 'Please enter both OTP and password');
      return;
    }

    if (otp != widget.otp) {
      Fluttertoast.showToast(msg: 'The OTP you entered is incorrect');
      return;
    }

    final url = Uri.parse(odooUrl);

    Map<String, dynamic> body = {
      'login': widget.email,
      'otp': otp,
      'db': dbName,
      'password': password
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

        if (result['result'] != null && result['result']['status'] != null) {
          var status = result['result']['status'];
          print('API status: $status');

          if (status == 'success') {
            Fluttertoast.showToast(msg: 'Password reset successfully!');
            onOtpSendSuccess();
          } else {
            Fluttertoast.showToast(msg: 'Failed to reset password: $status');
          }
        } else {
          Fluttertoast.showToast(msg: 'Unexpected response structure');
        }
      } else {
        Fluttertoast.showToast(msg: 'Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error: $e');
    } finally {
      toggleLoading();
    }
  }

  void onOtpSendSuccess() async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
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
                  color: Colors.blue.withOpacity(0.7),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                      const Text(
                        'Set a new password',
                        style: TextStyle(
                            fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Create a new password. Ensure it differs from previous ones for security',
                        style: TextStyle(fontSize: 16, color: Colors.white70, fontWeight: FontWeight.w400),
                      ),
                      const SizedBox(height: 40),
                      const Text(
                        'OTP',
                        style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      APTextField(
                        keyboardType: TextInputType.number,
                        controller: _otpController,
                        hintText: 'Enter OTP',
                        prefixIcon: const Icon(Icons.password),
                      ),
                      SizedBox(height: 20),
                      const Text(
                        'Password',
                        style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      APTextField(
                        controller: passwordController,
                        obscureText: !_isPasswordVisible,
                        hintText: 'Enter Password',
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                          onPressed: _togglePasswordVisibility,
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
                            String password = passwordController.text;
                            String otp = _otpController.text;
                            authenticate(password, otp);
                          },
                          child: _isLoading
                              ? const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                              : const Text(
                            'Reset Password',
                            style: TextStyle(
                                fontSize: 16, color: Color(0xff1BBAED), fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}