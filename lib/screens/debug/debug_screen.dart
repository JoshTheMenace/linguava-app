import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import '../../core/constants/app_routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../widgets/common/animated_card.dart';
import '../../services/database_service.dart';

class DebugScreen extends StatefulWidget {
  const DebugScreen({super.key});

  @override
  State<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  final DatabaseService _databaseService = DatabaseService.instance;
  List<CardDebugInfo> _cardDebugInfo = [];
  bool _isLoading = true;
  String _selectedDeckId = '';
  List<DeckInfo> _availableDecks = [];

  @override
  void initState() {
    super.initState();
    _loadDebugData();
  }

  Future<void> _loadDebugData() async {
    try {
      // Load all decks first
      final decks = await _databaseService.database.deckDao.getAllDecks();
      final deckInfo = decks.map((deck) => DeckInfo(
        id: deck.id,
        name: deck.name,
      )).toList();

      if (deckInfo.isNotEmpty && _selectedDeckId.isEmpty) {
        _selectedDeckId = deckInfo.first.id;
      }

      // Load card debug info for selected deck
      List<CardDebugInfo> cardInfo = [];
      
      if (_selectedDeckId.isNotEmpty) {
        final flashcards = await _databaseService.database.flashcardDao.getFlashcardsByDeck(_selectedDeckId);
        final now = DateTime.now();
        
        for (final flashcard in flashcards) {
          try {
            final studyCard = await _databaseService.database.studyCardDao.getStudyCard(flashcard.id);
            
            String status = 'New';
            String nextReview = 'Not scheduled';
            double difficulty = 0.0;
            double stability = 0.0;
            int reviewCount = 0;
            int lapses = 0;
            String fsrsState = 'New';
            
            if (studyCard != null) {
              if (studyCard.isNew) {
                status = 'New';
              } else if (studyCard.isLearning) {
                status = 'Learning';
              } else {
                status = 'Mature';
              }
              
              difficulty = studyCard.difficulty;
              stability = studyCard.stability;
              reviewCount = studyCard.reviewCount;
              lapses = studyCard.lapses ?? 0;
              
              if (studyCard.nextReviewDate != null) {
                final timeDiff = studyCard.nextReviewDate!.difference(now);
                if (timeDiff.isNegative) {
                  nextReview = 'Overdue by ${timeDiff.abs().inMinutes}m';
                } else if (timeDiff.inDays > 0) {
                  nextReview = 'In ${timeDiff.inDays}d';
                } else if (timeDiff.inHours > 0) {
                  nextReview = 'In ${timeDiff.inHours}h';
                } else {
                  nextReview = 'In ${timeDiff.inMinutes}m';
                }
              }
              
              // Decode FSRS state from JSON if available
              // This would need the actual FSRS data structure
              fsrsState = studyCard.isNew ? 'New' : studyCard.isLearning ? 'Learning' : 'Review';
            }
            
            cardInfo.add(CardDebugInfo(
              id: flashcard.id,
              front: flashcard.front,
              back: flashcard.back,
              status: status,
              nextReview: nextReview,
              difficulty: difficulty,
              stability: stability,
              reviewCount: reviewCount,
              lapses: lapses,
              fsrsState: fsrsState,
              isOverdue: studyCard?.nextReviewDate != null && studyCard!.nextReviewDate!.isBefore(now),
            ));
          } catch (e) {
            // Card has no study data
            cardInfo.add(CardDebugInfo(
              id: flashcard.id,
              front: flashcard.front,
              back: flashcard.back,
              status: 'New',
              nextReview: 'Not scheduled',
              difficulty: 0.0,
              stability: 0.0,
              reviewCount: 0,
              lapses: 0,
              fsrsState: 'New',
              isOverdue: false,
            ));
          }
        }
        
        // Sort by next review time (overdue first, then by time)
        cardInfo.sort((a, b) {
          if (a.isOverdue && !b.isOverdue) return -1;
          if (!a.isOverdue && b.isOverdue) return 1;
          return a.nextReview.compareTo(b.nextReview);
        });
      }

      setState(() {
        _availableDecks = deckInfo;
        _cardDebugInfo = cardInfo;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading debug data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF121212),
              Color(0xFF1a1a1a),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              if (_availableDecks.isNotEmpty) _buildDeckSelector(),
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                      )
                    : _cardDebugInfo.isEmpty
                        ? _buildEmptyState()
                        : _buildCardList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.go(AppRoutes.home),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.surfaceVariant,
            ),
          ),
          const Gap(16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Debug Cards',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Review status and FSRS data',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.hint,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _loadDebugData,
            icon: const Icon(Icons.refresh, color: Colors.white),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.surfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeckSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedDeckId,
          hint: const Text('Select Deck'),
          isExpanded: true,
          items: _availableDecks.map((deck) => DropdownMenuItem(
            value: deck.id,
            child: Text(deck.name),
          )).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedDeckId = value;
                _isLoading = true;
              });
              _loadDebugData();
            }
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bug_report_outlined,
            size: 64,
            color: AppColors.hint,
          ),
          const Gap(16),
          Text(
            'No Cards to Debug',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppColors.hint,
            ),
          ),
          const Gap(8),
          Text(
            'Add some cards to a deck to see debug information',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.hint,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCardList() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: _cardDebugInfo.length,
      itemBuilder: (context, index) {
        final card = _cardDebugInfo[index];
        return AnimatedCard(
          animationDelay: Duration(milliseconds: 50 * index),
          margin: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _getStatusColor(card.status),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const Gap(12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                card.front,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getStatusColor(card.status).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                card.status,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: _getStatusColor(card.status),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Gap(4),
                        Text(
                          card.back,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.hint,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Gap(12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildInfoChip('Next Review', card.nextReview, card.isOverdue ? AppColors.error : AppColors.primary),
                  _buildInfoChip('Reviews', card.reviewCount.toString(), AppColors.secondary),
                  _buildInfoChip('Difficulty', card.difficulty.toStringAsFixed(1), AppColors.warning),
                  _buildInfoChip('Stability', card.stability.toStringAsFixed(1), AppColors.success),
                  if (card.lapses > 0)
                    _buildInfoChip('Lapses', card.lapses.toString(), AppColors.error),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoChip(String label, String value, Color color) {
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
            '$label: ',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.hint,
              fontSize: 10,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'New':
        return AppColors.secondary;
      case 'Learning':
        return AppColors.warning;
      case 'Mature':
        return AppColors.success;
      default:
        return AppColors.primary;
    }
  }
}

class CardDebugInfo {
  final String id;
  final String front;
  final String back;
  final String status;
  final String nextReview;
  final double difficulty;
  final double stability;
  final int reviewCount;
  final int lapses;
  final String fsrsState;
  final bool isOverdue;

  CardDebugInfo({
    required this.id,
    required this.front,
    required this.back,
    required this.status,
    required this.nextReview,
    required this.difficulty,
    required this.stability,
    required this.reviewCount,
    required this.lapses,
    required this.fsrsState,
    required this.isOverdue,
  });
}

class DeckInfo {
  final String id;
  final String name;

  DeckInfo({
    required this.id,
    required this.name,
  });
}