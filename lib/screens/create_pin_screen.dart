import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../services/app_lock_service.dart';
import '../widgets/pin_indicator.dart';
import '../widgets/pin_keyboard.dart';
import 'navigation/bottom_navigation_screen.dart';

class CreatePinScreen extends StatefulWidget {
  final bool isReset;

  const CreatePinScreen({
    super.key,
    this.isReset = false,
  });

  @override
  State<CreatePinScreen> createState() => _CreatePinScreenState();
}

class _CreatePinScreenState extends State<CreatePinScreen> {
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
            SnackBar(
              content: Text(
                widget.isReset
                    ? "Confirm your new PIN"
                    : "Confirm your PIN",
              ),
            ),
          );
        } else {
          if (_pin == _firstPin) {
            if (widget.isReset) {
              await DatabaseHelper.instance.deleteDatabaseFile();
            }

            await AppLockService.savePin(_pin);

            if (!mounted) return;

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  widget.isReset
                      ? "PIN Updated Successfully"
                      : "PIN Created Successfully",
                ),
              ),
            );

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const BottomNavigationScreen(),
              ),
            );
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
        ? (widget.isReset
            ? "Confirm your new 6-digit PIN"
            : "Confirm your 6-digit PIN")
        : (widget.isReset
            ? "Create a new 6-digit PIN"
            : "Create a 6-digit PIN");

    final String subtitle = _isConfirming
        ? "Enter the same PIN again."
        : widget.isReset
            ? "This PIN will replace your existing PIN."
            : "This PIN will protect your MindVault.";

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isReset ? "Reset PIN" : "Create PIN",
        ),
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