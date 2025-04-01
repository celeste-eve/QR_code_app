import 'package:flutter/material.dart';
import 'package:qr_code_app/landingpageQRcode.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // title: 'QR code app',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Color.fromARGB(255, 255, 255, 255),
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 185, 213, 255),
        ),
      ),
      home: landingpage(),
    );
  }
}

void main() {
  runApp(MyApp());
}
