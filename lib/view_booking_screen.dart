import 'package:flutter/material.dart';

class ViewBookingScreen extends StatelessWidget {
  final String unitId;
  final String status;

  const ViewBookingScreen({super.key, required this.unitId, required this.status});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Booking Details',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18,color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            const Text(
              'Booking Information',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 30),

            // Unit ID Section
            _buildInfoRow('Unit ID', unitId.toString()),
            Divider(thickness: 1, color: Colors.grey.shade300),
            const SizedBox(height: 20),

            // Status Section
            _buildInfoRow('Status', status.toString()),
            Divider(thickness: 1, color: Colors.grey.shade300),
            const SizedBox(height: 30),

            // Additional Space for Better UI Balance
            const Spacer(),
          ],
        ),
      ),
    );
  }

  // Helper method to create rows for the booking info
  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            '$title: ',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }
}
