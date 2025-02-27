import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class CreateBooking extends StatefulWidget {
  const CreateBooking({super.key});

  @override
  _CreateBookingState createState() => _CreateBookingState();
}

class _CreateBookingState extends State<CreateBooking> {
  // Controller for input fields
  final TextEditingController unitIdController = TextEditingController();
  final TextEditingController planIdController = TextEditingController();
  final TextEditingController partnerIdController = TextEditingController();
  final TextEditingController otherPartIdsController = TextEditingController();
  final TextEditingController agencyIdController = TextEditingController();
  final TextEditingController agencyAgentIdController = TextEditingController();

  String? _authToken;
  String? _email;

  @override
  void initState() {
    super.initState();
    _loadCredentials();
  }

  // Function to load token and email from SharedPreferences
  Future<void> _loadCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _authToken = prefs.getString('authToken'); // Get the stored token
      _email = prefs.getString('email');         // Get the stored email
    });
  }

  // Function to handle API call
  Future<void> createBooking() async {
    const apiUrl = "https://beta.aquadev.me/json-call/create_booking";

    if (_authToken == null || _email == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Authentication token or email not found!")),
      );
      return;
    }

    // Prepare payload
    final Map<String, dynamic> payload = {
      "login": _email,
      "key": _authToken,
      "db": "beta_Real_18_dec",
      "unit_id": int.tryParse(unitIdController.text) ?? 0,
      "plan_id": int.tryParse(planIdController.text) ?? 0,
      "partner_id": int.tryParse(partnerIdController.text) ?? 0,
      "other_part_ids": otherPartIdsController.text
          .split(',')
          .map((id) => int.tryParse(id.trim()))
          .where((id) => id != null)
          .toList(),
      "agency_id": int.tryParse(agencyIdController.text) ?? 0,
      "agency_agent_id": int.tryParse(agencyAgentIdController.text) ?? 0,
    };

    try {
      // Make the API request
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
        },
        body: json.encode(payload),
      );

      // Handle response
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['result'] != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Booking created successfully!")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: ${responseData['error']['message']}")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("HTTP Error: ${response.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Booking")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Input Fields
            TextField(
              controller: unitIdController,
              decoration: const InputDecoration(labelText: "Unit ID"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: planIdController,
              decoration: const InputDecoration(labelText: "Plan ID"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: partnerIdController,
              decoration: const InputDecoration(labelText: "Partner ID"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: otherPartIdsController,
              decoration: const InputDecoration(
                  labelText: "Other Part IDs (comma-separated)"),
            ),
            TextField(
              controller: agencyIdController,
              decoration: const InputDecoration(labelText: "Agency ID"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: agencyAgentIdController,
              decoration: const InputDecoration(labelText: "Agency Agent ID"),
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 20),

            // Submit Button
            ElevatedButton(
              onPressed: createBooking,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                backgroundColor: Colors.blue,
              ),
              child: const Text("Submit"),
            ),
          ],
        ),
      ),
    );
  }
}
