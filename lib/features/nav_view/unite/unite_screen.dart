import 'dart:convert';

import 'package:aqua_properties/unit_detail_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:shared_preferences/shared_preferences.dart';

Future<void> requestStoragePermission() async {
  if (await Permission.storage.request().isGranted) {
    print("Storage permission granted");
  } else if (await Permission.manageExternalStorage.request().isGranted) {
    print("Manage external storage permission granted");
  } else {
    print("Storage permission denied");
  }
}

class UniteScreen extends StatefulWidget {
  final String selectPlan;

  const UniteScreen({super.key, required this.selectPlan});

  @override
  State<UniteScreen> createState() => _UniteScreenState();
}

class _UniteScreenState extends State<UniteScreen> {
  TextEditingController searchController = TextEditingController();

  List<UnitData> unitDataList = [];
  List<UnitData> filteredUnitDataList = [];
  bool isLoading = false;

  Future<void> unitModelApis() async {
    setState(() {
      isLoading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('email');
    String? token = prefs.getString('authToken');

    if (email == null || token == null) {
      print('No email or token found');
      setState(() {
        isLoading = false;
      });
      return;
    }
    print('Email: $email');
    print('Token: $token');

    Map<String, String> requestBody = {
      "login": email,
      "key": token,
      "db": "New_Real_Estate",
    };

    final response = await http.post(
      Uri.parse('https://aquadev.me/json-call/get_units'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(requestBody),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);

      if (data['result'] != null && data['result']['unit_data'] != null) {
        UnitModel unitModel = UnitModel.fromJson(data);
        setState(() {
          unitDataList = unitModel.result!.unitData!;
          filteredUnitDataList = unitDataList;
        });
      } else {
        print('No unit data found in response');
        setState(() {
          unitDataList = [];
          filteredUnitDataList = [];
        });
      }
    } else {
      print('Failed to load units');
      print('Error details: ${response.body}');
    }

    setState(() {
      isLoading = false;
    });
  }

  void filterUnits() {
    setState(() {
      filteredUnitDataList = unitDataList
          .where((unit) =>
              (unit.name?.toLowerCase() ?? '')
                  .contains(searchController.text.toLowerCase()) ||
              (unit.projectId?.toLowerCase() ?? '')
                  .contains(searchController.text.toLowerCase()))
          .toList();
    });
  }

  @override
  void initState() {
    super.initState();
    unitModelApis();
  }

  // For Plan button pop up
  void _showPaymentPlan(BuildContext context) {
    String? selectedPlan;
    int? selectedPlanId;
    bool isLoading = true;
    List<Map<String, dynamic>> paymentPlans = [];

    // Function to request storage permission
    Future<void> requestStoragePermission() async {
      if (!await Permission.storage.request().isGranted) {
        print("Storage permission denied");
      }
    }

    // Function to open downloaded file
    Future<void> openDownloadedFile(String filePath) async {
      final result = await OpenFile.open(filePath);
      if (result.type != ResultType.done) {
        print("Error opening file: ${result.message}");
      }
    }

    // Function to download the PDF using Dio
    Future<void> downloadPdf() async {
      const String fileUrl =
          "https://aquadev.me/web/content/457159?download=true";
      const filename = "Plan_D201.pdf";

      try {
        await requestStoragePermission();

        final directory = await getExternalStorageDirectory();
        if (directory == null) throw Exception("Failed to access storage");

        String savePath = "${directory.path}/$filename";

        Dio dio = Dio();
        Response response = await dio.download(fileUrl, savePath);

        if (response.statusCode == 200) {
          print("Download complete: $savePath");

          // After download is complete, open the file
          openDownloadedFile(savePath);
        } else {
          print("Error: Unable to download file");
        }
      } catch (e) {
        print("Error downloading PDF: $e");
      }
    }

    // Function to fetch payment plans
    Future<void> fetchPaymentPlans(Function setState) async {
      const String apiUrl = "https://aquadev.me/json-call/get_unit_paymentplan";
      const requestPayload = {
        "login": "app_user@akili.com",
        "key":
            "edec66b8c075611a78bd9ed7f00dbb0df065cdeac12b2beaaebbfe316f983e4d",
        "db": "New_Real_Estate",
        "id": 1077
      };

      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(requestPayload),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['result'] != null && data['result']['plans'] != null) {
            setState(() {
              paymentPlans =
                  List<Map<String, dynamic>>.from(data['result']['plans']);
              isLoading = false;
            });
          } else {
            setState(() {
              isLoading = false;
              paymentPlans = [];
            });
          }
        } else {
          setState(() {
            isLoading = false;
            paymentPlans = [];
          });
          print("Error: ${response.body}");
        }
      } catch (e) {
        setState(() {
          isLoading = false;
          paymentPlans = [];
        });
        print("Error fetching payment plans: $e");
      }
    }

