import 'package:flutter/material.dart';
import 'package:qr_code_app/pageone.dart';
import 'package:qr_code_app/pagetwo.dart';

class Landingpage extends StatefulWidget {
  const Landingpage({super.key});

  @override
  State<Landingpage> createState() => _LandingPageState();
}

class _LandingPageState extends State<Landingpage> {
  // this function is called when a button is pressed
  void pressme(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QR code app')),
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: 1000,
                height: 100,
                child: ElevatedButton(
                  onPressed: () {
                    pressme(PageOne());
                  },
                  child: const Text(
                    'Generate standard 2 line QR code',
                    style: TextStyle(
                      fontSize: 20,
                      color: Color.fromARGB(255, 53, 14, 59),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: 1000,
                height: 100,
                child: ElevatedButton(
                  onPressed: () {
                    pressme(PageTwo());
                  },
                  child: const Text(
                    'Generate multi line QR code',
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
