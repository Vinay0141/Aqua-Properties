import 'package:aqua_properties/features/nav_bar/nav_screen.dart';
import 'package:flutter/material.dart';

class BookingId extends StatefulWidget {
  final String bookingId;
  final String status;

  const BookingId({super.key, required this.bookingId, required this.status});

  @override
  State<BookingId> createState() => _BookingIdState();
}

class _BookingIdState extends State<BookingId> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false,
        title: const Text("Booking Details"),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ✅ Success or Pending Icon
            const Icon(
              Icons.check_circle,
              size: 80.0,
              color: Colors.green,
            ),
            const SizedBox(height: 20),

            // ✅ Booking Details Card
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow("Booking ID:", widget.bookingId, Colors.blue),
                    const Divider(),
                    _buildDetailRow("Status:", widget.status, Colors.green),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            // ✅ Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildActionButton("Back", Icons.arrow_back, Colors.blue, () {
                  // 🛑 Yahan pe Navigator.pop() ki jagah direct Bottom Navigation Screen par bhej raha hoon
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const DashboardScreen(initialIndex: 1)), // Apni Bottom Navigation wali screen ka naam yaha do
                        (route) => false, // Previous screens hata dega
                  );
                }),
                const SizedBox(width: 10),
                _buildActionButton("Share", Icons.share, Colors.green, () {
                  // Future functionality: Share Booking ID
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Helper Function for Detail Row
  Widget _buildDetailRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }

  // ✅ Helper Function for Buttons
  Widget _buildActionButton(String text, IconData icon, Color color, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 20, color: Colors.white),
      label: Text(text, style: const TextStyle(fontSize: 16, color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
