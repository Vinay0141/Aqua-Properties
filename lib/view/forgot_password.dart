import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:aqua_properties/features/common/ap_text_field.dart';
import 'package:aqua_properties/view/otp_screen.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  final String odooUrl = 'https://aquadev.me/json-call/get_otp';
  final String dbName = 'New_Real_Estate';

  void toggleLoading() {
    setState(() {
      _isLoading = !_isLoading;
    });
  }

  bool validateInputs(String email) {
    if (email.isEmpty) {
      Fluttertoast.showToast(msg: 'Please enter email');
      return false;
    }

    String pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(email)) {
      Fluttertoast.showToast(msg: 'Please enter a valid email address.');
      return false;
    }
    return true;
  }

  Future<void> authenticate(String email) async {
    if (!validateInputs(email)) return;

    final url = Uri.parse(odooUrl);

    Map<String, dynamic> body = {
      'login': email,
      'db': dbName,
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

        if (result['result'] != null &&
            result['result']['status'] == 'Success' &&
            result['result']['otp'] != null) {
          String otp = result['result']['otp'];

          Fluttertoast.showToast(msg: 'OTP sent successfully');
          onOtpSendSuccess(email, otp);
        } else {
          Fluttertoast.showToast(msg: 'Failed to send OTP');
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

  void onOtpSendSuccess(String email, String otp) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OtpScreen(email: email, otp: otp),
      ),
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
                      const SizedBox(height: 10,),
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.08, ),
                      const Center(
                        child: Text(
                          'Forgot password',
                          style: TextStyle(
                              fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 10, ),
                      const Center(
                        child: Text(
                          'Enter the email address associated\nwith your account.',
                          style: TextStyle(
                              fontSize: 16, color: Colors.white70, fontWeight: FontWeight.w400),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.07,),
                      const Text('Email', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w400),),
                      APTextField(
                        keyboardType: TextInputType.emailAddress,
                        controller: _emailController,
                        hintText: 'Enter Email',
                        prefixIcon: const Icon(Icons.email),
                      ),
                      const SizedBox(height: 40,),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : () {
                            String email = _emailController.text;
                            authenticate(email);
                          },
                          child: _isLoading
                              ? const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                              : const Text(
                            'Send OTP',
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
