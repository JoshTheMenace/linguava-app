import 'package:flutter/material.dart';

/// Post-lesson summary screen showing results
class LessonSummaryScreen extends StatelessWidget {
  final List<Map<String, dynamic>> wordsLearned;
  final List<Map<String, dynamic>> wordsSkipped;

  const LessonSummaryScreen({
    super.key,
    required this.wordsLearned,
    required this.wordsSkipped,
  });

  @override
  Widget build(BuildContext context) {
    final totalWords = wordsLearned.length + wordsSkipped.length;

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
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(
                      Icons.celebration,
                      color: Colors.purpleAccent,
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Lesson Complete!',
                      style: TextStyle(
                        color: Colors.purpleAccent.withOpacity(0.9),
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Great work practicing Japanese!',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Stats summary
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.purpleAccent.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatColumn(
                        icon: Icons.school,
                        label: 'Practiced',
                        value: wordsLearned.length.toString(),
                        color: Colors.purpleAccent,
                      ),
                      Container(
                        width: 1,
                        height: 50,
                        color: Colors.white.withOpacity(0.1),
                      ),
                      _StatColumn(
                        icon: Icons.check_circle,
                        label: 'Already Known',
                        value: wordsSkipped.length.toString(),
                        color: Colors.greenAccent,
                      ),
                      Container(
                        width: 1,
                        height: 50,
                        color: Colors.white.withOpacity(0.1),
                      ),
                      _StatColumn(
                        icon: Icons.library_books,
                        label: 'Total',
                        value: totalWords.toString(),
                        color: Colors.blueAccent,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Words practiced
              if (wordsLearned.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Words Practiced',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: wordsLearned.length,
                    itemBuilder: (context, index) {
                      final word = wordsLearned[index];
                      return _WordSummaryCard(
                        japanese: word['word'] as String,
                        romaji: word['romaji'] as String,
                        meaning: word['meaning'] as String,
                        status: 'practiced',
                      );
                    },
                  ),
                ),
              ],

              // Words skipped
              if (wordsSkipped.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Already Known',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: wordsSkipped.length,
                    itemBuilder: (context, index) {
                      final word = wordsSkipped[index];
                      return _WordSummaryCard(
                        japanese: word['word'] as String,
                        romaji: word['romaji'] as String,
                        meaning: word['meaning'] as String,
                        status: 'skipped',
                      );
                    },
                  ),
                ),
              ],

              // Bottom buttons
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          // Go back to home screen (pop all until home)
                          Navigator.popUntil(context, (route) => route.isFirst);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purpleAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Back to Home',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: OutlinedButton(
                        onPressed: () {
                          // Pop to home and navigate to cards review
                          Navigator.popUntil(context, (route) => route.isFirst);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.purpleAccent,
                          side: const BorderSide(color: Colors.purpleAccent),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'View All Cards',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
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

/// Stat column widget
class _StatColumn extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatColumn({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 24,
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

/// Word summary card widget
class _WordSummaryCard extends StatelessWidget {
  final String japanese;
  final String romaji;
  final String meaning;
  final String status; // 'practiced' or 'skipped'

  const _WordSummaryCard({
    required this.japanese,
    required this.romaji,
    required this.meaning,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final isPracticed = status == 'practiced';
    final color = isPracticed ? Colors.purpleAccent : Colors.greenAccent;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isPracticed ? Icons.check_circle : Icons.verified,
            color: color,
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  japanese,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$romaji - $meaning',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
