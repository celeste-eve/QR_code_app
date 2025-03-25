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

  Future<void> generateQRCodePdf() async {
    if (qrCodeEntries.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please add at least one location')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Change the save location here
      final directory =
          await getApplicationDocumentsDirectory(); // Use Documents directory
      final outputPath = '${directory.path}/Multiple_QRcodes1.pdf';

      // Execute Python script
      final result = await Process.run('python', [
        'assets\\QR_code_Alternative.py', // path to Python script
        '--data',
        qrCodeEntries.join(','), // Pass all entries as a single string
        '--output',
        outputPath,
        '--mode',
        'pdf', // Changed from 'multiple_pdf' to 'pdf'
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
          SnackBar(
            content: Text('Error generating PDF: ${result.stderr}'),
            duration: Duration(seconds: 100),
          ),
        );
        print('Error: ${result.stderr}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Exception: $e'),
          duration: Duration(seconds: 100),
        ),
      );
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
      if (result.type == ResultType.done) {
        setState(() {
          qrCodeEntries
              .clear(); // Clear the memory after successfully opening the file
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('File opened successfully!'),
            duration: Duration(seconds: 20),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to open file: ${result.message}'),
            duration: Duration(seconds: 20),
          ),
        );
      }
    } catch (e) {
      print('Error opening file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error opening file: $e'),
          duration: Duration(seconds: 20),
        ),
      );
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
                      style: TextStyle(fontSize: 20),
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
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                'Make Racking Beam QR code PDF Example: ',
                style: TextStyle(fontSize: 30),
                textAlign: TextAlign.center,
              ),
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
                    onPressed: generateQRCodePdf,
                    child: Text(
                      'Generate QR code PDF',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
