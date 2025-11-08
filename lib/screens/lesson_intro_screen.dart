import 'package:flutter/material.dart';
import 'package:fsrs/fsrs.dart' hide State;
import '../hud_screen.dart';
import '../services/fsrs_service.dart';
import '../repositories/vocabulary_repository.dart';
import 'lesson_summary_screen.dart';

/// Pre-lesson screen showing words to be learned
class LessonIntroScreen extends StatefulWidget {
  final String apiKey;

  const LessonIntroScreen({
    super.key,
    required this.apiKey,
  });

  @override
  State<LessonIntroScreen> createState() => _LessonIntroScreenState();
}

class _LessonIntroScreenState extends State<LessonIntroScreen> {
  late FSRSService _fsrsService;
  late VocabularyRepository _vocabularyRepo;
  List<Map<String, dynamic>> _lessonWords = [];
  Set<String> _skippedWords = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLessonWords();
  }

  Future<void> _loadLessonWords() async {
    setState(() {
      _isLoading = true;
    });

    _fsrsService = FSRSService();
    _vocabularyRepo = VocabularyRepository(_fsrsService);

    await _vocabularyRepo.initialize();
    final cards = await _vocabularyRepo.getCardsToStudy(limit: 2); // Only 2 words for testing

    setState(() {
      _lessonWords = cards;
      _isLoading = false;
    });
  }

  void _toggleSkip(String word) {
    setState(() {
      if (_skippedWords.contains(word)) {
        _skippedWords.remove(word);
      } else {
        _skippedWords.add(word);
      }
    });
  }

  Future<void> _startLesson() async {
    // Mark skipped words as "easy" in FSRS
    for (var word in _skippedWords) {
      await _vocabularyRepo.reviewCard(word, Rating.easy);
    }

    // Get words that need to be learned (not skipped)
    final wordsToLearn = _lessonWords
        .where((card) => !_skippedWords.contains(card['word']))
        .toList();

    if (!mounted) return;

    if (wordsToLearn.isEmpty) {
      // All words were skipped, go directly to summary
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LessonSummaryScreen(
            wordsLearned: [],
            wordsSkipped: _lessonWords,
          ),
        ),
      );
    } else {
      // Start the lesson with remaining words
      final result = await Navigator.push<List<Map<String, dynamic>>>(
        context,
        MaterialPageRoute(
          builder: (context) => JarvisHUDScreen(
            apiKey: widget.apiKey,
            lessonWords: wordsToLearn,
          ),
        ),
      );

      // If lesson was completed (result is not null), navigate to summary
      if (!mounted) return;

      if (result != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LessonSummaryScreen(
              wordsLearned: result,
              wordsSkipped: _lessonWords
                  .where((card) => _skippedWords.contains(card['word']))
                  .toList(),
            ),
          ),
        );
      }
    }
  }

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
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Colors.purpleAccent,
                  ),
                )
              : Column(
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back, color: Colors.purpleAccent),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Today\'s Lesson',
                                  style: TextStyle(
                                    color: Colors.purpleAccent.withOpacity(0.9),
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${_lessonWords.length} words to review',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.6),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Instructions
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.purpleAccent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.purpleAccent.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.purpleAccent,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Review the words below. Skip any you already know well.',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Word list
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _lessonWords.length,
                        itemBuilder: (context, index) {
                          final word = _lessonWords[index];
                          final japanese = word['word'] as String;
                          final romaji = word['romaji'] as String;
                          final meaning = word['meaning'] as String;
                          final example = word['example'] as String;
                          final isSkipped = _skippedWords.contains(japanese);

                          return _WordCard(
                            japanese: japanese,
                            romaji: romaji,
                            meaning: meaning,
                            example: example,
                            isSkipped: isSkipped,
                            onToggleSkip: () => _toggleSkip(japanese),
                          );
                        },
                      ),
                    ),

                    // Start button
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          if (_skippedWords.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Text(
                                'Skipped ${_skippedWords.length} word${_skippedWords.length == 1 ? '' : 's'} - marked as known',
                                style: TextStyle(
                                  color: Colors.greenAccent.withOpacity(0.8),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _startLesson,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.purpleAccent,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _skippedWords.length == _lessonWords.length
                                        ? 'Finish'
                                        : 'Start Lesson',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.arrow_forward),
                                ],
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

  @override
  void dispose() {
    _fsrsService.dispose();
    super.dispose();
  }
}

/// Word card widget for pre-lesson screen
class _WordCard extends StatelessWidget {
  final String japanese;
  final String romaji;
  final String meaning;
  final String example;
  final bool isSkipped;
  final VoidCallback onToggleSkip;

  const _WordCard({
    required this.japanese,
    required this.romaji,
    required this.meaning,
    required this.example,
    required this.isSkipped,
    required this.onToggleSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSkipped
            ? Colors.greenAccent.withOpacity(0.1)
            : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSkipped
              ? Colors.greenAccent.withOpacity(0.5)
              : Colors.purpleAccent.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      japanese,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      romaji,
                      style: TextStyle(
                        color: Colors.purpleAccent.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onToggleSkip,
                icon: Icon(
                  isSkipped ? Icons.check_circle : Icons.circle_outlined,
                  color: isSkipped ? Colors.greenAccent : Colors.white.withOpacity(0.5),
                  size: 28,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            meaning,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              example,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          if (isSkipped)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 16,
                    color: Colors.greenAccent,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Marked as already known',
                    style: TextStyle(
                      color: Colors.greenAccent,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
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
