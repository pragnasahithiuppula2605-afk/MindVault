import 'package:flutter/material.dart';
import 'package:mindvault/repositories/backup_repository.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  final BackupRepository backupRepository = BackupRepository();

  String lastBackup = "Never";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Backup & Restore"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            "Keep your MindVault data safe by creating backups or restoring previous backups.",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 24),

          Card(
            child: ListTile(
              leading: const Icon(Icons.backup, color: Colors.blue, size: 32),
              title: const Text("Create Backup"),
              subtitle: const Text(
                "Create a backup of all your MindVault data.",
              ),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () async {
                final file = await backupRepository.createBackup();

                if (!mounted) return;

                if (file != null) {
                  setState(() {
                    lastBackup = DateTime.now().toString().substring(0, 19);
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Backup created successfully\n${file.path}",
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Failed to create backup."),
                    ),
                  );
                }
              },
            ),
          ),

          const SizedBox(height: 16),

          Card(
            child: ListTile(
              leading: const Icon(Icons.restore, color: Colors.green, size: 32),
              title: const Text("Restore Backup"),
              subtitle: const Text("Restore data from a backup file."),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () async {
                final restored = await backupRepository.restoreBackup();

                if (!mounted) return;

                if (restored) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Backup restored successfully.\nRestart the app.",
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Restore cancelled or failed."),
                    ),
                  );
                }
              },
            ),
          ),

          const SizedBox(height: 16),

          Card(
            child: ListTile(
              leading: const Icon(Icons.history, color: Colors.orange),
              title: const Text("Last Backup"),
              subtitle: Text(lastBackup),
            ),
          ),
        ],
      ),
    );
  }
}