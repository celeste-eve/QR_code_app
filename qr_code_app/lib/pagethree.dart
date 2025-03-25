import 'package:flutter/material.dart';

class PageThree extends StatefulWidget {
  @override
  _PageThreeState createState() => _PageThreeState();
}

class _PageThreeState extends State<PageThree> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Page Three'),
        backgroundColor: const Color.fromARGB(255, 232, 216, 252),
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('Help!'),
                    content: Text(
                      'Your on the wrong page ',
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
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                'Upload a file to generate a QR code',
                style: TextStyle(fontSize: 30),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                width: 1000,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // Add code here
                  },
                  child: const Text(
                    'Upload file',
                    style: TextStyle(
                      fontSize: 20,
                      color: Color.fromARGB(255, 53, 14, 59),
                    ),
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
