import 'package:flutter/material.dart';
import '../services/app_lock_service.dart';
import 'create_pin_screen.dart';
import 'navigation/bottom_navigation_screen.dart';
import '../widgets/pin_indicator.dart';
import '../widgets/pin_keyboard.dart';
class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  String _enteredPin = "";


  @override
  void initState() {
    super.initState();
    _loadPin();
  }

  Future<void> _loadPin() async {}

  Future<void> _onKeyPressed(String value) async {
    if (_enteredPin.length >= 6) return;

    setState(() {
      _enteredPin += value;
    });

    if (_enteredPin.length == 6) {
      Future.delayed(const Duration(milliseconds: 200), () async {
        final isCorrect =
          await AppLockService.verifyPin(_enteredPin);

if (isCorrect) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const BottomNavigationScreen(),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Incorrect PIN"),
            ),
          );

          setState(() {
            _enteredPin = "";
          });
        }
      });
    }
  }

  Future<void> _forgotPin() async {
  final reset = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text(
        "Reset MindVault?",
      ),
      content: const Text(
        "Creating a new PIN will permanently delete all data stored in MindVault and reset the app.\n\nThis action cannot be undone.",
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text("Cancel"),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Colors.red,
          ),
          onPressed: () => Navigator.pop(context, true),
          child: const Text("Reset MindVault"),
        ),
      ],
    ),
  );

  if (reset == true && mounted) {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CreatePinScreen(
          isReset: true,
        ),
      ),
    );

    await _loadPin();

    setState(() {
      _enteredPin = "";
    });
  }
}

  void _delete() {
    if (_enteredPin.isEmpty) return;

    setState(() {
      _enteredPin =
          _enteredPin.substring(0, _enteredPin.length - 1);
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Unlock MindVault"),
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

              const Text(
                "Enter your PIN",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 40),

              PinIndicator(
  length: 6,
  filled: _enteredPin.length,
),

              const Spacer(),

            PinKeyboard(
  onPressed: _onKeyPressed,
  onDelete: _delete,
),  

              const SizedBox(height: 20),

              TextButton(
                onPressed: _forgotPin,
                child: const Text(
                  "Forgot PIN?",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}