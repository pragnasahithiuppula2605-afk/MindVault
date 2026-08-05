import 'package:flutter/material.dart';

import '../services/app_lock_service.dart';
import '../services/auth_service.dart';
import 'create_pin_screen.dart';
import 'lock_screen.dart';
import 'onboarding_screen.dart';
import 'welcome_screen.dart';

class StartupScreen extends StatefulWidget {
  const StartupScreen({super.key});

  @override
  State<StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends State<StartupScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkStartup();
    });
  }

  Future<void> _checkStartup() async {
    // Show onboarding only once
    final completedOnboarding =
        await AuthService.hasCompletedOnboarding();

    if (!mounted) return;

    if (!completedOnboarding) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const OnboardingScreen(),
        ),
      );
      return;
    }

    // Check account
    final hasAccount = await AuthService.hasAccount();

    if (!mounted) return;

    if (!hasAccount) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const WelcomeScreen(),
        ),
      );
      return;
    }

    // Check login session
    final loggedIn = await AuthService.isLoggedIn();

    if (!mounted) return;

    if (!loggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const WelcomeScreen(),
        ),
      );
      return;
    }

    // Check PIN
    final pinEnabled = await AppLockService.isEnabled();

    if (!mounted) return;

    if (!pinEnabled) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const CreatePinScreen(),
        ),
      );
      return;
    }

    // Go to Lock Screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const LockScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}