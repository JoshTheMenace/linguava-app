import 'package:flutter/material.dart' hide Card;
import 'package:fsrs/fsrs.dart' hide State;
import '../services/fsrs_service.dart';
import '../repositories/vocabulary_repository.dart';
import 'package:intl/intl.dart';

/// Screen to view all FSRS cards and their review status
class CardsReviewScreen extends StatefulWidget {
  const CardsReviewScreen({super.key});

  @override
  State<CardsReviewScreen> createState() => _CardsReviewScreenState();
}

class _CardsReviewScreenState extends State<CardsReviewScreen> {
  late FSRSService _fsrsService;
  late VocabularyRepository _vocabularyRepo;
  bool _isLoading = true;
  List<_CardInfo> _cards = [];

  @override
  void initState() {
    super.initState();
    _initializeAndLoadCards();
  }

  Future<void> _initializeAndLoadCards() async {
    setState(() {
      _isLoading = true;
    });

    _fsrsService = FSRSService();
    _vocabularyRepo = VocabularyRepository(_fsrsService);

    await _vocabularyRepo.initialize();
    await _loadCards();

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadCards() async {
    final allCards = _fsrsService.getAllCards();
    final cardInfoList = <_CardInfo>[];

    for (var entry in allCards.entries) {
      final word = entry.key;
      final card = entry.value;
      final vocabData = _vocabularyRepo.getVocabularyData(word);

      if (vocabData != null) {
        cardInfoList.add(_CardInfo(
          word: word,
          meaning: vocabData['meaning'] as String,
          romaji: vocabData['romaji'] as String,
          card: card,
          isDue: card.due.isBefore(DateTime.now()),
        ));
      }
    }

    // Sort by due date (most overdue first)
    cardInfoList.sort((a, b) => a.card.due.compareTo(b.card.due));

    setState(() {
      _cards = cardInfoList;
    });
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
          child: Column(
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
                    Text(
                      'Card Review Status',
                      style: TextStyle(
                        color: Colors.purpleAccent.withOpacity(0.9),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Stats summary
              if (!_isLoading)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
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
                        _StatColumn(
                          label: 'Total',
                          value: _cards.length.toString(),
                          color: Colors.purpleAccent,
                        ),
                        _StatColumn(
                          label: 'Due',
                          value: _cards.where((c) => c.isDue).length.toString(),
                          color: Colors.redAccent,
                        ),
                        _StatColumn(
                          label: 'Upcoming',
                          value: _cards.where((c) => !c.isDue).length.toString(),
                          color: Colors.greenAccent,
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 20),

              // Cards list
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Colors.purpleAccent,
                        ),
                      )
                    : _cards.isEmpty
                        ? Center(
                            child: Text(
                              'No cards found',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                                fontSize: 16,
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: _cards.length,
                            itemBuilder: (context, index) {
                              final cardInfo = _cards[index];
                              return _CardListItem(cardInfo: cardInfo);
                            },
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

/// Card list item widget
class _CardListItem extends StatelessWidget {
  final _CardInfo cardInfo;

  const _CardListItem({required this.cardInfo});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dueDate = cardInfo.card.due;
    final isDue = dueDate.isBefore(now);
    final timeUntilDue = dueDate.difference(now);

    // Format the due/overdue time
    String dueText;
    Color dueColor;
    if (isDue) {
      if (timeUntilDue.abs().inMinutes < 1) {
        dueText = 'Due now';
      } else if (timeUntilDue.abs().inHours < 1) {
        dueText = 'Overdue ${timeUntilDue.abs().inMinutes}m';
      } else if (timeUntilDue.abs().inDays < 1) {
        dueText = 'Overdue ${timeUntilDue.abs().inHours}h';
      } else {
        dueText = 'Overdue ${timeUntilDue.abs().inDays}d';
      }
      dueColor = Colors.redAccent;
    } else {
      if (timeUntilDue.inMinutes < 60) {
        dueText = 'Due in ${timeUntilDue.inMinutes}m';
      } else if (timeUntilDue.inHours < 24) {
        dueText = 'Due in ${timeUntilDue.inHours}h';
      } else {
        dueText = 'Due in ${timeUntilDue.inDays}d';
      }
      dueColor = Colors.greenAccent;
    }

    // Get card state info
    final stability = cardInfo.card.stability;
    final difficulty = cardInfo.card.difficulty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDue
              ? Colors.redAccent.withOpacity(0.3)
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
                      cardInfo.word,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      cardInfo.romaji,
                      style: TextStyle(
                        color: Colors.purpleAccent.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: dueColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: dueColor.withOpacity(0.5)),
                ),
                child: Text(
                  dueText,
                  style: TextStyle(
                    color: dueColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            cardInfo.meaning,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _InfoChip(
                label: 'Stability',
                value: stability?.toStringAsFixed(1) ?? 'N/A',
                color: Colors.blueAccent,
              ),
              const SizedBox(width: 8),
              _InfoChip(
                label: 'Difficulty',
                value: difficulty?.toStringAsFixed(1) ?? 'N/A',
                color: Colors.orangeAccent,
              ),
              const SizedBox(width: 8),
              _InfoChip(
                label: 'State',
                value: cardInfo.card.state.toString().split('.').last,
                color: Colors.purpleAccent,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Next review: ${DateFormat('MMM d, y h:mm a').format(dueDate)}',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

/// Info chip widget
class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _InfoChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color.withOpacity(0.7),
              fontSize: 10,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// Stat column widget
class _StatColumn extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatColumn({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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

/// Card info helper class
class _CardInfo {
  final String word;
  final String meaning;
  final String romaji;
  final Card card;
  final bool isDue;

  _CardInfo({
    required this.word,
    required this.meaning,
    required this.romaji,
    required this.card,
    required this.isDue,
  });
}
