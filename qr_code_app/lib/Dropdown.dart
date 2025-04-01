import 'package:flutter/material.dart';

class QRcodetype {
  QRcodetype(this.name);
  final String name;
}

class dropdownM extends StatefulWidget {
  const dropdownM({super.key, required this.onChanged});

  final Function(String) onChanged;

  @override
  State<dropdownM> createState() => _dropdownMState();
}

class _dropdownMState extends State<dropdownM> {
  final List<QRcodetype> items = [
    QRcodetype("Standard one line QR code"),
    QRcodetype("Pallet QR code"),
    QRcodetype("Racking beam QR code"),
  ];

  late QRcodetype currentChoice;

  @override
  void initState() {
    currentChoice = items[0];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      //select QR code type
      padding: const EdgeInsets.all(30),
      child: DropdownButton<String>(
        isExpanded: true,
        value: currentChoice.name,
        items:
            items
                .map<DropdownMenuItem<String>>(
                  (QRcodetype item) => DropdownMenuItem<String>(
                    value: item.name,
                    child: Center(child: Text(item.name)),
                  ),
                )
                .toList(),
        onChanged: (String? value) {
          if (value != null) {
            setState(() {
              currentChoice = items.firstWhere((item) => item.name == value);
              widget.onChanged(value); // Notify the parent widget
            });
          }
        },
      ),
    );
  }
}
