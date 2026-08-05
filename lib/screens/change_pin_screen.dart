import 'package:flutter/material.dart';

import '../services/app_lock_service.dart';
import '../widgets/pin_indicator.dart';
import '../widgets/pin_keyboard.dart';

class ChangePinScreen extends StatefulWidget {
  const ChangePinScreen({super.key});

  @override
  State<ChangePinScreen> createState() =>
      _ChangePinScreenState();
}

class _ChangePinScreenState extends State<ChangePinScreen> {
  String _pin = "";
  String? _firstPin;
  bool _isConfirming = false;

  Future<void> _onKeyPressed(String value) async {
    if (_pin.length >= 6) return;

    setState(() {
      _pin += value;
    });

    if (_pin.length == 6) {
      Future.delayed(const Duration(milliseconds: 250), () async {
        if (!_isConfirming) {
          setState(() {
            _firstPin = _pin;
            _pin = "";
            _isConfirming = true;
          });

          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Confirm your new PIN"),
            ),
          );
        } else {
          if (_pin == _firstPin) {
            await AppLockService.savePin(_pin);

            if (!mounted) return;

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("PIN Changed Successfully"),
              ),
            );

            Navigator.pop(context, true);
          } else {
            if (!mounted) return;

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("PINs do not match. Try again."),
              ),
            );

            setState(() {
              _pin = "";
              _firstPin = null;
              _isConfirming = false;
            });
          }
        }
      });
    }
  }

  void _delete() {
    if (_pin.isEmpty) return;

    setState(() {
      _pin = _pin.substring(0, _pin.length - 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final String title = _isConfirming
        ? "Confirm your new 6-digit PIN"
        : "Change your 6-digit PIN";

    const String subtitleConfirm =
        "Enter the same PIN again.";

    const String subtitleCreate =
        "Choose a new PIN for MindVault.";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Change PIN"),
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
                _isConfirming
                    ? subtitleConfirm
                    : subtitleCreate,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 30),

              PinIndicator(
                length: 6,
                filled: _pin.length,
              ),

              const Spacer(),

              PinKeyboard(
                onPressed: _onKeyPressed,
                onDelete: _delete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}