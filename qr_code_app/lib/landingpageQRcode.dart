import 'package:flutter/material.dart';
import 'package:qr_code_app/pageone.dart';
import 'package:qr_code_app/pagetwo.dart';
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
                height: 250,
                child: ElevatedButton(
                  onPressed: () {
                    pressme(PageOne());
                  },
                  child: Column(
                    children: [
                      const Text(
                        'Generate standard 1 or 2 line QR code',
                        style: TextStyle(
                          fontSize: 20,
                          color: Color.fromARGB(255, 53, 14, 59),
                        ),
                      ),
                      Container(
                        color: Color.fromARGB(255, 53, 14, 59),
                        child: Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Image.asset(
                            'assets/images/StandardQRcode.png',
                            height: 200,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: SizedBox(
                width: 1000,
                height: 250,
                child: ElevatedButton(
                  onPressed: () {
                    pressme(PageTwo());
                  },
                  child: Column(
                    children: [
                      const Text(
                        'Generate multi line QR codes for RACKING BEAMS',
                        style: TextStyle(
                          fontSize: 20,
                          color: Color.fromARGB(255, 53, 14, 59),
                        ),
                      ),
                      Container(
                        color: Color.fromARGB(255, 53, 14, 59),
                        child: Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Image.asset(
                            'assets/images/StandardQRcode.png',
                            height: 200,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: SizedBox(
                width: 1000,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    pressme(qrcodes());
                  },
                  child: Column(
                    children: [
                      const Text(
                        'UNDER CONSTRUCTION',
                        style: TextStyle(
                          fontSize: 20,
                          color: Color.fromARGB(255, 53, 14, 59),
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
