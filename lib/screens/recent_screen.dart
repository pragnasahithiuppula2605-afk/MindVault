import 'package:flutter/material.dart';

class RecentScreen extends StatelessWidget {
  const RecentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Recent"),
      ),
      body: const Center(
        child: Text(
          "No Recent Items",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}