import 'package:flutter/material.dart';
import 'package:mindvault/screens/backup_screen.dart';
import 'recycle_bin_screen.dart';
import 'settings_screen.dart';
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(
              Icons.delete,
              color: Colors.red,
            ),
            title: const Text("Recycle Bin"),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const RecycleBinScreen(),
                ),
              );
            },
          ),

          const Divider(),

          ListTile(
            leading: const Icon(
              Icons.backup,
              color: Colors.blue,
            ),
            title: const Text("Backup & Restore"),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const BackupScreen(),
                ),
              );
            },
          ),

          const Divider(),

          ListTile(
            leading: const Icon(
              Icons.settings,
              color: Colors.grey,
            ),
            title: const Text("Settings"),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const SettingsScreen(),
    ),
  );
},
          ),
        ],
      ),
    );
  }
}