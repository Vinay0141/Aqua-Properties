import 'package:flutter/material.dart';

class BookingInProgressScreen extends StatelessWidget {
  final String message;
  final bool isAlreadyBooked;

  BookingInProgressScreen({required this.message, required this.isAlreadyBooked});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.7), // Darker transparent background for better focus
      body: Center(
        child: Card(
          color: Colors.white,
          elevation: 12, // Slightly higher elevation for a more prominent look
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15), // Rounded corners for a modern look
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue), // Blue color for progress indicator
                ),
                const SizedBox(height: 20),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Please wait...',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BookingScreen extends StatefulWidget {
  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  bool isSubmitting = false; // Booking submit status
  bool isAlreadyBooked = false; // Check if the booking is already done

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Screen'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            setState(() {
              isSubmitting = true; // Booking submit ho raha hai
              if (isAlreadyBooked) {
                // Booking already ho gayi hai toh screen ko close karna hai
                Navigator.of(context).pop(); // Pop the current screen
                print("Booking already done!"); // Debugging log to check pop call
              } else {
                // Booking process continue
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookingInProgressScreen(
                      message: "Booking in progress",
                      isAlreadyBooked: isAlreadyBooked, // Pass the status
                    ),
                  ),
                );
              }
            });
          },
          child: const Text('Submit Booking'),
        ),
      ),
    );
  }
}
