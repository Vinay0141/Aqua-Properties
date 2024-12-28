import 'package:flutter/material.dart';

class BookingScreen extends StatelessWidget {
  final List<Map<String, String>> bookings = [
    {"id": "001", "status": "Pending", "date": "16-Dec-2024"},
    {"id": "002", "status": "Confirmed", "date": "17-Dec-2024"},
    {"id": "003", "status": "Cancelled", "date": "18-Dec-2024"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Booking Details"),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: bookings.length,
          itemBuilder: (context, index) {
            final booking = bookings[index];
            return Card(
              elevation: 3,
              margin: EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                leading: Icon(Icons.bookmark, color: Colors.blue),
                title: Text(
                  "Booking ID: ${booking['id']}",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text("Date: ${booking['date']}"),
                trailing: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(booking['status']!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    booking['status']!,
                    style: TextStyle(color: Colors.white,),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case "Pending":
        return Colors.orange;
      case "Confirmed":
        return Colors.green;
      case "Cancelled":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
