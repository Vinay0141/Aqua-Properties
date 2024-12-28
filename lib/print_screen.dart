import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class PdfDownloader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PDF Downloader'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await fetchAndDownloadPdf();
          },
          child: Text('Download PDF'),
        ),
      ),
    );
  }

  Future<void> fetchAndDownloadPdf() async {
    final String apiUrl = 'https://aquadev.me/json-call/get_unit_paymentplan_pdf';
    final Map<String, dynamic> requestBody = {
      "login": "app_user@akili.com",
      "key": "feaf757e3f5bfa31e39afaf072db4ff488f9f3c4319e2e7104e136de0b4dc002",
      "db": "New_Real_Estate",
      "password": "admin_123",
      "unit_id": 1077,
      "id": 1718
    };

    try {
      // Make the API call
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      // Print the response body for debugging
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        // Assuming the response contains a URL to the PDF
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        // Print the parsed response data
        print('Parsed response data: $responseData');

        // Check if the pdf_url key exists in the response
        if (responseData.containsKey('pdf_url')) {
          final pdfUrl = responseData['pdf_url'];
          // Ensure pdfUrl is a String
          if (pdfUrl is String) {
            // Download the PDF
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

  Future<void> downloadPdf(String url) async {
    try {
      // Make a GET request to download the PDF
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // Get the directory to save the PDF
        Directory appDocDir = await getApplicationDocumentsDirectory();
        String savePath = '${appDocDir.path}/downloaded_file.pdf';

        // Write the PDF file
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