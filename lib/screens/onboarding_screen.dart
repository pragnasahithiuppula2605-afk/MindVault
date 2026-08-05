import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'welcome_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() =>
      _OnboardingScreenState();
}

class _OnboardingScreenState
    extends State<OnboardingScreen> {
  final PageController _controller = PageController();

  int _currentPage = 0;

  final List<_OnboardData> _pages = [
    _OnboardData(
      icon: Icons.psychology_rounded,
      title: "Welcome to MindVault",
      description:
          "Your Second Brain.\nStore everything important in one secure place.",
      color: Colors.deepPurple,
    ),
    _OnboardData(
      icon: Icons.lock_rounded,
      title: "Private & Secure",
      description:
          "Protect your Notes, Documents, Media, Links and WhatsApp archives with your personal PIN.",
      color: Colors.green,
    ),
    _OnboardData(
      icon: Icons.search_rounded,
      title: "Find Everything",
      description:
          "Powerful search helps you instantly find anything you've saved.",
      color: Colors.orange,
    ),
  ];

  Future<void> _nextPage() async {
    if (_currentPage == _pages.length - 1) {
      await AuthService.completeOnboarding();

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const WelcomeScreen(),
        ),
      );
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _skip() async {
    await AuthService.completeOnboarding();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const WelcomeScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _skip,
                child: const Text("Skip"),
              ),
            ),

            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final page = _pages[index];

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                    ),
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 70,
                          backgroundColor:
                              page.color.withValues(
                            alpha: 0.12,
                          ),
                          child: Icon(
                            page.icon,
                            size: 75,
                            color: page.color,
                          ),
                        ),

                        const SizedBox(height: 45),

                        Text(
                          page.title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight:
                                FontWeight.bold,
                            color: theme
                                .colorScheme.onSurface,
                          ),
                        ),

                        const SizedBox(height: 20),

                        Text(
                          page.description,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 17,
                            height: 1.6,
                            color: theme
                                .textTheme.bodyMedium?.color
                                ?.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            Row(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => AnimatedContainer(
                  duration: const Duration(
                    milliseconds: 250,
                  ),
                  margin:
                      const EdgeInsets.symmetric(
                    horizontal: 4,
                  ),
                  height: 10,
                  width:
                      _currentPage == index ? 28 : 10,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? Colors.deepPurple
                        : Colors.grey.shade400,
                    borderRadius:
                        BorderRadius.circular(20),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 35),

            Padding(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 24,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: FilledButton(
                  onPressed: _nextPage,
                  child: Text(
                    _currentPage ==
                            _pages.length - 1
                        ? "Get Started"
                        : "Next",
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class _OnboardData {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  _OnboardData({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}