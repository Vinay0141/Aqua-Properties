import 'package:aqua_properties/features/nav_view/unite/unite_screen.dart';
import 'package:aqua_properties/view_booking_screen.dart';
import 'package:flutter/material.dart';

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Unit Details"),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt),
            onPressed: () {
              // Image upload logic
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // Conditional Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Agar unituserId == false hai toh Plan aur Book Button dikhao
                if (widget.unituserId == false) ...[
                  // Plan Button
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UniteScreen(
                            selectPlan: widget.unitIdName,
                          ),
                        ),
                      );
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookingPage(
                            unitId: widget.unitIdName,
                          ),
                        ),
                      );
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
                ] else ...[
                  // Agar unituserId mein false nahi hai toh sirf View Booking Button dikhao
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
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('View Booking'),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 5),
            const Divider(color: Colors.black),

            //  ID
            Row(
              children: [
                const Text(
                  "ID",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  widget.unitId.toString(), // Default value, update as needed
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
            Row(
              children: [
                const Text(
                  "Unit ID",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  "${widget.unitIdName}",
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),

            // Project & Address
            Row(
              children: [
                const Text(
                  "Project",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  "${widget.unitProjectId}",
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 10),



            // Payment Plan, Unit Price, and Discount
            Row(
              children: [
                const Text(
                  "Payment Plan",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(maxLines: 2,
                  widget.unitplanId.toString(), // Default value, update as needed
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Text(
                  "Price Unit",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  "\$${widget.unitPrice} (2)%", // Assuming 2% discount
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Text(
                  "Discount (%)",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  "${widget.unitdiscount} (2)%",
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),

            // Total Price
            Row(
              children: [
                const Text(
                  "Price",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  "\$${widget.unitPrice} x 2", // Assuming price * 2 for total
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                const Text(
                  "User ID",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  widget.unituserId.toString(), // Default value, update as needed
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
            Row(
              children: [
                const Text(
                  "FlatArea",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  widget.unitflatArea.toString(), // Default value, update as needed
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
            Row(
              children: [
                const Text(
                  "Net Area (Sq.ft)",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  " ${widget.unitTotalArea}",
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Text(
                  "Build Area",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  widget.unitbuildArea.toString(), // Default value, update as needed
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
            Row(
              children: [
                const Text(
                  "BalconyArea",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  widget.unitbalconyArea.toString(), // Default value, update as needed
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
            Row(
              children: [
                const Text(
                  "Total Area",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  widget.unitTotalArea.toString(), // Default value, update as needed
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
            Row(
              children: [
                const Text(
                  "Tower ID",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  widget.unittowerId.toString(), // Default value, update as needed
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
            Row(
              children: [
                const Text(
                  "Floor ID",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  widget.unitfloorId.toString(), // Default value, update as needed
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ), Row(
              children: [
                const Text(
                  "Floor Type ID",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  widget.unitfloorTypeId.toString(), // Default value, update as needed
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
            Row(
              children: [
                const Text(
                  "Bed Type ID",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  widget.unitbedTypeId.toString(), // Default value, update as needed
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
            Row(
              children: [
                const Text(
                  "View Type ID",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  widget.unitviewTypeId.toString(), // Default value, update as needed
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),

            Row(
              children: [
                const Text(
                  "Theme ID",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  widget.unitthemeId.toString(), // Default value, update as needed
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),

            Row(
              children: [
                const Text(
                  "Status",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  widget.unitStatus, // Default value, update as needed
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
