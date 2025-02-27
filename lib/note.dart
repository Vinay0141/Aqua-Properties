//
// // // Area Sq. ft
// // Column(
// //   crossAxisAlignment: CrossAxisAlignment.start,
// //   children: [
// //     const Text(
// //       'Area (Sq. ft)',
// //       style: TextStyle(
// //         fontWeight: FontWeight.bold,
// //         fontSize: 14,
// //         color: Colors.grey,
// //       ),
// //     ),
// //     Text(
// //       '${unitData.totalArea?.toStringAsFixed(2) ?? 'N/A'}',
// //       style: const TextStyle(
// //         fontSize: 16,
// //         fontWeight: FontWeight.w600,
// //       ),
// //     ),
// //   ],
// // ),
//
// // Plan Button
// ElevatedButton(
// onPressed: () {
// _showPaymentPlan(
// context); // Call the function to show the dialog
// },
// style: ElevatedButton.styleFrom(
// backgroundColor: Colors.blueAccent,
// foregroundColor: Colors.white,
// padding: const EdgeInsets.symmetric(
// horizontal: 16,
// vertical: 12,
// ),
// shape: RoundedRectangleBorder(
// borderRadius: BorderRadius.circular(8),
// ),
// ),
// child: const Text('Plan'),
// ),
//
// // Book Button
// ElevatedButton(
// onPressed: () {
// _showCustomers(context);
//
// //Navigator.push(context, MaterialPageRoute(builder: (context) => BookingPage(unitId: unitData.name ?? "N/A"),));
// },
// style: ElevatedButton.styleFrom(
// backgroundColor: Colors.deepPurple,
// foregroundColor: Colors.white,
// padding: const EdgeInsets.symmetric(
// horizontal: 16,
// vertical: 12,
// ),
// shape: RoundedRectangleBorder(
// borderRadius: BorderRadius.circular(8),
// ),
// ),
// child: const Text('Book'),
// ),








