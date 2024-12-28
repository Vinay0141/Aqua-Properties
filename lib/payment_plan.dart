import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class PaymentPlanScreen extends StatefulWidget {
  @override
  _PaymentPlanScreenState createState() => _PaymentPlanScreenState();
}

class _PaymentPlanScreenState extends State<PaymentPlanScreen> {
  bool isLoading = true;  // Loading state
  Map<String, dynamic>? responseData;  // Data from server
  String errorMessage = "";  // Error message

  Future<void> fetchData() async {
    final String apiUrl = "https://aquadev.me/json-call/get_unit_paymentplan"; // Updated API URL
    final Map<String, String> headers = {
      "Content-Type": "application/json", // Request type
    };
    final Map<String, dynamic> body = {
      "login": "app_user@akili.com", // Login credentials
      "key": "edec66b8c075611a78bd9ed7f00dbb0df065cdeac12b2beaaebbfe316f983e4d", // Authentication key
      "db": "New_Real_Estate", // Database name
      "id": 1077  // Unit ID
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
        title: Text("Payment Plan"),
      ),
      body: Center(
        child: isLoading
            ? CircularProgressIndicator()  // Loading indicator
            : responseData != null
            ? ListView(
          padding: EdgeInsets.all(16.0),
          children: [
            Text(
              "Payment Plan Details",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Colors.blue,
              ),
            ),
            SizedBox(height: 16),
            // Sample structure based on response data, customize it
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Status: ${responseData!['result']['status'] ?? 'N/A'}",
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "UID: ${responseData!['result']['uid'] ?? 'N/A'}",
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Payment Plan: ${responseData!['result']['plans'][0]['name'] ?? 'N/A'}",
                    style: TextStyle(fontSize: 16),
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
          style: TextStyle(color: Colors.red),
        ),
      ),
    );
  }
}
