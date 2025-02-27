import 'dart:convert';
import 'package:aqua_properties/features/nav_view/agencies/agencies_view.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AgenciesDetail extends StatefulWidget {
  const AgenciesDetail({super.key});

  @override
  State<AgenciesDetail> createState() => _AgenciesDetailState();
}

class _AgenciesDetailState extends State<AgenciesDetail> {
  List<Customer> agencies = [];
  List<Customer> filteredAgencies = [];
  bool isLoading = true;
  String errorMessage = "";
  String searchQuery = "";

  final String apiUrl = "https://beta.aquadev.me/json-call/get_agency_only";

  @override
  void initState() {
    super.initState();
    fetchAgencies();
  }

  Future<void> fetchAgencies() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? authToken = prefs.getString('authToken');
    String? email = prefs.getString('email');

    try {
      final Map<String, dynamic> requestPayload = {
        "login": email,
        "key": authToken,
        "db": "beta_Real_18_dec"
      };

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestPayload),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['result'] != null && data['result']['customer'] != null) {
          AgenciesDetails agencyResponse = AgenciesDetails.fromJson(data);

          setState(() {
            agencies = agencyResponse.result?.customer ?? [];
            filteredAgencies = agencies;
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
      print("Error Occurred: $e");
    }
  }

  void filterAgencies(String query) {
    setState(() {
      searchQuery = query;
      filteredAgencies = agencies
          .where((agency) =>
      agency.name!.toLowerCase().contains(query.toLowerCase()) ||
          agency.id!.toString().contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text("Agency Details",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: TextField(
              onChanged: filterAgencies,
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
                : filteredAgencies.isEmpty
                ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "No agencies found",
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
                width: 800,
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
                  rows: filteredAgencies.map((agency) {
                    return DataRow(
                        onSelectChanged: (selected) {
                          if (selected ?? false) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AgenciesView(
                                    id: agency.id.toString(),
                                    name: agency.name.toString(),
                                    mobile: agency.mobile.toString(),
                                    email: agency.email.toString(),
                                    country: agency.country.toString(),
                                    nationality: agency.nationality.toString(),
                                    lang: agency.lang.toString(),
                                    units : agency.units.toString(),
                                ),

                              ),
                            );
                          }
                        },
                        cells: [
                          DataCell(Text(
                              agency.id.toString() ?? "N/A")),
                          DataCell(Text(
                              agency.name.toString() ?? 'N/A')),
                          DataCell(Text(
                              agency.mobile.toString() ?? "N/A")),
                          DataCell(Text(
                              agency.email.toString() ?? 'N/A')),
                          DataCell(Text(
                              agency.country.toString() ?? 'N/A')),
                          DataCell(Text(
                              agency.nationality.toString() ?? 'N/A')),
                          DataCell(Text(
                              agency.lang.toString() ?? 'N/A')),
                          DataCell(Text(
                              agency.units.toString() ?? 'N/A')),
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






//Model Class

class AgenciesDetails {
  String? jsonrpc;
  dynamic id;
  Result? result;

  AgenciesDetails({this.jsonrpc, this.id, this.result});

  AgenciesDetails.fromJson(Map<dynamic, dynamic> json) {
    jsonrpc = json["jsonrpc"];
    id = json["id"];
    result = json["result"] == null ? null : Result.fromJson(json["result"]);
  }

  Map<dynamic, dynamic> toJson() {
    final Map<dynamic, dynamic> _data = <dynamic, dynamic>{};
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
    customer = json["customer"] == null ? null : (json["customer"] as List).map((e) => Customer.fromJson(e)).toList();
  }

  Map<dynamic, dynamic> toJson() {
    final Map<dynamic, dynamic> _data = <dynamic, dynamic>{};
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
  dynamic name;
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