//
// // For Book Button pop up
// void _showCustomers(BuildContext context) {
//   String? selectedCustomer;
//   String? selectedPaymentPlan;
//   Map<String, dynamic>? selectedAgency;
//   Map<String, dynamic>? selectedAgent;
//   List<Map<String, dynamic>> customers = [];
//   List<Map<String, dynamic>> agencies = [];
//   List<Map<String, dynamic>> agents = [];
//   List<String> paymentPlans = [];
//   bool isLoading = true;
//   List<Map<String, dynamic>> selectedOtherPartners = [];
//   List<Map<String, dynamic>> filteredAgents = [];  // To store filtered agents
//
//   Future<void> fetchData(Function setState) async {
//     const String apiUrl =
//         "https://beta.aquadev.me/json-call/get_booking_data";
//     const requestPayload = {
//       "login": "britta@aquadevelopments.com",
//       "key":
//       "6660f6b029fcd904123cab668bb057d6d7079b9d2d6b34e8fa86b0107faed247",
//       "db": "beta_Real_18_dec",
//       "id": 1077
//     };
//
//     try {
//       final response = await http.post(
//         Uri.parse(apiUrl),
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode(requestPayload),
//       );
//
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//
//         setState(() {
//           if (data['result'] != null) {
//             customers = List<Map<String, dynamic>>.from(
//                 data['result']['customer'] ?? []);
//             paymentPlans = List<String>.from(
//                 data['result']['plans']?.map((plan) => plan['name']) ?? []);
//             agencies = List<Map<String, dynamic>>.from(
//                 data['result']['agency'] ?? []);
//             agents = List<Map<String, dynamic>>.from(
//                 data['result']['agent'] ?? []);
//           }
//           isLoading = false;
//         });
//       } else {
//         setState(() {
//           isLoading = false;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }
//
//   showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return StatefulBuilder(
//         builder: (context, setState) {
//           if (isLoading) fetchData(setState);
//
//           return AlertDialog(
//             title: const Text(
//               'Booking Customers',
//               style: TextStyle(fontWeight: FontWeight.bold),
//             ),
//             content: SingleChildScrollView(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   if (isLoading)
//                     const Center(child: CircularProgressIndicator())
//                   else if (customers.isEmpty)
//                     const Text('No customers available.')
//                   else ...[
//                       const Text('Choose a customer:'),
//                       DropdownButton<Map<String, dynamic>>(
//                         value: selectedCustomer == null
//                             ? null
//                             : customers.firstWhere(
//                                 (customer) =>
//                             customer['name'] == selectedCustomer,
//                             orElse: () => {}),
//                         hint: const Text("Select a Customer"),
//                         isExpanded: true,
//                         items: customers
//                             .map<DropdownMenuItem<Map<String, dynamic>>>(
//                                 (customer) {
//                               return DropdownMenuItem<Map<String, dynamic>>(
//                                 value: customer,
//                                 child: Text(
//                                   customer['name'] ?? 'No name',
//                                   overflow: TextOverflow.ellipsis,
//                                 ),
//                               );
//                             }).toList(),
//                         onChanged: (value) {
//                           setState(() {
//                             selectedCustomer = value?['name'];
//                           });
//                         },
//                       ),
//                       if (selectedCustomer != null)
//                         Text("Selected Customer: $selectedCustomer"),
//                       const SizedBox(height: 20),
//                       const Text('Payment Plan:'),
//                       paymentPlans.isEmpty
//                           ? const Text("No payment plans available.")
//                           : DropdownButton<String>(
//                         value: selectedPaymentPlan,
//                         hint: const Text("Select a Payment Plan"),
//                         isExpanded: true,
//                         items: paymentPlans
//                             .map<DropdownMenuItem<String>>((plans) {
//                           return DropdownMenuItem<String>(
//                             value: plans,
//                             child: Text(
//                               plans,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           );
//                         }).toList(),
//                         onChanged: (value) {
//                           setState(() {
//                             selectedPaymentPlan = value;
//                           });
//                         },
//                       ),
//                       if (selectedPaymentPlan != null)
//                         Text("Selected Payment Plan: $selectedPaymentPlan"),
//                       const SizedBox(height: 20),
//                       const Text('Agency:'),
//                       agencies.isEmpty
//                           ? const Text("No agencies available.")
//                           : DropdownButton<Map<String, dynamic>>(
//                         value: selectedAgency,
//                         hint: const Text("Select an Agency"),
//                         isExpanded: true,
//                         items: agencies
//                             .map<DropdownMenuItem<Map<String, dynamic>>>(
//                                 (agency) {
//                               return DropdownMenuItem<Map<String, dynamic>>(
//                                 value: agency,
//                                 child: Text(
//                                   agency['name'] ?? 'No name',
//                                   overflow: TextOverflow.ellipsis,
//                                 ),
//                               );
//                             }).toList(),
//                         onChanged: (value) {
//                           setState(() {
//                             selectedAgency = value;
//                             selectedAgent = null; // Reset selected agent
//                             // Filter agents based on selected agency
//                             filteredAgents = agents.where((agent) {
//                               return agent['agency_id'] ==
//                                   selectedAgency?['id'];
//                             }).toList();
//                           });
//                         },
//                       ),
//                       if (selectedAgency != null)
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text("Selected Agency: ${selectedAgency!['name']}"),
//                             if (selectedAgency!['id'] != null)
//                               Text("ID: ${selectedAgency!['id']}"),
//                           ],
//                         ),
//                       const SizedBox(height: 20),
//                       const Text('Agent:'),
//                       filteredAgents.isEmpty
//                           ? const Text("No agents available for the selected agency.")
//                           : DropdownButton<Map<String, dynamic>>(
//                         value: selectedAgent,
//                         hint: const Text("Select an Agent"),
//                         isExpanded: true,
//                         items: filteredAgents
//                             .map<DropdownMenuItem<Map<String, dynamic>>>(
//                                 (agent) {
//                               return DropdownMenuItem<Map<String, dynamic>>(
//                                 value: agent,
//                                 child: Text(
//                                   agent['name'] ?? 'No name',
//                                   overflow: TextOverflow.ellipsis,
//                                 ),
//                               );
//                             }).toList(),
//                         onChanged: (value) {
//                           setState(() {
//                             selectedAgent = value;
//                           });
//                         },
//                       ),
//                       if (selectedAgent != null)
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text("Selected Agent: ${selectedAgent!['name']}"),
//                             if (selectedAgent!['id'] != null)
//                               Text("ID: ${selectedAgent!['id']}"),
//                             if (selectedAgent!['agency_id'] != null)
//                               Text("Agency ID: ${selectedAgent!['agency_id']}"),
//                           ],
//                         ),
//                       const SizedBox(height: 20),
//                       const Text('Other Partners (Multiple Selection):'),
//                       customers.isEmpty
//                           ? const Text("No customers available.")
//                           : Column(
//                         children: [
//                           DropdownButton<Map<String, dynamic>>(
//                             hint: const Text("Select Other Partners"),
//                             isExpanded: true,
//                             items: customers.map<
//                                 DropdownMenuItem<
//                                     Map<String, dynamic>>>((partner) {
//                               return DropdownMenuItem<
//                                   Map<String, dynamic>>(
//                                 value: partner,
//                                 child: Text(
//                                   partner['name'] ?? 'No name',
//                                   overflow: TextOverflow.ellipsis,
//                                 ),
//                               );
//                             }).toList(),
//                             onChanged: (value) {
//                               setState(() {
//                                 if (value != null &&
//                                     !selectedOtherPartners
//                                         .contains(value)) {
//                                   selectedOtherPartners.add(value);
//                                 }
//                               });
//                             },
//                           ),
//                           Wrap(
//                             spacing: 8.0,
//                             children: selectedOtherPartners
//                                 .map((partner) => Chip(
//                               label: Text(partner['name'] ?? ''),
//                               onDeleted: () {
//                                 setState(() {
//                                   selectedOtherPartners.remove(partner);
//                                 });
//                               },
//                             ))
//                                 .toList(),
//                           ),
//                         ],
//                       ),
//                     ],
//                 ],
//               ),
//             ),
//             actions: [
//               ElevatedButton(
//                 onPressed: () {
//                   Navigator.pop(context);
//                 },
//                 child: const Text('Cancel'),
//               ),
//               ElevatedButton(
//                 onPressed: () {
//                   Navigator.pop(context);
//                   // Handle form submission
//                 },
//                 child: const Text('Submit'),
//               ),
//             ],
//           );
//         },
//       );
//     },
//   );
// }


