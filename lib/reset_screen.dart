import 'package:flutter/material.dart';
class ResetScreen extends StatelessWidget {
  const ResetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset All Settings'),
      ),
      body: const Center(
        child: Text('Reset All Settings Screen'),
      ),
    );
  }
}