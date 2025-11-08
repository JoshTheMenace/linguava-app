import 'package:flutter/material.dart';
import 'lesson_intro_screen.dart';
import 'cards_review_screen.dart';

/// Home screen - main entry point for Linguava
class HomeScreen extends StatelessWidget {
  final String apiKey;

  const HomeScreen({
    super.key,
    required this.apiKey,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.deepPurple.shade900,
              Colors.black,
              Colors.deepPurple.shade800,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App branding
                Text(
                  'Linguava',
                  style: TextStyle(
                    color: Colors.purpleAccent.withOpacity(0.9),
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Master Japanese with AI',
                  style: TextStyle(
                    color: Colors.purpleAccent.withOpacity(0.6),
                    fontSize: 16,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 60),

                // Main menu options
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _MenuButton(
                        icon: Icons.chat_bubble_outline,
                        title: 'Start Lesson',
                        subtitle: 'Practice vocabulary with AI tutor',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LessonIntroScreen(apiKey: apiKey),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      _MenuButton(
                        icon: Icons.library_books_outlined,
                        title: 'Review Cards',
                        subtitle: 'View card status and progress',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CardsReviewScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      _MenuButton(
                        icon: Icons.bar_chart_outlined,
                        title: 'Progress',
                        subtitle: 'View your learning stats',
                        onTap: () {
                          // TODO: Navigate to progress screen
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Progress tracking coming soon!'),
                              backgroundColor: Colors.purpleAccent,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // Footer with quick stats (placeholder for now)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.purpleAccent.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatItem(
                        label: 'Words Learned',
                        value: '0',
                      ),
                      Container(
                        width: 1,
                        height: 30,
                        color: Colors.purpleAccent.withOpacity(0.2),
                      ),
                      _StatItem(
                        label: 'Study Streak',
                        value: '0 days',
                      ),
                      Container(
                        width: 1,
                        height: 30,
                        color: Colors.purpleAccent.withOpacity(0.2),
                      ),
                      _StatItem(
                        label: 'Cards Due',
                        value: '0',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Menu button widget
class _MenuButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.purpleAccent.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.purpleAccent.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Colors.purpleAccent,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.purpleAccent.withOpacity(0.5),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

/// Stat item widget
class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.purpleAccent,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
