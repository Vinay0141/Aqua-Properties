import 'dart:convert';
import 'package:aqua_properties/booking_id.dart';
import 'package:aqua_properties/view_booking_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class UnitDetailScreen extends StatefulWidget {
  final dynamic unitIdName;
  final dynamic unitPrice;
  final dynamic unitTotalArea;
  final dynamic unitProjectId;
  final dynamic unitplanId;
  final dynamic unitpriceUnit;
  final dynamic unitdiscount;
  final dynamic unituserId;
  final dynamic unitflatArea;
  final dynamic unitbuildArea;
  final dynamic unitbalconyArea;
  final dynamic unittowerId;
  final dynamic unitfloorId;
  final dynamic unitfloorTypeId;
  final dynamic unitbedTypeId;
  final dynamic unitviewTypeId;
  final dynamic unitthemeId;
  final dynamic unitId;
  final dynamic unitStatus;

  // Constructor accepting data
  const UnitDetailScreen({
    super.key,
    required this.unitIdName,
    required this.unitPrice,
    required this.unitTotalArea,
    required this.unitProjectId,
    required this.unitplanId,
    required this.unitpriceUnit,
    required this.unitdiscount,
    required this.unituserId,
    required this.unitflatArea,
    required this.unitbuildArea,
    required this.unitbalconyArea,
    required this.unittowerId,
    required this.unitfloorId,
    required this.unitfloorTypeId,
    required this.unitbedTypeId,
    required this.unitviewTypeId,
    required this.unitthemeId,
    required this.unitId,
    required this.unitStatus,
  });

  @override
  State<UnitDetailScreen> createState() => _UnitDetailScreenState();
}

class _UnitDetailScreenState extends State<UnitDetailScreen> {


  // Ye function payment plan fetch karega aur PDF download ka option dega
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






  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Unit View", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  // Buttons on Left
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.unituserId == false) ...[
                        // Offer Button
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _showPaymentPlan(context);
                            });
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
                          child: const Text('Offer',style: TextStyle(color: Colors.white),),
                        ),
                        const SizedBox(height: 2),
                        // Book Button
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _showCustomers(context, widget.unitId.toString());
                            });
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
                          child: const Text('Book',style: TextStyle(color: Colors.white),),
                        ),
                      ] else ...[
                        // View Booking Button
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ViewBookingScreen(
                                  unitId: widget.unitIdName,
                                  status: widget.unitStatus,
                                  userId: widget.unituserId,
                                ),
                              ),
                            );
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
                          child: const Text('View Booking',style: TextStyle(color: Colors.white),),
                        ),
                      ],
                    ],
                  ),
                  const Spacer(),
                  // Camera on Right
                  GestureDetector(
                    onTap: () {
                      // Image upload logic
                    },
                    child: Stack(
                      children: [
                        Container(
                          height: 100,
                          width: 100,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        Positioned(
                          bottom: 5,
                          right: 5,
                          child: CircleAvatar(
                            radius: 15,
                            backgroundColor: Colors.blue,
                            child: const Icon(Icons.add, color: Colors.white, size: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(color: Colors.black),

              // Data Rows
              buildDataRow("ID", widget.unitId.toString()),
              buildDataRow("Unit ID", widget.unitIdName),
              buildDataRow("Project", widget.unitProjectId),
              buildDataRow("Payment Plan", widget.unitplanId.toString()),
              buildDataRow("Price Unit", "\$${widget.unitPrice} (2)%"),
              buildDataRow("Discount (%)", "${widget.unitdiscount} (2)%"),
              buildDataRow("Price", "\$${widget.unitPrice} x 2"),
              buildDataRow("User ID", widget.unituserId.toString()),
              buildDataRow("FlatArea", widget.unitflatArea.toString()),
              buildDataRow("Net Area (Sq.ft)", widget.unitTotalArea),
              buildDataRow("Build Area", widget.unitbuildArea.toString()),
              buildDataRow("BalconyArea", widget.unitbalconyArea.toString()),
              buildDataRow("Total Area", widget.unitTotalArea.toString()),
              buildDataRow("Tower ID", widget.unittowerId.toString()),
              buildDataRow("Floor ID", widget.unitfloorId.toString()),
              buildDataRow("Floor Type ID", widget.unitfloorTypeId.toString()),
              buildDataRow("Bed Type ID", widget.unitbedTypeId.toString()),
              buildDataRow("View Type ID", widget.unitviewTypeId.toString()),
              buildDataRow("Theme ID", widget.unitthemeId.toString()),
              buildDataRow("Status", widget.unitStatus),
              const Divider(),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

// Function to create each row
  Widget buildDataRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13),
              textAlign: TextAlign.end,
              overflow: TextOverflow.visible,
            ),
          ),
        ],
      ),
    );
  }
}
