import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class PageTwo extends StatefulWidget {
  @override
  _PageTwoState createState() => _PageTwoState();
}

class _PageTwoState extends State<PageTwo> {
  final TextEditingController _textController = TextEditingController();
  bool isLoading = false;
  String? lastGeneratedPdfPath;

  Future<void> generateQRCodePdf(String data) async {
    if (data.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a location for the QR code')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Get the Downloads directory to save the PDF
      final directory = await getDownloadsDirectory();
      if (directory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to access Downloads directory')),
        );
        return;
      }
      final sanitizedName = data.replaceAll(RegExp(r'[^\w\s]'), '_').trim();
      final outputPath = '${directory.path}/${sanitizedName}_QRcode.pdf';

      // Execute Python script
      final result = await Process.run('python', [
        'assets\\QR_code_Alternative.py', // path to Python script
        '--data', data,
        '--output', outputPath,
        '--mode',
        'single_pdf',
      ]);

      if (result.exitCode == 0) {
        setState(() {
          lastGeneratedPdfPath = outputPath;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF saved successfully!'),
            duration: Duration(seconds: 20), //duration
            action: SnackBarAction(
              label: 'Open',
              onPressed: () => openFile(outputPath),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating PDF: ${result.stderr}')),
        );
        print('Error: ${result.stderr}');
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Exception: $e')));
      print('Exception: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Open a file using the open_file package
  Future<void> openFile(String path) async {
    try {
      final result = await OpenFile.open(path);
      if (result.type != ResultType.done) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to open file: ${result.message}')),
        );
      }
    } catch (e) {
      print('Error opening file: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error opening file: $e')));
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Page Two'),
        backgroundColor: const Color.fromARGB(255, 232, 216, 252),
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('Help'),
                    content: Text(
                      'Enter a location for the QR code and click the "Generate QR code PDF" button to create a PDF with the QR code. This can be used to create QR codes with 3 lines of text',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Close'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Make a 3 line QR code PDF Example: ',
              style: TextStyle(fontSize: 30),
              textAlign: TextAlign.center,
            ),
            Image.asset('assets/images/3LineQRcode.png', height: 200),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: TextField(
                controller: _textController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Enter QR code location',
                ),
              ),
            ),
            isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                  onPressed: () => generateQRCodePdf(_textController.text),
                  child: Text('Generate QR code PDF'),
                ),
          ],
        ),
      ),
    );
  }
}
