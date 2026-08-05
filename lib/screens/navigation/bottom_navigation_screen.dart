import 'package:flutter/material.dart';

import '../documents_screen.dart';
import '../home_screen.dart';
import '../links_screen.dart';
import '../media_screen.dart';
import '../notes_screen.dart';
import '../profile_screen.dart';
import '../recent_screen.dart';
import '../search_screen.dart';
import '../whatsapp_screen.dart';

class BottomNavigationScreen extends StatefulWidget {
  const BottomNavigationScreen({super.key});

  @override
  State<BottomNavigationScreen> createState() =>
      _BottomNavigationScreenState();
}

class _BottomNavigationScreenState
    extends State<BottomNavigationScreen> {
  int _currentIndex = 0;

  List<Widget> get _pages => [
      HomeScreen(
        onSearchTap: () {
          setState(() {
            _currentIndex = 1;
          });
        },
      ),
      const SearchScreen(),
      const RecentScreen(),
      const ProfileScreen(),
    ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],

      floatingActionButton: FloatingActionButton(
        backgroundColor:
    Theme.of(context).colorScheme.primary,
        onPressed: _showAddMenu,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),

      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: BottomAppBar(
  color: Theme.of(context).bottomAppBarTheme.color,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: SizedBox(
          height: 65,
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceAround,
            children: [
              _navItem(
                Icons.home,
                "Home",
                0,
              ),
              _navItem(
                Icons.search,
                "Search",
                1,
              ),
              const SizedBox(width: 40),
              _navItem(
                Icons.history,
                "Recent",
                2,
              ),
              _navItem(
                Icons.person,
                "Profile",
                3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(
    IconData icon,
    String label,
    int index,
  ) {
    final selected = _currentIndex == index;

    return InkWell(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: selected
    ? Theme.of(context).colorScheme.primary
    : Theme.of(context).disabledColor,
          ),
          Text(
            label,
            style: TextStyle(
              color: selected
    ? Theme.of(context).colorScheme.primary
    : Theme.of(context).disabledColor,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddMenu() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  "Add to MindVault",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              ListTile(
                leading: const Icon(
                  Icons.description,
                ),
                title: const Text(
                  "Document",
                ),
                onTap: () {
                  Navigator.pop(context);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const DocumentsScreen(
                        autoPick: true,
                      ),
                    ),
                  );
                },
              ),

              ListTile(
                leading: const Icon(
                  Icons.note,
                ),
                title: const Text(
                  "Note",
                ),
                onTap: () {
                  Navigator.pop(context);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const NotesScreen(),
                    ),
                  );
                },
              ),

              ListTile(
                leading: const Icon(
                  Icons.perm_media_outlined,
                ),
                title: const Text(
                  "Media",
                ),
                onTap: () {
                  Navigator.pop(context);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const MediaScreen(),
                    ),
                  );
                },
              ),

              ListTile(
                leading: const Icon(
                  Icons.link,
                ),
                title: const Text(
                  "Save Link",
                ),
                onTap: () {
                  Navigator.pop(context);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const LinksScreen(),
                    ),
                  );
                },
              ),

              ListTile(
                leading: const Icon(
                  Icons.chat,
                ),
                title: const Text(
                  "WhatsApp Chat",
                ),
                onTap: () {
                  Navigator.pop(context);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const WhatsAppScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(
                height: 20,
              ),
            ],
          ),
        );
      },
    );
  }
}