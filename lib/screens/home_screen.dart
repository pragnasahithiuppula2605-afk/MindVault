import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../widgets/feature_card.dart';
import 'documents_screen.dart';
import 'favorites_screen.dart';
import 'links_screen.dart';
import 'media_screen.dart';
import 'notes_screen.dart';
import 'whatsapp_screen.dart';
class HomeScreen extends StatelessWidget {
  final VoidCallback onSearchTap;

  const HomeScreen({
    super.key,
    required this.onSearchTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "MindVault",
          style: TextStyle(
  color: Theme.of(context).colorScheme.onSurface,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 10),

              Text(
  "Your Second Brain.\nSearch everything you've saved.",
  textAlign: TextAlign.center,
  style: TextStyle(
    fontSize: 14,
    height: 1.5,
    color: Theme.of(context)
        .textTheme
        .bodyMedium
        ?.color
        ?.withValues(alpha: 0.7),
  ),
),

              const SizedBox(height: 20),

              TextField(
  readOnly: true,
  onTap: onSearchTap,
                decoration: InputDecoration(
                  hintText: "Search your vault...",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 25),

              Expanded(
                child: GridView.count(
                  physics: const BouncingScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 18,
                  mainAxisSpacing: 18,
                  childAspectRatio: 1.05,
                  children: [
                    /// Notes
                    FeatureCard(
                      icon: Icons.note_alt_outlined,
                      title: "Notes",
                      subtitle: "Quick Notes",
                      color: AppColors.notes,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const NotesScreen(),
                          ),
                        );
                      },
                    ),

                    /// Documents
                    FeatureCard(
                      icon: Icons.description_outlined,
                      title: "Documents",
                      subtitle: "PDFs & Docs",
                      color: AppColors.documents,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const DocumentsScreen(),
                          ),
                        );
                      },
                    ),

                    /// Media
                    FeatureCard(
                      icon: Icons.perm_media_outlined,
                      title: "Media",
                      subtitle: "Images & Videos",
                      color: AppColors.images,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MediaScreen(),
                          ),
                        );
                      },
                    ),

                    /// WhatsApp
                    FeatureCard(
                      icon: Icons.chat_outlined,
                      title: "WhatsApp",
                      subtitle: "Chat Backup",
                      color: AppColors.whatsapp,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const WhatsAppScreen(),
                          ),
                        );
                      },
                    ),

                    /// Links
                    FeatureCard(
                      icon: Icons.link,
                      title: "Links",
                      subtitle: "Saved Websites",
                      color: AppColors.links,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LinksScreen(),
                          ),
                        );
                      },
                    ),

                    /// Favorites
                    FeatureCard(
                      icon: Icons.star_rounded,
                      title: "Favorites",
                      subtitle: "Starred Items",
                      color: Colors.amber,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const FavoritesScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}