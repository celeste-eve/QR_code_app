import 'package:flutter/material.dart';
import 'package:qr_code_app/qrcodegenerator.dart';

class landingpage extends StatefulWidget {
  const landingpage({super.key});

  @override
  State<landingpage> createState() => _landingpageState();
}

class _landingpageState extends State<landingpage> {
  // this function is called when a button is pressed
  void pressme(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR code app'),
        backgroundColor: const Color.fromARGB(255, 185, 213, 255),
      ),
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: SizedBox(
                width: 1000,
                height: 100,
                child: ElevatedButton(
                  onPressed: () {
                    pressme(qrcodes());
                  },
                  child: Column(
                    children: [
                      Flexible(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(30.0),
                          child: const Text(
                            'Create Wearhouse QR codes ',
                            style: TextStyle(
                              fontSize: 30,
                              color: Color.fromARGB(255, 53, 14, 59),
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
