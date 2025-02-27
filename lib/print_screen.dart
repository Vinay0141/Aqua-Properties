import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PdfDownloader extends StatelessWidget {
  const PdfDownloader({super.key});
  // Define variables for API details and request body
  final String apiUrl = 'https://beta.aquadev.me/json-call/get_unit_paymentplan_pdf';
  final String apiKey = "6660f6b029fcd904123cab668bb057d6d7079b9d2d6b34e8fa86b0107faed247"; // Renamed from 'key' to 'apiKey'
  final String db = "beta_Real_18_dec";
  final int unitId = 886;
  final int id = 1718;



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Downloader'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await fetchAndDownloadPdf();
          },
          child: const Text('Download PDF'),
        ),
      ),
    );
  }

  // Function to fetch and download PDF
  Future<void> fetchAndDownloadPdf() async {
    // Retrieve the token from SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? authToken = prefs.getString('authToken'); // Get the stored token
    String? email = prefs.getString('email');

    if (authToken == null) {
      print('Token not found, please login');
      return; // Exit if token is not found
    }

    // Prepare the request body dynamically with the token
    final Map<String, dynamic> requestBody = {
      "login": email,
      "key": apiKey, // Use 'apiKey' here
      "db": db,
      "unit_id": unitId,
      "id": id,
      "token": authToken, // Include the token in the request body
    };

    try {
      // Make the API call
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        // Check if the response contains a 'pdf_url'
        if (responseData.containsKey('pdf_url')) {
          final pdfUrl = responseData['pdf_url'];
          if (pdfUrl is String) {
            await downloadPdf(pdfUrl);
          } else {
            print('Error: pdf_url is not a String');
          }
        } else {
          print('Error: pdf_url key not found in response');
        }
      } else {
        print('Failed to fetch data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  // Function to download the PDF
  Future<void> downloadPdf(String url) async {
    try {
      // Download the PDF
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // Save the PDF in the app's documents directory
        Directory appDocDir = await getApplicationDocumentsDirectory();
        String savePath = '${appDocDir.path}/downloaded_file.pdf';

        File file = File(savePath);
        await file.writeAsBytes(response.bodyBytes);
        print('PDF downloaded to: $savePath');
      } else {
        print('Failed to download PDF: ${response.statusCode}');
      }
    } catch (e) {
      print('Download error: $e');
    }
  }
}
