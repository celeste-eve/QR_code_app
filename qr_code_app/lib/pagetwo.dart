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
  List<String> qrCodeEntries = []; // List to store multiple QR code data

  void addEntry(String data) {
    if (data.isNotEmpty) {
      setState(() {
        qrCodeEntries.add(data);
      });
      _textController.clear();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please enter a valid location')));
    }
  }

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

      final outputPath = '${directory.path}/Multiple_QRcodes.pdf';

      // Execute Python script
      final result = await Process.run('python', [
        'assets\\QR_code_Alternative.py', // path to Python script
        '--data',
        qrCodeEntries.join(','), // Pass all entries as a single string
        '--output',
        outputPath,
        '--mode',
        'multiple_pdf',
      ]);

      if (result.exitCode == 0) {
        setState(() {
          lastGeneratedPdfPath = outputPath;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF saved successfully!'),
            duration: Duration(seconds: 100), //duration
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
                      'Enter a location for the QR code and click the "Add Location" button, once you have added all of the locations you want QR codes for then press "Generate QR code PDF" to generate the file.  This can be used to create QR codes with 3 lines of text',
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
            ElevatedButton(
              onPressed: () => addEntry(_textController.text),
              child: Text('Add Location'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: qrCodeEntries.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(qrCodeEntries[index]),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          qrCodeEntries.removeAt(index);
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            isLoading
                ? CircularProgressIndicator()
                : Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: ElevatedButton(
                    onPressed: () => generateQRCodePdf(_textController.text),
                    child: Text('Generate QR code PDF'),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
