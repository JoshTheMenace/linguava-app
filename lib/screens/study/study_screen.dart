import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import '../../core/constants/app_routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../widgets/common/flip_card.dart';
import '../../widgets/common/study_grade_buttons.dart';
import '../../models/study_card.dart';
import '../../models/flashcard.dart';
import '../../services/fsrs_service.dart';
import '../../services/database_service.dart';

class StudyScreen extends StatefulWidget {
  final String deckId;
  
  const StudyScreen({super.key, required this.deckId});

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> {
  bool _isCardFlipped = false;
  bool _showGradeButtons = false;
  int _currentCardIndex = 0;
  
  // FSRS service for algorithm integration
  late final FSRSService _fsrsService;
  List<StudyCard> _studyCards = [];
  bool _isLoading = true;
  String _deckName = 'Loading...';

  @override
  void initState() {
    super.initState();
    _fsrsService = FSRSService();
    _initializeStudySession();
  }

  Future<void> _initializeStudySession() async {
    try {
      // Load deck name from database
      final databaseService = DatabaseService.instance;
      if (widget.deckId.isNotEmpty) {
        final deck = await databaseService.database.deckDao.getDeckById(widget.deckId);
        if (deck != null) {
          _deckName = deck.name;
        } else {
          _deckName = 'Unknown Deck';
        }
      } else {
        _deckName = 'Mixed Study';
      }
      
      // Get due cards first, then new cards if we need more
      final deckIdForQuery = widget.deckId.isNotEmpty ? widget.deckId : null;
      final dueCards = await _fsrsService.getDueCards(deckId: deckIdForQuery, limit: 10);
      final newCards = await _fsrsService.getNewCards(deckId: deckIdForQuery, limit: 5);
      final learningCards = await _fsrsService.getLearningCards(deckId: deckIdForQuery);
      
      // Combine and prioritize: learning > due > new
      final allCards = <StudyCard>[];
      allCards.addAll(learningCards);
      allCards.addAll(dueCards);
      allCards.addAll(newCards);
      
      // Remove duplicates (shouldn't happen but just in case)
      final uniqueCards = <String, StudyCard>{};
      for (final card in allCards) {
        uniqueCards[card.flashcard.id] = card;
      }
      
      _studyCards = uniqueCards.values.toList();
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading study session: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }
  

  StudyCard get _currentCard => _studyCards[_currentCardIndex];
  
  int get _newCardsCount => _studyCards.where((c) => c.isNew).length;
  int get _learningCardsCount => _studyCards.where((c) => c.isLearning).length;
  int get _reviewCardsCount => _studyCards.where((c) => !c.isNew && !c.isLearning).length;

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
          child: _isLoading 
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              )
            : _studyCards.isEmpty
            ? _buildEmptyState()
            : Column(
                children: [
                  _buildAppBar(),
                  _buildProgressSection(),
                  Expanded(
                    child: _buildCardSection(),
                  ),
                  _buildBottomSection(),
                ],
              ),
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
            Icons.school_outlined,
            size: 80,
            color: AppColors.hint,
          ),
          const Gap(24),
          Text(
            'No cards to study',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const Gap(8),
          Text(
            'All cards are up to date!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.hint,
            ),
          ),
          const Gap(32),
          ElevatedButton(
            onPressed: () => context.go(AppRoutes.home),
            child: const Text('Back to Home'),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          IconButton(
            onPressed: () => _showExitDialog(),
            icon: const Icon(Icons.close, color: Colors.white),
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
                  _deckName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _currentCard.cardStatus,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: _getStatusColor(_currentCard.cardStatus),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _showCardInfo(),
            icon: const Icon(Icons.info_outline, color: Colors.white),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.surfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${_currentCardIndex + 1} / ${_studyCards.length}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Gap(12),
          LinearProgressIndicator(
            value: (_currentCardIndex + 1) / _studyCards.length,
            backgroundColor: AppColors.divider,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            minHeight: 6,
          ),
          const Gap(12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildProgressStat('New', _newCardsCount, AppColors.secondary),
              _buildProgressStat('Learning', _learningCardsCount, AppColors.warning),
              _buildProgressStat('Review', _reviewCardsCount, AppColors.success),
            ],
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 200.ms, duration: 600.ms)
        .slideY(begin: -0.1, end: 0);
  }

