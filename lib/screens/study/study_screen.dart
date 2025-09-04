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
  
  // Mock data for demonstration
  final List<StudyCard> _studyCards = [
    StudyCard(
      flashcard: Flashcard(
        id: '1',
        front: 'Hola',
        back: 'Hello (Spanish greeting)',
        tags: ['Spanish', 'Greetings', 'Basic'],
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        updatedAt: DateTime.now(),
      ),
      isNew: true,
      difficulty: 5.0,
      stability: 1.0,
    ),
    StudyCard(
      flashcard: Flashcard(
        id: '2',
        front: 'Comment allez-vous?',
        back: 'How are you? (Formal French)',
        tags: ['French', 'Greetings', 'Formal'],
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        updatedAt: DateTime.now(),
      ),
      isLearning: true,
      reviewCount: 2,
      difficulty: 6.2,
      stability: 2.5,
    ),
    StudyCard(
      flashcard: Flashcard(
        id: '3',
        front: 'Guten Tag',
        back: 'Good day / Hello (German)',
        tags: ['German', 'Greetings'],
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      reviewCount: 5,
      difficulty: 4.8,
      stability: 8.2,
      daysUntilReview: 0,
    ),
  ];

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
          child: Column(
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
                  'Spanish Basics',
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

  void _handleGradeSelection(StudyGrade grade) {
    // Simulate FSRS algorithm response
    _processCardGrade(grade);
    _nextCard();
  }

  void _processCardGrade(StudyGrade grade) {
    // Here you would implement FSRS algorithm
    // For now, just simulate the process
    print('Card graded: $grade');
    print('Current card difficulty: ${_currentCard.difficulty}');
    print('Current card stability: ${_currentCard.stability}');
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
    // Simulate FSRS intervals based on current card state
    if (_currentCard.isNew) {
      return {
        StudyGrade.again: '<1m',
        StudyGrade.hard: '6m',
        StudyGrade.good: '10m',
        StudyGrade.easy: '4d',
      };
    } else if (_currentCard.isLearning) {
      return {
        StudyGrade.again: '<1m',
        StudyGrade.hard: '6m',
        StudyGrade.good: '1d',
        StudyGrade.easy: '3d',
      };
    } else {
      final stability = _currentCard.stability;
      return {
        StudyGrade.again: '<1m',
        StudyGrade.hard: '${(stability * 0.5).round()}d',
        StudyGrade.good: '${(stability * 1.2).round()}d',
        StudyGrade.easy: '${(stability * 2.5).round()}d',
      };
    }
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
            _buildInfoRow('Reviews', '${_currentCard.reviewCount}'),
            _buildInfoRow('Difficulty', '${_currentCard.difficulty.toStringAsFixed(1)}'),
            _buildInfoRow('Stability', '${_currentCard.stability.toStringAsFixed(1)} days'),
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