    // Show payment plan dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            if (isLoading) {
              fetchPaymentPlans(setState);
            }

            return AlertDialog(
              title: const Text(
                'Payment Plan',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (paymentPlans.isEmpty)
                    const Text('No payment plans available.')
                  else ...[
                    const Text('Choose a payment plan:'),
                    const SizedBox(height: 10),
                    DropdownButton<Map<String, dynamic>>(
                      value: selectedPlanId == null
                          ? null
                          : paymentPlans.firstWhere(
                              (plan) => plan['id'] == selectedPlanId),
                      isExpanded: true,
                      hint: const Text("Select a Plan"),
                      items: paymentPlans.map((plan) {
                        return DropdownMenuItem<Map<String, dynamic>>(
                          value: plan,
                          child: Text("${plan['id']} - ${plan['name']}"),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedPlan = value?['name'];
                          selectedPlanId = value?['id'];
                        });
                      },
                    ),
                    if (selectedPlan != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        "Selected Plan: $selectedPlan\nPlan ID: $selectedPlanId",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                    ],
                  ],
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Close'),
                ),
                ElevatedButton(
                  onPressed: selectedPlan == null
                      ? null
                      : () {
                          downloadPdf();
                          Navigator.of(context).pop();
                        },
                  child: const Text('Download PDF'),
                ),
              ],
            );
          },
        );
      },
    );
  }





  // For Book Button pop up
  void _showCustomers(BuildContext context) {
    String? selectedCustomer;
    String? selectedPaymentPlan;
    Map<String, dynamic>? selectedAgency;
    Map<String, dynamic>? selectedAgent;
    List<Map<String, dynamic>> customers = [];
    List<Map<String, dynamic>> agencies = [];
    List<Map<String, dynamic>> agents = [];
    List<String> paymentPlans = [];
    bool isLoading = true;
    List<Map<String, dynamic>> selectedOtherPartners = [];
    List<Map<String, dynamic>> filteredAgents = [];  // To store filtered agents

    Future<void> fetchData(Function setState) async {
      const String apiUrl =
          "https://beta.aquadev.me/json-call/get_booking_data";
      const requestPayload = {
        "login": "app_user@akili.com",
        "key":
        "feaf757e3f5bfa31e39afaf072db4ff488f9f3c4319e2e7104e136de0b4dc002",
        "db": "beta_Real_18_dec",
        "id": 3677
      };

      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(requestPayload),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);

          setState(() {
            if (data['result'] != null) {
              customers = List<Map<String, dynamic>>.from(
                  data['result']['customer'] ?? []);
              paymentPlans = List<String>.from(
                  data['result']['plans']?.map((plan) => plan['name']) ?? []);
              agencies = List<Map<String, dynamic>>.from(
                  data['result']['agency'] ?? []);
              agents = List<Map<String, dynamic>>.from(
                  data['result']['agent'] ?? []);
            }
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
        }
      } catch (e) {
        setState(() {
          isLoading = false;
        });
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            if (isLoading) fetchData(setState);

            return AlertDialog(
              title: const Text(
                'Booking Customers',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (customers.isEmpty)
                      const Text('No customers available.')
                    else ...[
                        const Text('Choose a customer:'),
                        DropdownButton<Map<String, dynamic>>(
                          value: selectedCustomer == null
                              ? null
                              : customers.firstWhere(
                                  (customer) =>
                              customer['name'] == selectedCustomer,
                              orElse: () => {}),
                          hint: const Text("Select a Customer"),
                          isExpanded: true,
                          items: customers
                              .map<DropdownMenuItem<Map<String, dynamic>>>(
                                  (customer) {
                                return DropdownMenuItem<Map<String, dynamic>>(
                                  value: customer,
                                  child: Text(
                                    customer['name'] ?? 'No name',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedCustomer = value?['name'];
                            });
                          },
                        ),
                        if (selectedCustomer != null)
                          Text("Selected Customer: $selectedCustomer"),
                        const SizedBox(height: 20),
                        const Text('Payment Plan:'),
                        paymentPlans.isEmpty
                            ? const Text("No payment plans available.")
                            : DropdownButton<String>(
                          value: selectedPaymentPlan,
                          hint: const Text("Select a Payment Plan"),
                          isExpanded: true,
                          items: paymentPlans
                              .map<DropdownMenuItem<String>>((plans) {
                            return DropdownMenuItem<String>(
                              value: plans,
                              child: Text(
                                plans,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedPaymentPlan = value;
                            });
                          },
                        ),
                        if (selectedPaymentPlan != null)
                          Text("Selected Payment Plan: $selectedPaymentPlan"),
                        const SizedBox(height: 20),
                        const Text('Agency:'),
                        agencies.isEmpty
                            ? const Text("No agencies available.")
                            : DropdownButton<Map<String, dynamic>>(
                          value: selectedAgency,
                          hint: const Text("Select an Agency"),
                          isExpanded: true,
                          items: agencies
                              .map<DropdownMenuItem<Map<String, dynamic>>>(
                                  (agency) {
                                return DropdownMenuItem<Map<String, dynamic>>(
                                  value: agency,
                                  child: Text(
                                    agency['name'] ?? 'No name',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedAgency = value;
                              selectedAgent = null; // Reset selected agent
                              // Filter agents based on selected agency
                              filteredAgents = agents.where((agent) {
                                return agent['agency_id'] ==
                                    selectedAgency?['id'];
                              }).toList();
                            });
                          },
                        ),
                        if (selectedAgency != null)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Selected Agency: ${selectedAgency!['name']}"),
                              if (selectedAgency!['id'] != null)
                                Text("ID: ${selectedAgency!['id']}"),
                            ],
                          ),
                        const SizedBox(height: 20),
                        const Text('Agent:'),
                        filteredAgents.isEmpty
                            ? const Text("No agents available for the selected agency.")
                            : DropdownButton<Map<String, dynamic>>(
                          value: selectedAgent,
                          hint: const Text("Select an Agent"),
                          isExpanded: true,
                          items: filteredAgents
                              .map<DropdownMenuItem<Map<String, dynamic>>>(
                                  (agent) {
                                return DropdownMenuItem<Map<String, dynamic>>(
                                  value: agent,
                                  child: Text(
                                    agent['name'] ?? 'No name',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedAgent = value;
                            });
                          },
                        ),
                        if (selectedAgent != null)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Selected Agent: ${selectedAgent!['name']}"),
                              if (selectedAgent!['id'] != null)
                                Text("ID: ${selectedAgent!['id']}"),
                              if (selectedAgent!['agency_id'] != null)
                                Text("Agency ID: ${selectedAgent!['agency_id']}"),
                            ],
                          ),
                        const SizedBox(height: 20),
                        const Text('Other Partners (Multiple Selection):'),
                        customers.isEmpty
                            ? const Text("No customers available.")
                            : Column(
                          children: [
                            DropdownButton<Map<String, dynamic>>(
                              hint: const Text("Select Other Partners"),
                              isExpanded: true,
                              items: customers.map<
                                  DropdownMenuItem<
                                      Map<String, dynamic>>>((partner) {
                                return DropdownMenuItem<
                                    Map<String, dynamic>>(
                                  value: partner,
                                  child: Text(
                                    partner['name'] ?? 'No name',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  if (value != null &&
                                      !selectedOtherPartners
                                          .contains(value)) {
                                    selectedOtherPartners.add(value);
                                  }
                                });
                              },
                            ),
                            Wrap(
                              spacing: 8.0,
                              children: selectedOtherPartners
                                  .map((partner) => Chip(
                                label: Text(partner['name'] ?? ''),
                                onDeleted: () {
                                  setState(() {
                                    selectedOtherPartners.remove(partner);
                                  });
                                },
                              ))
                                  .toList(),
                            ),
                          ],
                        ),
                      ],
                  ],
                ),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Handle form submission
                  },
                  child: const Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );
  }




