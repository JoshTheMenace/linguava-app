import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import '../../core/constants/app_routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../widgets/common/animated_card.dart';
import '../../widgets/common/gradient_button.dart';
import '../../models/deck.dart';
import '../../services/database_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseService _databaseService = DatabaseService.instance;
  List<Deck> _userDecks = [];
  int _totalCards = 0;
  int _masteredCards = 0;
  int _cardsToReview = 0;
  int _newCards = 0;
  int _learningCards = 0;
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }
  
  Future<void> _loadDashboardData() async {
    try {
      // Load decks from database
      final decks = await _databaseService.database.deckDao.getAllDecks();
      final deckModels = decks.map((deck) => Deck(
        id: deck.id,
        name: deck.name,
        description: deck.description,
        language: deck.language,
        difficulty: deck.difficulty,
        creatorId: deck.creatorId,
        isPublic: deck.isPublic,
        createdAt: deck.createdAt,
        updatedAt: deck.updatedAt,
      )).toList();
      
      // Calculate stats across all decks
      int totalCards = 0;
      int masteredCards = 0;
      int cardsToReview = 0;
      int newCards = 0;
      int learningCards = 0;
      
      final now = DateTime.now();
      
      for (final deck in decks) {
        final flashcards = await _databaseService.database.flashcardDao.getFlashcardsByDeck(deck.id);
        totalCards += flashcards.length;
        
        // Analyze each card's study status
        for (final flashcard in flashcards) {
          try {
            final studyCard = await _databaseService.database.studyCardDao.getStudyCard(flashcard.id);
            
            if (studyCard == null) {
              // No study data yet, count as new
              newCards++;
            } else {
              if (studyCard.isNew) {
                newCards++;
              } else if (studyCard.isLearning) {
                learningCards++;
                // Learning cards might also be due for review
                if (studyCard.nextReviewDate != null && 
                    studyCard.nextReviewDate!.isBefore(now.add(const Duration(minutes: 1)))) {
                  cardsToReview++;
                }
              } else {
                masteredCards++;
                // Check if mastered card is due for review
                if (studyCard.nextReviewDate != null && 
                    studyCard.nextReviewDate!.isBefore(now.add(const Duration(minutes: 1)))) {
                  cardsToReview++;
                }
              }
            }
          } catch (e) {
            // Card might not have study data yet, count as new
            newCards++;
          }
        }
      }
      
      if (mounted) {
        setState(() {
          _userDecks = deckModels;
          _totalCards = totalCards;
          _masteredCards = masteredCards;
          _cardsToReview = cardsToReview;
          _newCards = newCards;
          _learningCards = learningCards;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading dashboard data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
          child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              )
            : RefreshIndicator(
                onRefresh: _loadDashboardData,
                child: CustomScrollView(
                  slivers: [
                    _buildAppBar(),
                    SliverPadding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          _buildWelcomeSection(),
                          const Gap(24),
                          _buildStatsOverview(),
                          const Gap(32),
                          _buildQuickActions(),
                          const Gap(32),
                          _buildRecentDecks(),
                          const Gap(32),
                          _buildContinueLearning(),
                          const Gap(100),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.go(AppRoutes.createDeck);
        },
        backgroundColor: AppColors.secondary,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      floating: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withOpacity(0.1),
              AppColors.secondary.withOpacity(0.1),
            ],
          ),
        ),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
              ),
            ),
            child: const Icon(Icons.school, color: Colors.white, size: 24),
          ),
          const Gap(12),
          Text(
            'Linguava',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {
            context.go(AppRoutes.search);
          },
          icon: const Icon(Icons.search),
        ),
        IconButton(
          onPressed: () {
            context.go(AppRoutes.settings);
          },
          icon: const Icon(Icons.settings),
        ),
      ],
    );
  }

  Widget _buildWelcomeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome back!',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const Gap(8),
        Text(
          'Ready to continue your learning journey?',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Colors.white.withOpacity(0.7),
          ),
        ),
      ],
    )
        .animate()
        .fadeIn(delay: 200.ms, duration: 600.ms)
        .slideX(begin: -0.3, end: 0);
  }

  Widget _buildStatsOverview() {
    return Column(
      children: [
        // First row - basic stats
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.style,
                title: 'Total Cards',
                value: _totalCards.toString(),
                color: AppColors.primary,
              ),
            ),
            const Gap(12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.layers,
                title: 'Decks',
                value: _userDecks.length.toString(),
                color: AppColors.secondary,
              ),
            ),
            const Gap(12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.school,
                title: 'Mastered',
                value: _masteredCards.toString(),
                color: AppColors.success,
              ),
            ),
          ],
        ),
        const Gap(16),
        // Second row - review status
        _buildReviewSummary(),
      ],
    )
        .animate()
        .fadeIn(delay: 300.ms, duration: 600.ms)
        .slideY(begin: 0.3, end: 0);
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return AnimatedCard(
      backgroundColor: AppColors.surfaceVariant,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const Gap(8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const Gap(16),
        Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: GradientButton(
                    text: 'Study Now',
                    icon: const Icon(Icons.play_arrow, color: Colors.white, size: 20),
                    textStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    onPressed: _startSmartStudySession,
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: GradientButton(
                    text: 'Add Cards',
                    gradientColors: [AppColors.secondary, AppColors.primary],
                    icon: const Icon(Icons.add, color: Colors.white, size: 20),
                    textStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    onPressed: () {
                      context.go(AppRoutes.addCard);
                    },
                  ),
                ),
              ],
            ),
            const Gap(12),
            SizedBox(
              width: double.infinity,
              child: GradientButton(
                text: 'Learning Paths',
                gradientColors: [AppColors.primary.withOpacity(0.8), AppColors.secondary.withOpacity(0.8)],
                icon: const Icon(Icons.route, color: Colors.white, size: 20),
                textStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                onPressed: () {
                  context.go(AppRoutes.learningPaths);
                },
              ),
            ),
          ],
        ),
      ],
    )
        .animate()
        .fadeIn(delay: 600.ms, duration: 600.ms)
        .slideY(begin: 0.3, end: 0);
  }

  Widget _buildRecentDecks() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Your Decks',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                context.go(AppRoutes.deckManagement);
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const Gap(16),
        if (_userDecks.isEmpty) 
          _buildNoDeckMessage()
        else
          ...List.generate(
            _userDecks.take(3).length,
            (index) => _buildDeckCard(_userDecks[index], index),
          ),
      ],
    )
        .animate()
        .fadeIn(delay: 800.ms, duration: 600.ms)
        .slideY(begin: 0.3, end: 0);
  }

  Widget _buildDeckCard(Deck deck, int index) {
    return AnimatedCard(
      animationDelay: Duration(milliseconds: 200 * index),
      onTap: () {
        context.go('${AppRoutes.study}?deckId=${deck.id}');
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.layers, color: Colors.white, size: 24),
              ),
              const Gap(16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      deck.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Gap(4),
                    Text(
                      deck.description,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: AppColors.hint,
              ),
            ],
          ),
          const Gap(16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Progress',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const Gap(4),
                    LinearProgressIndicator(
                      value: deck.progressPercentage,
                      backgroundColor: AppColors.divider,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ],
                ),
              ),
              const Gap(16),
              Text(
                '${deck.reviewedCards}/${deck.totalCards}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContinueLearning() {
    return AnimatedCard(
      backgroundColor: AppColors.primaryWithOpacity10,
      customShadows: [
        BoxShadow(
          color: AppColors.primary.withOpacity(0.2),
          blurRadius: 20,
          spreadRadius: 2,
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.auto_awesome, color: Colors.white),
              ),
              const Gap(16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Study Session',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      'Let AI create a personalized study session for you',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Gap(16),
          GradientButton(
            text: 'Start AI Session',
            width: double.infinity,
            onPressed: () {
              context.go(AppRoutes.studySession);
            },
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 200.ms, duration: 600.ms)
        .slideY(begin: 0.3, end: 0);
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.surface.withOpacity(0.8),
            AppColors.surface,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.hint,
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 0:
              break;
            case 1:
              context.go(AppRoutes.study);
              break;
            case 2:
              context.go(AppRoutes.deckManagement);
              break;
            case 3:
              context.go(AppRoutes.stats);
              break;
            case 4:
              context.go(AppRoutes.profile);
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Study',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.layers),
            label: 'Decks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Stats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
  
  Widget _buildReviewSummary() {
    return AnimatedCard(
      backgroundColor: AppColors.surfaceVariant,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _cardsToReview > 0 ? AppColors.warning.withOpacity(0.2) : AppColors.success.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _cardsToReview > 0 ? Icons.schedule : Icons.check_circle,
                  color: _cardsToReview > 0 ? AppColors.warning : AppColors.success,
                  size: 20,
                ),
              ),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Review Status',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _cardsToReview > 0 
                          ? '$_cardsToReview cards ready for review'
                          : 'All caught up!',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.hint,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_cardsToReview > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.warning,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _cardsToReview.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  const Gap(8),
                  GestureDetector(
                    onTap: () => context.go(AppRoutes.debug),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.hint.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.bug_report,
                        color: AppColors.hint,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Gap(12),
          Row(
            children: [
              Expanded(
                child: _buildReviewStatusPill('New', _newCards, AppColors.secondary),
              ),
              const Gap(8),
              Expanded(
                child: _buildReviewStatusPill('Learning', _learningCards, AppColors.warning),
              ),
              const Gap(8),
              Expanded(
                child: _buildReviewStatusPill('Review', _cardsToReview, AppColors.error),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildReviewStatusPill(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            count.toString(),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
  
  Future<void> _startSmartStudySession() async {
    try {
      // Find the best deck to study from
      String? bestDeckId = await _findBestDeckToStudy();
      
      if (bestDeckId != null) {
        // Navigate to study screen with the selected deck
        if (mounted) {
          context.go('${AppRoutes.study}?deckId=$bestDeckId');
        }
      } else {
        // Show dialog if no cards available to study
        if (mounted) {
          _showNoCardsDialog();
        }
      }
    } catch (e) {
      print('Error starting study session: $e');
      if (mounted) {
        _showNoCardsDialog();
      }
    }
  }
  
  Future<String?> _findBestDeckToStudy() async {
    try {
      final decks = await _databaseService.database.deckDao.getAllDecks();
      
      // Priority 1: Find deck with cards due for review
      for (final deck in decks) {
        final flashcards = await _databaseService.database.flashcardDao.getFlashcardsByDeck(deck.id);
        if (flashcards.isEmpty) continue;
        
        // Check if deck has cards ready for review
        bool hasDueCards = false;
        bool hasNewCards = false;
        bool hasLearningCards = false;
        
        final now = DateTime.now();
        
        for (final flashcard in flashcards) {
          try {
            final studyCard = await _databaseService.database.studyCardDao.getStudyCard(flashcard.id);
            
            if (studyCard == null) {
              hasNewCards = true; // Card has no study data, so it's new
            } else {
              if (studyCard.isNew) {
                hasNewCards = true;
              } else if (studyCard.isLearning) {
                hasLearningCards = true;
                // Check if learning card is due
                if (studyCard.nextReviewDate != null && 
                    studyCard.nextReviewDate!.isBefore(now.add(const Duration(minutes: 1)))) {
                  hasDueCards = true;
                }
              } else {
                // Mature card - check if due for review
                if (studyCard.nextReviewDate != null && 
                    studyCard.nextReviewDate!.isBefore(now.add(const Duration(minutes: 1)))) {
                  hasDueCards = true;
                }
              }
            }
          } catch (e) {
            // Error getting study card, treat as new
            hasNewCards = true;
          }
        }
        
        // Prioritize decks with due cards, then learning cards, then new cards
        if (hasDueCards || hasLearningCards || hasNewCards) {
          return deck.id;
        }
      }
      
      // If no cards are due, return the first deck with any cards
      for (final deck in decks) {
        final flashcards = await _databaseService.database.flashcardDao.getFlashcardsByDeck(deck.id);
        if (flashcards.isNotEmpty) {
          return deck.id;
        }
      }
      
      return null; // No decks with cards found
    } catch (e) {
      print('Error finding best deck to study: $e');
      return null;
    }
  }
  
  void _showNoCardsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('No Cards to Study'),
        content: Text(_userDecks.isEmpty 
            ? 'You don\'t have any decks yet. Create a deck and add some cards to start studying!'
            : 'No cards are ready for study right now. Try adding more cards to your decks or check back later.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
          if (_userDecks.isEmpty)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.go(AppRoutes.createDeck);
              },
              child: const Text('Create Deck'),
            ),
        ],
      ),
    );
  }
  
  Widget _buildNoDeckMessage() {
    return AnimatedCard(
      child: Column(
        children: [
          Icon(
            Icons.layers_outlined,
            size: 48,
            color: AppColors.hint,
          ),
          const Gap(16),
          Text(
            'No Decks Yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Gap(8),
          Text(
            'Create your first deck to start learning!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.hint,
            ),
            textAlign: TextAlign.center,
          ),
          const Gap(16),
          ElevatedButton.icon(
            onPressed: () => context.go(AppRoutes.createDeck),
            icon: const Icon(Icons.add),
            label: const Text('Create Deck'),
          ),
        ],
      ),
    );
  }
}