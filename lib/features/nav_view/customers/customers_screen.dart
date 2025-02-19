import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class CustomerScreen extends StatefulWidget {
  const CustomerScreen({super.key});

  @override
  State<CustomerScreen> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
  List<CustomerData> customers = [];
  List<CustomerData> filteredCustomers = [];
  bool isLoading = true;
  String errorMessage = "";
  String searchQuery = "";

  final String apiUrl = "https://beta.aquadev.me/json-call/get_customers_only";
  final String db = "beta_Real_18_dec";

  @override
  void initState() {
    super.initState();
    fetchCustomers();
  }

  Future<void> fetchCustomers() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? authToken = prefs.getString('authToken');
      String? email = prefs.getString('email');
      if (authToken == null) {
        throw Exception("Authentication token not found. Please log in again.");
      }

      final Map<String, dynamic> requestPayload = {
        "login": email,
        "key": authToken,
        "db": db,
      };

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestPayload),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['result'] != null && data['result']['customer'] != null) {
          CustomerModel customerResponse = CustomerModel.fromJson(data);

          setState(() {
            customers = customerResponse.result?.customerData ?? [];
            filteredCustomers = customers;
            isLoading = false;
          });
        } else {
          throw Exception("Invalid response structure.");
        }
      } else {
        throw Exception("Failed to load data. Status Code: ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  void filterCustomers(String query) {
    setState(() {
      searchQuery = query;
      filteredCustomers = customers
          .where((customer) =>
      customer.name!.toLowerCase().contains(query.toLowerCase()) ||
          customer.id!.toString().contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text("Customer Screen", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 10,),
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: TextField(
              onChanged: filterCustomers,
              decoration: InputDecoration(
                hintText: "Search by Name or ID",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.blue, width: 1.5),
                    borderRadius: BorderRadius.circular(50.0)
                ),
                focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.blue, width: 2.0),
                    borderRadius: BorderRadius.circular(50.0)
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : errorMessage.isNotEmpty
                ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  errorMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            )
                : filteredCustomers.isEmpty
                ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "No customers found",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey[600]),
                ),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: filteredCustomers.length,
              itemBuilder: (context, index) {
                final customer = filteredCustomers[index];

                return Card(
                  elevation: 5,
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    title: Text(
                      customer.name ?? "Unknown",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("ID: ${customer.id ?? "N/A"}", style: const TextStyle(fontSize: 14, color: Colors.black54)),
                          Text("Mobile: ${customer.mobile ?? "N/A"}", style: const TextStyle(fontSize: 14, color: Colors.black54)),
                          Text("Email: ${customer.email ?? "N/A"}", style: const TextStyle(fontSize: 14, color: Colors.black54)),
                          Text("Country: ${customer.country ?? "N/A"}", style: const TextStyle(fontSize: 14, color: Colors.black54)),
                          Text("Nationality: ${customer.nationality ?? "N/A"}", style: const TextStyle(fontSize: 14, color: Colors.black54)),
                          Text("Lang: ${customer.lang ?? "N/A"}", style: const TextStyle(fontSize: 14, color: Colors.black54)),
                          Text("Units: ${customer.units ?? "N/A"}", style: const TextStyle(fontSize: 14, color: Colors.black54)),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


// Model Class to handle the response structure
class CustomerModel {
  final Result? result;

  CustomerModel({this.result});

  factory CustomerModel.fromJson(Map<dynamic, dynamic> json) {
    return CustomerModel(
      result: json['result'] != null ? Result.fromJson(json['result']) : null,
    );
  }
}

class Result {
  final List<CustomerData>? customerData;

  Result({this.customerData});

  factory Result.fromJson(Map<dynamic, dynamic> json) {
    return Result(
      customerData: (json['customer'] as List<dynamic>?)?.
      map((e) => CustomerData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class CustomerData {
  final dynamic id;
  final dynamic name;
  final dynamic mobile;
  final dynamic email;
  final dynamic lang;
  final List<dynamic>? units;
  final dynamic country;   // Added country field
  final dynamic nationality;   // Added nationality field

  CustomerData({
    this.id,
    this.name,
    this.mobile,
    this.email,
    this.lang,
    this.units,
    this.country,   // Added country field
    this.nationality,   // Added nationality field
  });

  factory CustomerData.fromJson(Map<dynamic, dynamic> json) {
    return CustomerData(
      id: json['id'],
      name: json['name'],
      mobile: json['mobile'],
      email: json['email'],
      lang: json['lang'],
      units: json['units'] ?? [],
      country: json['country'],  // Parse country field
      nationality: json['nationality'],  // Parse nationality field
    );
  }
}