// Search Bar for filter with list ui from here
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: searchController,
                onChanged: (value) {
                  filterUnits();
                },
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                  hintText: 'Search ...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.filter_list_alt),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50.0),
                  ),
                ),
              ),
            ),

            // Loading Indicator
            if (isLoading) const Center(child: CircularProgressIndicator()),

            // Data Cards
            if (!isLoading && unitDataList.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: filteredUnitDataList.length,
                  itemBuilder: (context, index) {
                    var unitData = filteredUnitDataList[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 6.0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UnitDetailScreen(
                                  unitIdName: unitData.name ?? "N/A",
                                  unitPrice: unitData.price.toString() ?? "N/A",
                                  unitTotalArea:
                                      unitData.totalArea.toString() ?? "N/A",
                                  unitProjectId: unitData.projectId ?? "N/A",
                                ),
                              ));
                        },
                        child: Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Unit Name
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Unit',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      unitData.name ?? 'N/A',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),

                                // Project ID
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Project',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      unitData.projectId ?? 'N/A',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),

                                // Total Price
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Total Price',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      '\$${unitData.price?.toStringAsFixed(2) ?? 'N/A'}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),

                                // // Area Sq. ft
                                // Column(
                                //   crossAxisAlignment: CrossAxisAlignment.start,
                                //   children: [
                                //     const Text(
                                //       'Area (Sq. ft)',
                                //       style: TextStyle(
                                //         fontWeight: FontWeight.bold,
                                //         fontSize: 14,
                                //         color: Colors.grey,
                                //       ),
                                //     ),
                                //     Text(
                                //       '${unitData.totalArea?.toStringAsFixed(2) ?? 'N/A'}',
                                //       style: const TextStyle(
                                //         fontSize: 16,
                                //         fontWeight: FontWeight.w600,
                                //       ),
                                //     ),
                                //   ],
                                // ),

                                // Plan Button
                                ElevatedButton(
                                  onPressed: () {
                                    _showPaymentPlan(
                                        context); // Call the function to show the dialog
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blueAccent,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text('Plan'),
                                ),

                                // Book Button
                                ElevatedButton(
                                  onPressed: () {
                                    _showCustomers(context);

                                    //Navigator.push(context, MaterialPageRoute(builder: (context) => BookingPage(unitId: unitData.name ?? "N/A"),));
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.deepPurple,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text('Book'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

            // Empty State
            if (!isLoading && unitDataList.isEmpty)
              const Center(
                child: Text(
                  'No units available',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Model classes from here
class UnitModel {
  final Result? result;

  UnitModel({this.result});

  factory UnitModel.fromJson(Map<String, dynamic> json) {
    return UnitModel(
      result: json['result'] != null ? Result.fromJson(json['result']) : null,
    );
  }
}

class Result {
  final List<UnitData>? unitData;

  Result({this.unitData});

  factory Result.fromJson(Map<String, dynamic> json) {
    return Result(
      unitData: (json['unit_data'] as List<dynamic>?)
          ?.map((e) => UnitData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class UnitData {
  final String? name;
  final double? price;
  final double? totalArea;
  final String? projectId;

  UnitData({this.name, this.price, this.totalArea, this.projectId});

  factory UnitData.fromJson(Map<String, dynamic> json) {
    return UnitData(
      name: json['name'],
      price: json['price'],
      totalArea: json['total_area'],
      projectId: json['project_id'],
    );
  }
}

// Dialog Box
Future<void> showMyDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        content: const Text("Confirm Booking"),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Confirm"),
          ),
        ],
      );
    },
  );
}

// Booking Screen
class BookingPage extends StatefulWidget {
  final String unitId;

  const BookingPage({super.key, required this.unitId});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Booking Page"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
              child: Text(
            "Booking Page unit id: ${widget.unitId}",
            style: TextStyle(backgroundColor: Colors.blueAccent, fontSize: 30),
          ))
        ],
      ),
    );
  }
}
