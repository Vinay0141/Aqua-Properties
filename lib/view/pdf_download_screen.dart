import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';



class PDFDownloadScreen extends StatefulWidget {
  const PDFDownloadScreen({Key? key}) : super(key: key);

  @override
  State<PDFDownloadScreen> createState() => _PDFDownloadScreenState();
}

class _PDFDownloadScreenState extends State<PDFDownloadScreen> {
  bool isDownloading = false; // For download status
  String downloadMessage = "";
  String pdfUrl = ""; // PDF URL fetched from API

  // Step 1: Fetch PDF URL from API
  Future<void> fetchPDFUrl() async {
    const String apiUrl = "http://www.morningstar.com"; // Replace with real API URL

    try {
      setState(() {
        downloadMessage = "Fetching PDF URL...";
      });

      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        setState(() {
          pdfUrl = response.body; // Assuming API returns the URL directly
          downloadMessage = "PDF URL fetched successfully!";
        });
      } else {
        setState(() {
          downloadMessage = "Failed to fetch PDF URL!";
        });
      }
    } catch (e) {
      setState(() {
        downloadMessage = "Error fetching PDF URL!";
      });
      print(e);
    }
  }

  // Step 2: Download PDF and Save to local storage
  Future<void> downloadPDF(String url) async {
    try {
      setState(() {
        isDownloading = true;
        downloadMessage = "Downloading PDF...";
      });

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final directory = await getApplicationDocumentsDirectory();
        String filePath = "${directory.path}/downloaded_pdf.pdf";

        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        setState(() {
          downloadMessage = "PDF Downloaded Successfully!\nPath: $filePath";
        });

        // Show success notification
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF saved to: $filePath')),
        );
      } else {
        setState(() {
          downloadMessage = "Failed to download PDF!";
        });
      }
    } catch (e) {
      setState(() {
        downloadMessage = "Error downloading PDF!";
      });
      print(e);
    } finally {
      setState(() {
        isDownloading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(' Preview and Download PDF'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Fetch PDF URL Button
            ElevatedButton(
              onPressed: () async {
                await fetchPDFUrl();
              },
              child: const Text("Fetch PDF URL"),
            ),
            const SizedBox(height: 20),

            // Show PDF Preview (Thumbnail) if URL is fetched
            if (pdfUrl.isNotEmpty)
              GestureDetector(
                onTap: () {
                  // Open the PDF in a new screen for preview
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PDFPreviewScreen(pdfUrl: pdfUrl),
                    ),
                  );
                },
                child: Image.network(
                  pdfUrl, // Using the URL as the image source
                  width: 150,
                  height: 150,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 20),

            // Download Button
            ElevatedButton(
              onPressed: (pdfUrl.isNotEmpty && !isDownloading)
                  ? () async {
                await downloadPDF(pdfUrl);
              }
                  : null,
              child: const Text("Download PDF"),
            ),
            const SizedBox(height: 20),

            // Display download message
            if (downloadMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  downloadMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.blueGrey),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// PDF Preview Screen
class PDFPreviewScreen extends StatelessWidget {
  final String pdfUrl;
  const PDFPreviewScreen({required this.pdfUrl, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("PDF Preview")),
      body: Center(
        child: PDFView(
          filePath: pdfUrl, // Show the PDF from URL
        ),
      ),
    );
  }
}