  Widget _buildProgressStat(String label, int count, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            count.toString(),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const Gap(4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.hint,
          ),
        ),
      ],
    );
  }

  Widget _buildCardSection() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          const Gap(24),
          Expanded(
            child: FlipCard(
              isFlipped: _isCardFlipped,
              onTap: () => _flipCard(),
              front: StudyCardContent(
                text: _currentCard.flashcard.front,
                tags: _currentCard.flashcard.tags,
              ),
              back: StudyCardContent(
                text: _currentCard.flashcard.back,
                isAnswer: true,
                tags: _currentCard.flashcard.tags,
              ),
            ),
          ),
          const Gap(24),
          if (!_isCardFlipped)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.touch_app,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const Gap(8),
                  Text(
                    'Tap to reveal answer',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(delay: 800.ms, duration: 400.ms)
                .shimmer(
                  delay: 1200.ms,
                  duration: 2000.ms,
                  color: AppColors.primary.withOpacity(0.3),
                ),
        ],
      ),
    );
  }

  Widget _buildBottomSection() {
    return StudyGradeButtons(
      onGradeSelected: _handleGradeSelection,
      isVisible: _showGradeButtons,
      nextReviewTimes: _getNextReviewTimes(),
    );
  }

  void _flipCard() {
    setState(() {
      _isCardFlipped = true;
      _showGradeButtons = true;
    });
  }

  void _handleGradeSelection(StudyGrade grade) async {
    await _processCardGrade(grade);
    _nextCard();
  }

  Future<void> _processCardGrade(StudyGrade grade) async {
    try {
      // Use FSRS algorithm to process the grade
      final currentCard = _currentCard;
      final updatedCard = await _fsrsService.reviewCard(currentCard, grade);
      
      // Update the card in our list
      _studyCards[_currentCardIndex] = updatedCard;
      
      // Debug info
      print('Card graded: $grade');
      print('FSRS State: ${updatedCard.fsrsState}');
      print('Difficulty: ${updatedCard.difficulty.toStringAsFixed(2)}');
      print('Stability: ${updatedCard.formattedStability}');
      print('Next review: ${updatedCard.nextReviewText}');
    } catch (e) {
      print('Error processing grade: $e');
    }
  }

  void _nextCard() {
    if (_currentCardIndex < _studyCards.length - 1) {
      setState(() {
        _currentCardIndex++;
        _isCardFlipped = false;
        _showGradeButtons = false;
      });
    } else {
      _showSessionComplete();
    }
  }

  Map<StudyGrade, String> _getNextReviewTimes() {
    // Use real FSRS algorithm to get next review times
    return _fsrsService.getNextReviewTimes(_currentCard);
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'New':
        return AppColors.secondary;
      case 'Learning':
        return AppColors.warning;
      case 'Due':
      case 'Overdue':
        return AppColors.error;
      default:
        return AppColors.success;
    }
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End Study Session?'),
        content: const Text('Your progress will be saved. Are you sure you want to exit?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continue'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.go(AppRoutes.home);
            },
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }

  void _showCardInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Card Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Status', _currentCard.cardStatus),
            _buildInfoRow('FSRS State', _currentCard.fsrsState),
            _buildInfoRow('Reviews', '${_currentCard.reviewCount}'),
            _buildInfoRow('Difficulty', '${_currentCard.difficulty.toStringAsFixed(2)}'),
            _buildInfoRow('Stability', _currentCard.formattedStability),
            _buildInfoRow('Interval', _currentCard.interval != null ? '${_currentCard.interval} days' : 'N/A'),
            _buildInfoRow('Lapses', '${_currentCard.lapses ?? 0}'),
            _buildInfoRow('Next Review', _currentCard.nextReviewText),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  void _showSessionComplete() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('🎉 Session Complete!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Great job! You\'ve completed this study session.'),
            const Gap(16),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
              ),
              child: Column(
                children: [
                  Text(
                    '${_studyCards.length}',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Cards Studied',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.go(AppRoutes.home);
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}