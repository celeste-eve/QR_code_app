import 'package:flutter/material.dart';
import 'package:qr_code_app/landingpage.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // title: 'QR code app',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 100, 0, 100),
        ),
      ),
      home: Landingpage(),
    );
  }
}

void main() {
  runApp(MyApp());
}
