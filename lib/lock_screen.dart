import 'package:flutter/material.dart';
class LockScreen extends StatelessWidget {
  const LockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lock Settings'),
      ),
      body: const Center(
        child: Text('Lock Settings Screen'),
      ),
    );
  }
}