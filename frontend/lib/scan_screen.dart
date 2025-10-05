import 'package:flutter/material.dart';

class ScanScreen extends StatelessWidget {
  const ScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan the Product')),
      body: const Center(
        child: Text('Scanner coming soon.\nUse "Enter GTIN Number Manually" for the demo.',
            textAlign: TextAlign.center),
      ),
    );
  }
}
