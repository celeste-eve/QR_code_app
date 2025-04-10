import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:qr_code_app/dropdown.dart';

class qrcodes extends StatefulWidget {
  @override
  _qrcodesState createState() => _qrcodesState();
}

String selectedQRCodeType = "Standard one line QR code"; // Default value

class _qrcodesState extends State<qrcodes> {
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
      final directory = await getApplicationDocumentsDirectory();
      final outputPath = '${directory.path}/QRcodes.pdf';

      // Determine the script to execute based on the selected QR code type
      String scriptPath;
      switch (selectedQRCodeType) {
        case "Pallet QR code":
          scriptPath = 'assets\\QR_code_gen.py';
          break;
        case "Racking beam QR code":
          scriptPath = 'assets\\QR_code_Alternative.py';
          break;
        default:
          scriptPath = 'assets\\QR_code_gen.py';
      }

      // Execute the selected Python script with the appropriate arguments
      final result = await Process.run('python', [
        scriptPath, // Use the selected script
        '--data',
        qrCodeEntries.join(','), // Pass all entries as a single string
        '--output',
        outputPath,
      ]);

      if (result.exitCode == 0) {
        setState(() {
          lastGeneratedPdfPath = outputPath;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF saved successfully!'),
            duration: Duration(seconds: 100),
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
        title: Text('Wearhouse QR codes'),
        backgroundColor: const Color.fromARGB(2255, 185, 213, 255),
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('Help'),
                    content: Column(
                      children: [
                        Text(
                          'Enter a location for the QR code and select the type for QR code your making then click the "Add Location" button, once you have added all of the locations you want QR codes for then press "Generate QR code PDF" to generate the file.',
                          style: TextStyle(fontSize: 20),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Example of Pallet QR code',
                                  style: TextStyle(fontSize: 20),
                                ),
                                Image.asset(
                                  'assets/images/StandardQRcode.png',
                                  height: 200,
                                ),
                                Text(
                                  'Example of Racking beam QR code',
                                  style: TextStyle(fontSize: 20),
                                ),
                                Image.asset(
                                  'assets/images/3LineQRcode.png',
                                  height: 200,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
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
      body: Align(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 40.0),
              child: Text(
                'Select QR code type: ',
                style: TextStyle(fontSize: 30),
                textAlign: TextAlign.center,
              ),
            ),
            // type of QR code
            dropdownM(
              onChanged: (String selectedValue) {
                setState(() {
                  selectedQRCodeType =
                      selectedValue; // Update the selected value
                });
              },
            ),
            // enter location bar
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

            Padding(
              // add location button
              padding: const EdgeInsets.all(20.0),
              child: Container(
                width: 550,
                child: ElevatedButton(
                  onPressed: () => addEntry(_textController.text),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text('Add Location', style: TextStyle(fontSize: 20)),
                  ),
                ),
              ),
            ),

            Expanded(
              // list of QR code locations
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

            Padding(
              padding: const EdgeInsets.all(20.0),
              child:
                  isLoading
                      ? CircularProgressIndicator()
                      : Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Container(
                          width: 600,
                          child: Row(
                            // bottom row of buttons
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Container(
                                  width: 200,
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: ElevatedButton(
                                      onPressed: generateQRCodePdf,
                                      child: Text(
                                        'Generate QR code PDF',
                                        style: TextStyle(fontSize: 20),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  width: 200,
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          qrCodeEntries.clear();
                                        });
                                      },
                                      child: Text(
                                        'Clear List',
                                        style: TextStyle(fontSize: 20),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
