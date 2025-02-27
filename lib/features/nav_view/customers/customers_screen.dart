import 'dart:convert';
import 'package:aqua_properties/customer_view.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class CustomerDetail extends StatefulWidget {
  const CustomerDetail({super.key});

  @override
  State<CustomerDetail> createState() => _CustomerDetailState();
}

class _CustomerDetailState extends State<CustomerDetail> {
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

      // Debugging Statements
      print("Request Payload: $requestPayload");
      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

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
        print("Failed to load data. Status Code: ${response.statusCode}");
        print("Response Body: ${response.body}");
        throw Exception("Failed to load data. Status Code: ${response.statusCode}. Response: ${response.body}");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
      print("Error Occurred: $e");
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
        title: const Text("Customer Details",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
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
                  borderRadius: BorderRadius.circular(50.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.blue, width: 2.0),
                  borderRadius: BorderRadius.circular(50.0),
                ),
                contentPadding:
                const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
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
                  style: const TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
              ),
            )
                : filteredCustomers.isEmpty
                ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "No customers found",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600]),
                ),
              ),
            )
                : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: 800, // Minimum width for horizontal scrolling
                child: DataTable2(
                  columnSpacing: 8,
                  fixedTopRows: 1,
                  horizontalMargin: 12,
                  minWidth: 800,
                  columns: const [
                    DataColumn(
                        label: Text('ID',
                            style: TextStyle(
                                fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Name',
                            style: TextStyle(
                                fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Mobile',
                            style: TextStyle(
                                fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Email',
                            style: TextStyle(
                                fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Country',
                            style: TextStyle(
                                fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Nationality',
                            style: TextStyle(
                                fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Lang',
                            style: TextStyle(
                                fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Units',
                            style: TextStyle(
                                fontWeight: FontWeight.bold))),
                  ],
                  rows: filteredCustomers.map((customer) {
                    return DataRow(
                        onSelectChanged: (selected) {
                          if (selected ?? false) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    CustomerView(
                                        id: customer.id.toString(),
                                        name: customer.name.toString(),
                                        mobile: customer.mobile.toString(),
                                        email: customer.email.toString(),
                                        country: customer.country.toString(),
                                        nationality: customer.nationality.toString(),
                                        lang: customer.lang.toString(),
                                        units: customer.units),
                              ),
                            );
                          }
                        },
                        cells: [
                          DataCell(Text(
                              customer.id.toString() ?? "N/A")),
                          DataCell(Text(
                              customer.name.toString() ?? 'N/A')),
                          DataCell(Text(
                              customer.mobile.toString() ??
                                  "N/A")),
                          DataCell(Text(
                              customer.email.toString() ?? 'N/A')),
                          DataCell(Text(
                              customer.country.toString() ??
                                  "N/A")),
                          DataCell(Text(
                              customer.nationality.toString() ??
                                  "N/A")),
                          DataCell(Text(
                              customer.lang.toString() ?? "N/A")),
                          DataCell(Text(
                              customer.units.toString() ??
                                  "N/A")),
                        ]);
                  }).toList(),
                ),
              ),
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
