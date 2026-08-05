import 'package:flutter/material.dart';

class PinScreenLayout extends StatelessWidget {
  final String appBarTitle;
  final String title;
  final String subtitle;
  final Widget indicator;
  final Widget keyboard;
  final Widget? bottomWidget;

  const PinScreenLayout({
    super.key,
    required this.appBarTitle,
    required this.title,
    required this.subtitle,
    required this.indicator,
    required this.keyboard,
    this.bottomWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text(appBarTitle),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),

              const Icon(
                Icons.lock,
                size: 80,
                color: Colors.deepPurple,
              ),

              const SizedBox(height: 20),

              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 40),

              indicator,

              const Spacer(),

              keyboard,

              if (bottomWidget != null) ...[
                const SizedBox(height: 20),
                bottomWidget!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}