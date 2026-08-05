import 'dart:async';

import 'package:flutter/material.dart';

import 'startup_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Timer(
      const Duration(seconds: 2),
      () {
        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const StartupScreen(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 110,
                  width: 110,
                  decoration: BoxDecoration(
                    color: Colors.deepPurple,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: const Icon(
                    Icons.lock,
                    color: Colors.white,
                    size: 55,
                  ),
                ),

                const SizedBox(height: 30),

                Text(
                  "MindVault",
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  "Your Second Brain",
                  style: TextStyle(
                    fontSize: 18,
                    color: theme.textTheme.bodyMedium?.color
                        ?.withValues(alpha: 0.7),
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  "Store • Search • Remember",
                  style: TextStyle(
                    fontSize: 15,
                    color: theme.textTheme.bodyMedium?.color
                        ?.withValues(alpha: 0.6),
                  ),
                ),

                const SizedBox(height: 50),

                const CircularProgressIndicator(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}