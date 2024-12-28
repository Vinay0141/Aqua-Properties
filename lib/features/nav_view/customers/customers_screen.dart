import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CustomerScreen extends StatefulWidget {
  @override
  State<CustomerScreen> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
  List<Map<String, String>> customers = [];
  bool isLoading = true;

  // Fetch customers data from the API
  Future<void> fetchCustomers() async {
    const String apiUrl = "https://beta.aquadev.me/json-call/get_customers";
    const requestPayload = {
      "login": "app_user@akili.com",
      "key": "edec66b8c075611a78bd9ed7f00dbb0df065cdeac12b2beaaebbfe316f983e4d",
      "db": "beta_Real_18_dec"
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestPayload),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Debugging: Print the whole response to check the format
        print('API Response: $data');

        setState(() {
          if (data['result'] != null && data['result']['customers'] != null) {
            // Assuming 'customers' data is inside 'result' -> 'customers'
            customers = List<Map<String, String>>.from(data['result']['customers'] ?? []);
            isLoading = false;
          } else {
            // If customers are not found, show an empty list
            isLoading = false;
            customers = [];
          }
        });
      } else {
        setState(() {
          isLoading = false;
        });
        // Handle the error if status code is not 200
        print('Failed to load data. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      // Error handling
      print("Error: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchCustomers(); // Fetch the data when the screen is initialized
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Customer Screen"),
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : customers.isEmpty
          ? Center(child: Text("No customers found"))
          : ListView.builder(
        itemCount: customers.length,
        itemBuilder: (context, index) {
          final customer = customers[index];
          return Card(
            elevation: 3,
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: ListTile(
              leading: Icon(Icons.person, color: Colors.blue),
              title: Text(customer['name']!),
              subtitle: Text("Role: ${customer['role']}"),
              trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey),
            ),
          );
        },
      ),
    );
  }
}
