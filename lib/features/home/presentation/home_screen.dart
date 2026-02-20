import 'package:flutter/material.dart';

/// Home screen ? entry point for the app.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ReMem'),
      ),
      body: const Center(
        child: Text('Welcome to ReMem ? your language learning companion.'),
      ),
    );
  }
}
