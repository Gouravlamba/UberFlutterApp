import 'package:flutter/material.dart';

class EarningsPage extends StatelessWidget {
  static const String id = 'earnings';

  const EarningsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Earnings")),
      body: const Center(
        child: Text("Earnings Page Content", style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
