import 'dart:async';
import 'dart:convert';

import 'package:aqua_properties/booking_id.dart';
import 'package:aqua_properties/custom_drawer.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:shared_preferences/shared_preferences.dart';
import '../../../unit_detail_screen.dart';
import '../../../view_booking_screen.dart';

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
  void _viewBooking(
    BuildContext context,
    String unitId,
    String status,
      String userId
  ) {
    // navigate to the ViewBooking screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViewBookingScreen(
          unitId: unitId,
          status: status,
          userId: userId,
        ), // Replace with your booking details screen
      ),
    );
  }

  Timer? _debounce; // Declare Timer variable for debounce

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
      "db": "beta_Real_18_dec",
    };

    final response = await http.post(
      Uri.parse('https://beta.aquadev.me/json-call/get_units'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(requestBody),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);

      // Debugging the response data
      print('Response: $data');

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


  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    searchController.clear();
    _debounce?.cancel();
    unitModelApis();

  }




// Search Bar for filter with list ui from here
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, true); // Handles the back button
        return true;
      },
      child: Scaffold(
        appBar: AppBar(iconTheme: const IconThemeData(color: Colors.white),
          //   actions: [
          //     ElevatedButton(onPressed: () {
          //   Navigator.push(context, MaterialPageRoute(builder: (context) => BookingId(bookingId: bookingId, status: status),));
          // }, child:Text("BookedId"))
          //
          // ],
          centerTitle: true,
          title: const Text(
            "Aqua Properties",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.blue,
        ),
        drawer: const CustomDrawer(),
        body: SafeArea(
            child: Column(
          children: [
            // Search Bar
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextFormField(
                controller: searchController,
                onChanged: (value) {
                  // Debounce to avoid immediate filtering on every keystroke
                  if (_debounce?.isActive ?? false) _debounce?.cancel();
                  _debounce = Timer(const Duration(milliseconds: 500), () {
                    filterUnits();
                  });
                },
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                  hintText: 'Search by Unit or Project',
                  // Updated hint text
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.filter_list_alt),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.blue, width: 2.0),
                      borderRadius: BorderRadius.circular(50.0)
                  ),
                ),
              ),
            ),

            // Loading Indicator
            if (isLoading) const Center(child: CircularProgressIndicator()),

            // Data Table with horizontal & vertical scrolling
            if (!isLoading && filteredUnitDataList.isNotEmpty)
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: 800, // Table width adjust karo agar zarurat ho
                    child: DataTable2(
                      headingRowHeight: 50,
                      columnSpacing: 8,
                      fixedTopRows: 1, // Header ko fix karne ke liye
                      horizontalMargin: 12,
                      minWidth: 800,
                      columns: const [
                        DataColumn(label: Text('Unit')),
                        DataColumn(label: Text('Project')),
                        DataColumn(label: Text('SalesPerson')),
                        DataColumn(label: Text('Total Price')),
                        DataColumn(label: Text('Status')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: filteredUnitDataList.map((unitData) {
                        return DataRow(
                          onSelectChanged: (selected) {
                            if (selected != null && selected) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UnitDetailScreen(
                                    unitIdName: unitData.name ?? "N/A",
                                    unitPrice: unitData.price?.toString() ?? "N/A",
                                    unitTotalArea: unitData.totalArea?.toString() ?? "N/A",
                                    unitProjectId: unitData.projectId ?? "N/A",
                                    unitplanId: unitData.planId ?? "N/A",
                                    unitbalconyArea: unitData.balconyArea ?? "N/A",
                                    unitbedTypeId: unitData.bedTypeId ?? "N/A",
                                    unitbuildArea: unitData.buildArea ?? "N/A",
                                    unitdiscount: unitData.discount ?? "N/A",
                                    unitflatArea: unitData.flatArea ?? "N/A",
                                    unitfloorId: unitData.floorId ?? "N/A",
                                    unitfloorTypeId: unitData.floorTypeId ?? "N/A",
                                    unitpriceUnit: unitData.priceUnit ?? "N/A",
                                    unittowerId: unitData.towerId ?? "N/A",
                                    unituserId: unitData.userId ?? "N/A",
                                    unitviewTypeId: unitData.viewTypeId ?? "N/A",
                                    unitthemeId: unitData.themeId ?? "N/A",
                                    unitId: unitData.id ?? "N/A",
                                    unitStatus: unitData.status ?? "N/A",
                                  ),
                                ),
                              );
                            }
                          },
                          cells: [
                            DataCell(Text(unitData.name ?? 'N/A')),
                            DataCell(Text(unitData.projectId ?? 'N/A')),
                            DataCell(Text(unitData.userId.toString() ?? 'N/A')),
                            DataCell(
                              Text(
                                '\$${unitData.price?.toStringAsFixed(2) ?? 'N/A'}',
                                style: const TextStyle(color: Colors.green),
                              ),
                            ),
                            DataCell(
                              Text(
                                unitData.status ?? 'N/A',
                                style: TextStyle(
                                  color: unitData.status == 'available'
                                      ? Colors.green
                                      : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            DataCell(
                              Row(
                                children: [
                                  if (unitData.status == 'available') ...[
                                    ElevatedButton(
                                      onPressed: () {
                                        _showPaymentPlan(context);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue,
                                        minimumSize: const Size(0, 0),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 6),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: const Text(
                                        'Offer',
                                        style: TextStyle(
                                            fontSize: 10, color: Colors.white),
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    ElevatedButton(
                                      onPressed: () {
                                        _showCustomers(
                                            context, unitData.id.toString());
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.deepPurple,
                                        minimumSize: const Size(0, 0),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 6),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: const Text(
                                        'Book',
                                        style: TextStyle(
                                            fontSize: 10, color: Colors.white),
                                      ),
                                    ),
                                  ] else ...[
                                    ElevatedButton(
                                      onPressed: () {
                                        _viewBooking(
                                            context,
                                            unitData.id.toString(),
                                            unitData.status.toString(),
                                            unitData.userId);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.orangeAccent,
                                        minimumSize: const Size(0, 0),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 6),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: const Text(
                                        'View Booking',
                                        style: TextStyle(
                                            fontSize: 10, color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),

            // Empty State
            if (!isLoading && filteredUnitDataList.isEmpty)
              const Center(
                child: Text(
                  'No units available',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
          ],
        )),
      ),
    );
  }
}







// Model classes from here
class UnitModel {
  final Result? result;

  UnitModel({this.result});

  factory UnitModel.fromJson(Map<dynamic, dynamic> json) {
    return UnitModel(
      result: json['result'] != null ? Result.fromJson(json['result']) : null,
    );
  }
}

class Result {
  final List<UnitData>? unitData;

  Result({this.unitData});

  factory Result.fromJson(Map<dynamic, dynamic> json) {
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
  final int? id; // Added id field
  final String? status; // Added status field

  // New fields
  final dynamic planId;
  final dynamic priceUnit;
  final dynamic discount;
  final dynamic userId;
  final dynamic flatArea;
  final dynamic buildArea;
  final dynamic balconyArea;
  final dynamic towerId;
  final dynamic floorId;
  final dynamic floorTypeId;
  final dynamic bedTypeId;
  final dynamic viewTypeId;
  final dynamic themeId;

  UnitData({
    this.name,
    this.price,
    this.totalArea,
    this.projectId,
    this.id,
    this.status,
    this.planId,
    this.priceUnit,
    this.discount,
    this.userId,
    this.flatArea,
    this.buildArea,
    this.balconyArea,
    this.towerId,
    this.floorId,
    this.floorTypeId,
    this.bedTypeId,
    this.viewTypeId,
    this.themeId,
  });

  factory UnitData.fromJson(Map<dynamic, dynamic> json) {
    return UnitData(
      name: json['name'],
      price: json['price'],
      totalArea: json['total_area'],
      projectId: json['project_id'],
      id: json['id'],
      // Parse id
      status: json['status'],
      // Parse status

      // New fields parsing
      planId: json['plan_id'],
      priceUnit: json['price_unit'],
      discount: json['discount'],
      userId: json['user_id'],
      flatArea: json['flat_area'],
      buildArea: json['build_area'],
      balconyArea: json['balcony_area'],
      towerId: json['tower_id'],
      floorId: json['floor_id'],
      floorTypeId: json['floor_type_id'],
      bedTypeId: json['bed_type_id'],
      viewTypeId: json['view_type_id'],
      themeId: json['theme_id'],
    );
  }
}







//Also ui function part from her
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
        title: const Text("Booking Page"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
              child: Text(
            "Booking Page unit id: ${widget.unitId}",
            style: const TextStyle(backgroundColor: Colors.blueAccent, fontSize: 30),
          ))
        ],
      ),
    );
  }
}




//function model of ui

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
    const String apiUrl =
        "https://beta.aquadev.me/json-call/get_unit_paymentplan";

    // Retrieve the token from SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? authToken = prefs.getString('authToken'); // Get the stored token
    String? email = prefs.getString('email');

    if (authToken == null) {
      print('Token not found, please login');
      return; // Exit if token is not found
    }

    // Use the token in the request payload
    var requestPayload = {
      "login": email,
      "key": authToken,
      "db": "beta_Real_18_dec",
      "id": 1077,
      //"key": "edec66b8c075611a78bd9ed7f00dbb0df065cdeac12b2beaaebbfe316f983e4d",// Add the token to the payload
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
void _showCustomers(BuildContext context, String unitId) {
  String? selectedCustomer;
  String? selectedPaymentPlan;
  String? selectedPlanId;
  Map<String, dynamic>? selectedAgency;
  Map<String, dynamic>? selectedAgent;
  List<Map<String, dynamic>> customers = [];
  List<Map<String, dynamic>> agencies = [];
  List<Map<String, dynamic>> agents = [];
  List<Map<String, dynamic>> paymentPlans = [];
  bool isLoading = true;
  bool isSubmitting = false;
  List<Map<String, dynamic>> selectedOtherPartners = [];
  List<Map<String, dynamic>> filteredAgents = [];

  // Fetch data
  Future<void> fetchData(Function setState) async {
    String apiUrl = "https://beta.aquadev.me/json-call/get_booking_data";

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? authToken = prefs.getString('authToken');
    String? email = prefs.getString('email');

    if (authToken == null) {
      print('Token not found');
      return;
    }

    var requestPayload = {
      "login": email,
      "key": authToken,
      "db": "beta_Real_18_dec",
      "id": 1077,
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
            paymentPlans = List<Map<String, dynamic>>.from(
                data['result']['plans'] ?? []);
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

  // Handle Submit Request
  void _handleSubmit(Function setState, BuildContext context) {
    setState(() {
      isSubmitting = true; // Show progress indicator
    });

    final bookingData = {
      "unit_id": unitId,
      "customer": selectedCustomer,
      "plan_id": selectedPlanId,
      "agency": selectedAgency?['id'],
      "agent": selectedAgent?['id'],
      "otherPartners":
      selectedOtherPartners.map((partner) => partner['id']).toList(),
      "partner_id": selectedOtherPartners.isNotEmpty
          ? selectedOtherPartners.first['id']
          : null,
    };

    SharedPreferences.getInstance().then((prefs) async {
      String? authToken = prefs.getString('authToken');
      String? email = prefs.getString('email');
      if (authToken == null) {
        print("Auth token is missing");
        return;
      }

      try {
        print("Sending data to the server: ");
        print(bookingData);

        final response = await http.post(
          Uri.parse("https://beta.aquadev.me/json-call/create_booking"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "login": email,
            "key": authToken,
            "plan_id": selectedPlanId,
            "agency_id": selectedAgency?['id'],
            "unit_id": unitId.toString(),
            "agency_agent_id": selectedAgent?['id'],
            "other_part_ids": selectedOtherPartners
                .map((partner) => partner['id'])
                .toList(),
            "partner_id": selectedCustomer,
          }),
        );

        print("Response status: ${response.statusCode}");
        print("Response body: ${response.body}");

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          final bookingId = responseData["result"]['book_id'];
          final status = responseData["result"]['status'];

          print("Unit Name (used as unitId): $unitId");
          print("Submission successful: ${response.body}");

          // ✅ **Alert box ko close karne ke liye ye line add ki hai**
          Navigator.pop(context, true);

          // ✅ Snackbar ki jagah AlertDialog implement kiya hai
          showDialog(
            context: context,
            barrierDismissible: false, // User manually dismiss na kar sake
            builder: (BuildContext context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(15.0), // Rounded Corners
                ),
                backgroundColor: Colors.green,
                // ✅ Green Success Background
                title: const Column(
                  children: [
                    Icon(
                      Icons.check_circle, // ✅ Success Icon
                      size: 50.0,
                      color: Colors.white,
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Booking Successful",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                      ),
                    ),
                  ],
                ),
                content: Text(
                  "Booked successfully! Booking ID: $bookingId",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                  ),
                  textAlign: TextAlign.center,
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      // ✅ Pehle dialog close hoga, phir BookingId screen open hogi
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookingId(
                            bookingId: bookingId.toString(),
                            status: status.toString(),
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      "OK",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              );
            },
          );
        } else {
          print("Submission failed with status: ${response.statusCode}");

          // ✅ Booking fail hone par Snackbar show karega
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                "Unable to process, please contact admin.",
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating, // ✅ Floating effect
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      } catch (e) {
        print("An error occurred during submission: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Already booked.",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          isSubmitting = false; // Hide progress indicator after submission
        });
      }
    });
  }

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          if (isLoading) fetchData(setState);

          return AlertDialog(
            title: const Text('Booking Customers',
                style: TextStyle(fontWeight: FontWeight.bold)),
            content: isSubmitting
                ? const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(), // Circular progress indicator
                SizedBox(
                    height: 16), // Space between indicator and text
                Text(
                  "Please Wait...",
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            )
                : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isSubmitting)
                    const Center(child: CircularProgressIndicator())
                  else if (isLoading)
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
                              customer['id'].toString() ==
                                  selectedCustomer,
                              orElse: () => {}),
                          hint: const Text("Select a Customer"),
                          isExpanded: true,
                          items: customers
                              .map<DropdownMenuItem<Map<String, dynamic>>>(
                                  (customer) {
                                return DropdownMenuItem<Map<String, dynamic>>(
                                  value: customer,
                                  child: Text(customer['name'] ?? 'No name',
                                      overflow: TextOverflow.ellipsis),
                                );
                              }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedCustomer = value?['id'].toString();
                            });
                            print(
                                'Selected Customer ID: $selectedCustomer');
                          },
                        ),
                        const SizedBox(height: 20),
                        const Text('Payment Plan:'),
                        paymentPlans.isEmpty
                            ? const Text("No payment plans available.")
                            : DropdownButton<Map<String, dynamic>>(
                          value: selectedPaymentPlan == null
                              ? null
                              : paymentPlans.firstWhere(
                                  (plan) =>
                              plan['id'].toString() ==
                                  selectedPaymentPlan,
                              orElse: () => {}),
                          hint: const Text("Select a Payment Plan"),
                          isExpanded: true,
                          items: paymentPlans.map<
                              DropdownMenuItem<
                                  Map<String, dynamic>>>((plan) {
                            return DropdownMenuItem<
                                Map<String, dynamic>>(
                              value: plan,
                              child: Text(plan['name'] ?? 'No name',
                                  overflow: TextOverflow.ellipsis),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedPaymentPlan =
                                  value?['id'].toString();
                              selectedPlanId = selectedPaymentPlan;
                            });
                            print(
                                'Selected Payment Plan ID: $selectedPlanId');
                          },
                        ),
                        if (selectedPaymentPlan != null)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Selected Plan ID: $selectedPlanId"),
                            ],
                          ),
                        const SizedBox(height: 20),
                        const Text('Agency:'),
                        agencies.isEmpty
                            ? const Text("No agencies available.")
                            : DropdownButton<Map<String, dynamic>>(
                          value: selectedAgency,
                          hint: const Text("Select an Agency"),
                          isExpanded: true,
                          items: agencies.map<
                              DropdownMenuItem<
                                  Map<String, dynamic>>>((agency) {
                            return DropdownMenuItem<
                                Map<String, dynamic>>(
                              value: agency,
                              child: Text(agency['name'] ?? 'No name',
                                  overflow: TextOverflow.ellipsis),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedAgency = value;
                              selectedAgent = null;
                              filteredAgents = agents.where((agent) {
                                return agent['agency_id'] ==
                                    selectedAgency?['id'];
                              }).toList();
                            });
                            print(
                                'Selected Agency ID: ${selectedAgency?['id']}');
                          },
                        ),
                        const SizedBox(height: 20),
                        const Text('Agent:'),
                        filteredAgents.isEmpty
                            ? const Text("No agents available.")
                            : DropdownButton<Map<String, dynamic>>(
                          value: selectedAgent,
                          hint: const Text("Select an Agent"),
                          isExpanded: true,
                          items: filteredAgents.map<
                              DropdownMenuItem<
                                  Map<String, dynamic>>>((agent) {
                            return DropdownMenuItem<
                                Map<String, dynamic>>(
                              value: agent,
                              child: Text(agent['name'] ?? 'No name',
                                  overflow: TextOverflow.ellipsis),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedAgent = value;
                            });
                            print(
                                'Selected Agent ID: ${selectedAgent?['id']}');
                          },
                        ),
                        const SizedBox(height: 20),
                        const Text('Other Partners (Multiple Selection):'),
                        customers.isEmpty
                            ? const Text("No customers available.")
                            : Column(
                          children: [
                            DropdownButton<Map<String, dynamic>>(
                              hint:
                              const Text("Select Other Partners"),
                              isExpanded: true,
                              items: customers.map<
                                  DropdownMenuItem<
                                      Map<String, dynamic>>>(
                                      (partner) {
                                    return DropdownMenuItem<
                                        Map<String, dynamic>>(
                                      value: partner,
                                      child: Text(
                                          partner['name'] ?? 'No name',
                                          overflow:
                                          TextOverflow.ellipsis),
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
                                print(
                                    'Selected Other Partner ID: ${value?['id']}');
                              },
                            ),
                            Wrap(
                              spacing: 8.0,
                              children: selectedOtherPartners
                                  .map((partner) {
                                return Chip(
                                  label: Text(partner['name'] ?? ''),
                                  onDeleted: () {
                                    setState(() {
                                      selectedOtherPartners
                                          .remove(partner);
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ],
                ],
              ),
            ),
            actions: isSubmitting
                ? []
                : [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, true);
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  _handleSubmit(setState, context);
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
