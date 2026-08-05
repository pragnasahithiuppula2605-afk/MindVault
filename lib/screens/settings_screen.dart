import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';
import '../services/app_lock_service.dart';
import '../services/auth_service.dart';
import 'change_pin_screen.dart';
import 'create_pin_screen.dart';
import 'welcome_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _hasPin = false;

  @override
  void initState() {
    super.initState();
    _checkPin();
  }

  Future<void> _checkPin() async {
    _hasPin = await AppLockService.isEnabled();

    if (mounted) {
      setState(() {});
    }
  }

  Widget _buildTile({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required String title,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        ListTile(
          leading: CircleAvatar(
            radius: 20,
            backgroundColor: color.withValues(alpha: 0.15),
            child: Icon(icon, color: color),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 18,
          ),
          onTap: onTap,
        ),
        const Divider(height: 1),
      ],
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              radius: 35,
              backgroundColor: Colors.deepPurple,
              child: Icon(
                Icons.lock,
                size: 35,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "MindVault",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Your Second Brain",
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "MindVault helps you securely organize Notes, Documents, Media, Links and WhatsApp Chat Archives in one place.",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const Text(
              "Version 1.0.0",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Close"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 12),

          _buildTile(
            context: context,
            icon: _hasPin ? Icons.key : Icons.lock_outline,
            color: Colors.deepPurple,
            title: _hasPin ? "Change PIN" : "Create PIN",
            onTap: () async {
              if (_hasPin) {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ChangePinScreen(),
                  ),
                );
              } else {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CreatePinScreen(),
                  ),
                );
              }

              _checkPin();
            },
          ),

          SwitchListTile(
            secondary: const CircleAvatar(
              radius: 20,
              backgroundColor: Color(0x1F673AB7),
              child: Icon(
                Icons.dark_mode,
                color: Colors.deepPurple,
              ),
            ),
            title: const Text(
              "Dark Mode",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            value: themeProvider.isDarkMode,
            onChanged: (value) {
              themeProvider.toggleTheme(value);
            },
          ),

          const Divider(height: 1),

          _buildTile(
            context: context,
            icon: Icons.favorite,
            color: Colors.pink,
            title: "About MindVault",
            onTap: _showAboutDialog,
          ),

          ListTile(
            leading: const CircleAvatar(
              radius: 20,
              backgroundColor: Color(0x1F673AB7),
              child: Icon(
                Icons.info_outline,
                color: Colors.deepPurple,
              ),
            ),
            title: const Text(
              "Version",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            trailing: const Text(
              "1.0.0",
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const Divider(height: 1),

          _buildTile(
            context: context,
            icon: Icons.logout_rounded,
            color: Colors.red,
            title: "Logout",
            onTap: () async {
              final logout = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Logout"),
                  content: const Text(
                    "Are you sure you want to logout?",
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
                      child: const Text("Logout"),
                    ),
                  ],
                ),
              );

              if (logout == true) {
                await AuthService.logout();

                if (!mounted) return;

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const WelcomeScreen(),
                  ),
                  (route) => false,
                );
              }
            },
          ),

          const Divider(height: 1),
        ],
      ),
    );
  }
}