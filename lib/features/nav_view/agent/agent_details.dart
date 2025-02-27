import 'package:aqua_properties/features/nav_view/agent/agent_view.dart';
import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AgentDetail extends StatefulWidget {
  const AgentDetail({super.key});

  @override
  State<AgentDetail> createState() => _AgentDetailState();
}

class _AgentDetailState extends State<AgentDetail> {
  late Future<List<Customer>> _agentDetails;
  List<Customer> _allCustomers = [];
  List<Customer> _filteredCustomers = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _agentDetails = fetchAgentDetails();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // API Call to fetch Agent Details
  Future<List<Customer>> fetchAgentDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? authToken = prefs.getString('authToken');
    String? email = prefs.getString('email');

    print('Auth Token: $authToken');
    print('Email: $email');

    const url = 'https://beta.aquadev.me/json-call/get_agents_only';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "login": email,
        "key": authToken,
        "db": "beta_Real_18_dec"
      }),
    );

    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      AgentDetails agentDetails = AgentDetails.fromJson(jsonData);

      print('Parsed Data: ${agentDetails.result?.customer}');

      _allCustomers = agentDetails.result?.customer ?? [];
      _filteredCustomers = _allCustomers;

      // Debug: Check if list is populated
      print('All Customers: $_allCustomers');
      print('Filtered Customers: $_filteredCustomers');

      return _allCustomers;
    } else {
      print('Failed to load data');
      throw Exception('Failed to load data');
    }
  }

  // Search Functionality
  void _onSearchChanged() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCustomers = _allCustomers.where((customer) {
        return customer.id.toString().contains(query) ||
            (customer.name?.toLowerCase().contains(query) ?? false);
      }).toList();
    });

    // Debug: Check filtered list
    print('Search Query: $query');
    print('Filtered List: $_filteredCustomers');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.blue,
          title: const Text('Agent Details',style: TextStyle(color: Colors.white),)),
      body: Column(
        children: [
          const SizedBox(height: 10),
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: TextField(
             controller: _searchController,
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
            child: FutureBuilder<List<Customer>>(
              future: _agentDetails,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  if (_filteredCustomers.isEmpty) {
                    return const Center(child: Text('No data available'));
                  }

                  // SingleChildScrollView with SizedBox
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: DataTable2(
                        columnSpacing: 12,
                        horizontalMargin: 12,
                        minWidth: 800,
                        columns: const [
                          DataColumn(label: Text('ID')),
                          DataColumn(label: Text('Name')),
                          DataColumn(label: Text('Mobile')),
                          DataColumn(label: Text('Email')),
                          DataColumn(label: Text('Country')),
                          DataColumn(label: Text('Nationality')),
                          DataColumn(label: Text('Lang')),
                          DataColumn(label: Text('Units')),
                        ],
                        rows: _filteredCustomers.map((customer) {
                          return DataRow(
                            cells: [
                              DataCell(Text(customer.id.toString())),
                              DataCell(Text(customer.name ?? '')),
                              DataCell(Text(customer.mobile ?? '')),
                              DataCell(Text(customer.email ?? '')),
                              DataCell(Text(customer.country.toString())),
                              DataCell(Text(customer.nationality.toString())),
                              DataCell(Text(customer.lang ?? '')),
                              DataCell(Text(customer.units.toString())),
                            ],
                            onSelectChanged: (isSelected) {
                              if (isSelected != null && isSelected) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AgentView(
                                      customer: customer,
                                    ),
                                  ),
                                );
                              }
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  );
                } else {
                  return const Center(child: Text('No data available'));
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}





// Model Classes
class AgentDetails {
  String? jsonrpc;
  dynamic id;
  Result? result;

  AgentDetails({this.jsonrpc, this.id, this.result});

  AgentDetails.fromJson(Map<dynamic, dynamic> json) {
    jsonrpc = json["jsonrpc"];
    id = json["id"];
    result = json["result"] == null ? null : Result.fromJson(json["result"]);
  }

  Map<dynamic, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["jsonrpc"] = jsonrpc;
    _data["id"] = id;
    if(result != null) {
      _data["result"] = result?.toJson();
    }
    return _data;
  }
}

class Result {
  String? status;
  int? uid;
  List<Customer>? customer;

  Result({this.status, this.uid, this.customer});

  Result.fromJson(Map<dynamic, dynamic> json) {
    status = json["status"];
    uid = json["uid"];
    customer = json["customer"] == null
        ? null
        : (json["customer"] as List).map((e) => Customer.fromJson(e)).toList();
  }

  Map<dynamic, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["status"] = status;
    _data["uid"] = uid;
    if(customer != null) {
      _data["customer"] = customer?.map((e) => e.toJson()).toList();
    }
    return _data;
  }
}

class Customer {
  dynamic id;
  dynamic  name;
  dynamic mobile;
  dynamic email;
  dynamic country;
  dynamic nationality;
  dynamic lang;
  List<dynamic>? units;

  Customer({this.id, this.name, this.mobile, this.email, this.country, this.nationality, this.lang, this.units});

  Customer.fromJson(Map<dynamic, dynamic> json) {
    id = json["id"];
    name = json["name"];
    mobile = json["mobile"];
    email = json["email"];
    country = json["country"];
    nationality = json["nationality"];
    lang = json["lang"];
    units = json["units"] ?? [];
  }

  Map<dynamic, dynamic> toJson() {
    final Map<dynamic, dynamic> _data = <String, dynamic>{};
    _data["id"] = id;
    _data["name"] = name;
    _data["mobile"] = mobile;
    _data["email"] = email;
    _data["country"] = country;
    _data["nationality"] = nationality;
    _data["lang"] = lang;
    if(units != null) {
      _data["units"] = units;
    }
    return _data;
  }
}
