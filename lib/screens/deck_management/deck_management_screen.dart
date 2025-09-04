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

class DeckManagementScreen extends StatefulWidget {
  const DeckManagementScreen({super.key});

  @override
  State<DeckManagementScreen> createState() => _DeckManagementScreenState();
}

class _DeckManagementScreenState extends State<DeckManagementScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _sortBy = 'recent';
  bool _showOnlyDue = false;

  final List<Deck> _mockDecks = [
    Deck(
      id: '1',
      name: 'Spanish Basics',
      description: 'Essential Spanish vocabulary for beginners including greetings, numbers, and common phrases',
      totalCards: 150,
      reviewedCards: 89,
      masteredCards: 45,
      language: 'Spanish',
      difficulty: 'Beginner',
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      updatedAt: DateTime.now(),
      creatorId: 'user1',
      tags: ['Spanish', 'Vocabulary', 'Beginner'],
      isPublic: false,
    ),
    Deck(
      id: '2',
      name: 'French Grammar Mastery',
      description: 'Master French grammar rules, conjugations, and sentence structure',
      totalCards: 200,
      reviewedCards: 156,
      masteredCards: 98,
      language: 'French',
      difficulty: 'Intermediate',
      createdAt: DateTime.now().subtract(const Duration(days: 14)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      creatorId: 'user1',
      tags: ['French', 'Grammar', 'Intermediate'],
      isPublic: true,
    ),
    Deck(
      id: '3',
      name: 'Business English Professional',
      description: 'Professional English vocabulary, phrases, and business terminology',
      totalCards: 120,
      reviewedCards: 45,
      masteredCards: 12,
      language: 'English',
      difficulty: 'Advanced',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      updatedAt: DateTime.now(),
      creatorId: 'user1',
      tags: ['English', 'Business', 'Advanced'],
      isPublic: false,
    ),
    Deck(
      id: '4',
      name: 'Japanese Kanji Level 1',
      description: 'Essential Japanese Kanji characters with readings and meanings',
      totalCards: 300,
      reviewedCards: 180,
      masteredCards: 60,
      language: 'Japanese',
      difficulty: 'Intermediate',
      createdAt: DateTime.now().subtract(const Duration(days: 21)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      creatorId: 'user1',
      tags: ['Japanese', 'Kanji', 'Characters'],
      isPublic: true,
    ),
    Deck(
      id: '5',
      name: 'German Pronunciation',
      description: 'German pronunciation guide with audio examples and phonetic rules',
      totalCards: 80,
      reviewedCards: 25,
      masteredCards: 8,
      language: 'German',
      difficulty: 'Beginner',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      updatedAt: DateTime.now(),
      creatorId: 'user1',
      tags: ['German', 'Pronunciation', 'Audio'],
      isPublic: false,
    ),
  ];

  List<Deck> get _filteredDecks {
    var decks = _mockDecks.where((deck) {
      final matchesSearch = _searchQuery.isEmpty ||
          deck.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          deck.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          deck.tags.any((tag) => tag.toLowerCase().contains(_searchQuery.toLowerCase()));

      final matchesFilter = !_showOnlyDue || (deck.reviewedCards < deck.totalCards);

      return matchesSearch && matchesFilter;
    }).toList();

    switch (_sortBy) {
      case 'name':
        decks.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'progress':
        decks.sort((a, b) => b.progressPercentage.compareTo(a.progressPercentage));
        break;
      case 'cards':
        decks.sort((a, b) => b.totalCards.compareTo(a.totalCards));
        break;
      case 'recent':
      default:
        decks.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        break;
    }

    return decks;
  }

  List<Deck> get _myDecks => _filteredDecks.where((deck) => !deck.isPublic).toList();
  List<Deck> get _publicDecks => _filteredDecks.where((deck) => deck.isPublic).toList();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
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
              _buildSearchAndFilters(),
              _buildTabBar(),
              Expanded(
                child: _buildTabContent(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go(AppRoutes.createDeck),
        backgroundColor: AppColors.secondary,
        icon: const Icon(Icons.add),
        label: const Text('New Deck'),
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
                  'My Decks',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${_mockDecks.length} decks • ${_mockDecks.fold(0, (sum, deck) => sum + deck.totalCards)} cards total',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.hint,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _showSortOptions(),
            icon: const Icon(Icons.sort, color: Colors.white),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.surfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search decks, tags, or content...',
                    prefixIcon: Icon(Icons.search, color: AppColors.hint),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: AppColors.hint),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                  ),
                ),
              ),
            ],
          ),
          const Gap(12),
          Row(
            children: [
              FilterChip(
                label: const Text('Due for Review'),
                selected: _showOnlyDue,
                onSelected: (selected) {
                  setState(() {
                    _showOnlyDue = selected;
                  });
                },
                selectedColor: AppColors.warning.withOpacity(0.2),
                checkmarkColor: AppColors.warning,
              ),
              const Gap(8),
              FilterChip(
                label: Text('Sort: ${_getSortLabel(_sortBy)}'),
                onSelected: (_) => _showSortOptions(),
                avatar: const Icon(Icons.sort, size: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.secondary],
          ),
          borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.hint,
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.person, size: 16),
                const Gap(8),
                Text('My Decks (${_myDecks.length})'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.public, size: 16),
                const Gap(8),
                Text('Shared (${_publicDecks.length})'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildDeckGrid(_myDecks, isMyDecks: true),
        _buildDeckGrid(_publicDecks, isMyDecks: false),
      ],
    );
  }

  Widget _buildDeckGrid(List<Deck> decks, {required bool isMyDecks}) {
    if (decks.isEmpty) {
      return _buildEmptyState(isMyDecks);
    }

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: AppSpacing.md,
          mainAxisSpacing: AppSpacing.md,
        ),
        itemCount: decks.length,
        itemBuilder: (context, index) {
          return _buildDeckCard(decks[index], index, isMyDecks: isMyDecks);
        },
      ),
    );
  }

  Widget _buildDeckCard(Deck deck, int index, {required bool isMyDecks}) {
    final dueCards = deck.totalCards - deck.reviewedCards;
    final isDue = dueCards > 0;

    return AnimatedCard(
      animationDelay: Duration(milliseconds: 100 * index),
      onTap: () => _onDeckTap(deck),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with language flag and options
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getLanguageFlag(deck.language),
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              const Spacer(),
              if (isMyDecks)
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: AppColors.hint, size: 16),
                  onSelected: (value) => _handleDeckAction(value, deck),
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'study', child: Text('Study Now')),
                    const PopupMenuItem(value: 'edit', child: Text('Edit Deck')),
                    const PopupMenuItem(value: 'stats', child: Text('View Stats')),
                    const PopupMenuItem(value: 'duplicate', child: Text('Duplicate')),
                    const PopupMenuItem(value: 'export', child: Text('Export')),
                    const PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
            ],
          ),
          const Gap(12),
          
          // Deck name and description
          Text(
            deck.name,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const Gap(4),
          Text(
            deck.description,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.hint,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          
          const Spacer(),
          
          // Progress section
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progress',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.hint,
                    ),
                  ),
                  Text(
                    '${(deck.progressPercentage * 100).round()}%',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const Gap(4),
              LinearProgressIndicator(
                value: deck.progressPercentage,
                backgroundColor: AppColors.divider,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                minHeight: 3,
              ),
              const Gap(8),
              
              // Stats row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatPill('${deck.totalCards}', 'Cards', AppColors.primary),
                  if (isDue)
                    _buildStatPill('$dueCards', 'Due', AppColors.warning)
                  else
                    _buildStatPill('${deck.masteredCards}', 'Mastered', AppColors.success),
                ],
              ),
            ],
          ),
          
          const Gap(8),
          
          // Tags
          if (deck.tags.isNotEmpty)
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: deck.tags.take(2).map((tag) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  tag,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.primary,
                    fontSize: 10,
                  ),
                ),
              )).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildStatPill(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
          const Gap(2),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isMyDecks) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isMyDecks ? Icons.add_circle_outline : Icons.public_off,
            size: 64,
            color: AppColors.hint,
          ),
          const Gap(16),
          Text(
            isMyDecks ? 'No decks yet' : 'No shared decks found',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppColors.hint,
            ),
          ),
          const Gap(8),
          Text(
            isMyDecks 
                ? 'Create your first deck to start learning'
                : 'Try adjusting your search or filters',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.hint,
            ),
            textAlign: TextAlign.center,
          ),
          if (isMyDecks) ...[
            const Gap(24),
            GradientButton(
              text: 'Create First Deck',
              icon: const Icon(Icons.add, color: Colors.white, size: 20),
              onPressed: () => context.go(AppRoutes.createDeck),
            ),
          ],
        ],
      ),
    );
  }

  void _onDeckTap(Deck deck) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.hint,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Gap(16),
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
                  child: Text(
                    _getLanguageFlag(deck.language),
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
                const Gap(16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        deck.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${deck.totalCards} cards • ${deck.difficulty}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.hint,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Gap(24),
            Row(
              children: [
                Expanded(
                  child: GradientButton(
                    text: 'Study Now',
                    icon: const Icon(Icons.play_arrow, color: Colors.white, size: 20),
                    onPressed: () {
                      Navigator.pop(context);
                      context.go('${AppRoutes.study}?deckId=${deck.id}');
                    },
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: GradientButton(
                    text: 'Add Cards',
                    gradientColors: [AppColors.secondary, AppColors.primary],
                    icon: const Icon(Icons.add, color: Colors.white, size: 20),
                    onPressed: () {
                      Navigator.pop(context);
                      context.go('${AppRoutes.addCard}?deckId=${deck.id}');
                    },
                  ),
                ),
              ],
            ),
            const Gap(16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    context.go('${AppRoutes.editDeck}?deckId=${deck.id}');
                  },
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Edit'),
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    context.go(AppRoutes.stats);
                  },
                  icon: const Icon(Icons.analytics, size: 16),
                  label: const Text('Stats'),
                ),
                TextButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.share, size: 16),
                  label: const Text('Share'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _handleDeckAction(String action, Deck deck) {
    switch (action) {
      case 'study':
        context.go('${AppRoutes.study}?deckId=${deck.id}');
        break;
      case 'edit':
        context.go('${AppRoutes.editDeck}?deckId=${deck.id}');
        break;
      case 'stats':
        context.go(AppRoutes.stats);
        break;
      case 'duplicate':
        _showSnackBar('Deck duplicated successfully');
        break;
      case 'export':
        _showSnackBar('Deck exported successfully');
        break;
      case 'delete':
        _showDeleteConfirmation(deck);
        break;
    }
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.hint,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Gap(16),
            Text(
              'Sort Decks By',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Gap(16),
            ...['recent', 'name', 'progress', 'cards'].map((sortOption) =>
              ListTile(
                leading: Icon(
                  _getSortIcon(sortOption),
                  color: _sortBy == sortOption ? AppColors.primary : AppColors.hint,
                ),
                title: Text(_getSortLabel(sortOption)),
                trailing: _sortBy == sortOption 
                    ? Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () {
                  setState(() {
                    _sortBy = sortOption;
                  });
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(Deck deck) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Deck'),
        content: Text('Are you sure you want to delete "${deck.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnackBar('Deck deleted successfully');
            },
            child: Text(
              'Delete',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _getLanguageFlag(String language) {
    switch (language.toLowerCase()) {
      case 'spanish':
        return '🇪🇸';
      case 'french':
        return '🇫🇷';
      case 'german':
        return '🇩🇪';
      case 'japanese':
        return '🇯🇵';
      case 'english':
        return '🇺🇸';
      default:
        return '🌍';
    }
  }

  String _getSortLabel(String sortBy) {
    switch (sortBy) {
      case 'recent':
        return 'Recently Updated';
      case 'name':
        return 'Name A-Z';
      case 'progress':
        return 'Progress';
      case 'cards':
        return 'Card Count';
      default:
        return 'Recent';
    }
  }

  IconData _getSortIcon(String sortBy) {
    switch (sortBy) {
      case 'recent':
        return Icons.access_time;
      case 'name':
        return Icons.sort_by_alpha;
      case 'progress':
        return Icons.trending_up;
      case 'cards':
        return Icons.numbers;
      default:
        return Icons.access_time;
    }
  }
}