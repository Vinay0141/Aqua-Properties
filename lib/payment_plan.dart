import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PaymentPlanScreen extends StatefulWidget {
  const PaymentPlanScreen({super.key});

  @override
  _PaymentPlanScreenState createState() => _PaymentPlanScreenState();
}

class _PaymentPlanScreenState extends State<PaymentPlanScreen> {
  bool isLoading = true;  // Loading state
  Map<String, dynamic>? responseData;  // Data from server
  String errorMessage = "";  // Error message

  // Function to fetch data from API
  Future<void> fetchData() async {
    // Retrieve the token from SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? authToken = prefs.getString('authToken'); // Get the stored token
    String? email = prefs.getString('email');

    if (authToken == null) {
      setState(() {
        errorMessage = "Token not found, please login";
        isLoading = false;
      });
      return; // Exit if token is not found
    }

    final String apiUrl = "https://beta.aquadev.me/json-call/get_unit_paymentplan"; // Updated API URL
    final Map<String, String> headers = {
      "Content-Type": "application/json", // Request type
    };

    final Map<String, dynamic> body = {
      "login": email, // Login credentials
      "key":  authToken, // Authentication key
      "db": "beta_Real_18_dec", // Database name
      "id": 1077, // Unit ID

    };

    try {
      // POST request send kar rahe hain
      final response = await http.post(Uri.parse(apiUrl),
        headers: headers, body: jsonEncode(body),
      );

      print(response.body);

      if (response.statusCode == 200) {
        // Agar response successful ho
        setState(() {
          responseData = jsonDecode(response.body); // Response data ko store kar rahe hain
          isLoading = false;  // Loading complete
        });
      } else {
        // Agar error ho
        setState(() {
          errorMessage =
          "Error: ${response.statusCode} - ${response.reasonPhrase}";
          isLoading = false;
        });
      }
    } catch (error) {
      // Agar connection ka issue ho
      setState(() {
        errorMessage = "Error: $error";
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();  // Data fetch karte hain jab screen load ho
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment Plan"),
      ),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()  // Loading indicator
            : responseData != null
            ? ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            const Text(
              "Payment Plan Details",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 16),
            // Sample structure based on response data, customize it
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Status: ${responseData!['result']['status'] ?? 'N/A'}",
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "UID: ${responseData!['result']['uid'] ?? 'N/A'}",
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Payment Plan: ${responseData!['result']['plans'][0]['name'] ?? 'N/A'}",
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        )
            : Text(
          errorMessage.isNotEmpty
              ? errorMessage
              : "No data received",  // Agar error ya data na aaye toh
          style: const TextStyle(color: Colors.red),
        ),
      ),
    );
  }
}
