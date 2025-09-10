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

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  final DatabaseService _databaseService = DatabaseService.instance;
  
  String _searchQuery = '';
  String _selectedLanguage = 'All';
  String _selectedDifficulty = 'All';
  String _selectedCategory = 'All';
  bool _showOnlyPublic = false;
  String _sortBy = 'Popularity';
  
  bool _isSearching = false;
  List<Deck> _allDecks = [];
  bool _isLoading = true;
  
  final List<String> _recentSearches = [
    'Spanish conversation',
    'Japanese hiragana',
    'French verbs',
    'Medical terms',
  ];
  
  final List<String> _popularSearches = [
    'Spanish basics',
    'French grammar',
    'Japanese kanji',
    'German vocabulary',
    'Italian phrases',
    'Chinese characters',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _searchController.addListener(_onSearchChanged);
    _loadDecks();
  }

  Future<void> _loadDecks() async {
    try {
      final decks = await _databaseService.database.deckDao.getAllDecks();
      final modelDecks = decks.map((deck) => Deck(
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

      setState(() {
        _allDecks = modelDecks;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading decks: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _isSearching = _searchQuery.isNotEmpty;
    });
  }

  List<Deck> get _filteredDecks {
    var filtered = _allDecks.where((deck) {
      // Search query filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!deck.name.toLowerCase().contains(query) &&
            !deck.description.toLowerCase().contains(query) &&
            !deck.tags.any((tag) => tag.toLowerCase().contains(query))) {
          return false;
        }
      }
      
      // Language filter
      if (_selectedLanguage != 'All' && deck.language != _selectedLanguage) {
        return false;
      }
      
      // Difficulty filter
      if (_selectedDifficulty != 'All' && deck.difficulty != _selectedDifficulty) {
        return false;
      }
      
      // Public filter
      if (_showOnlyPublic && !deck.isPublic) {
        return false;
      }
      
      return true;
    }).toList();
    
    // Sort
    switch (_sortBy) {
      case 'Popularity':
        filtered.sort((a, b) => b.totalCards.compareTo(a.totalCards));
        break;
      case 'Recent':
        filtered.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        break;
      case 'Name':
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'Cards':
        filtered.sort((a, b) => b.totalCards.compareTo(a.totalCards));
        break;
    }
    
    return filtered;
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
            ? Column(
                children: [
                  _buildAppBar(),
                  const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                children: [
                  _buildAppBar(),
                  _buildSearchBar(),
                  _buildFilters(),
                  _buildTabBar(),
                  Expanded(
                    child: _buildTabContent(),
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
            child: Text(
              'Discover Decks',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            onPressed: _showFilterDialog,
            icon: const Icon(Icons.tune, color: Colors.white),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.surfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search decks, tags, or topics...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                      _isSearching = false;
                    });
                  },
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(top: AppSpacing.md),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        children: [
          _buildFilterChip('Language', _selectedLanguage),
          _buildFilterChip('Difficulty', _selectedDifficulty),
          _buildFilterChip('Sort', _sortBy),
          _buildFilterChip('Public Only', _showOnlyPublic ? 'Yes' : 'No'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text('$label: $value'),
        selected: value != 'All' && value != 'No',
        onSelected: (_) => _showFilterDialog(),
        selectedColor: AppColors.primary.withOpacity(0.2),
        checkmarkColor: AppColors.primary,
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
        tabs: const [
          Tab(text: 'Search Results'),
          Tab(text: 'Discover'),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildSearchResults(),
        _buildDiscoverContent(),
      ],
    );
  }

  Widget _buildSearchResults() {
    if (!_isSearching && _searchQuery.isEmpty) {
      return _buildSearchSuggestions();
    }
    
    final filteredDecks = _filteredDecks;
    
    if (filteredDecks.isEmpty) {
      return _buildNoResults();
    }
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      itemCount: filteredDecks.length,
      itemBuilder: (context, index) {
        final deck = filteredDecks[index];
        return _buildDeckCard(deck, index);
      },
    );
  }

  Widget _buildSearchSuggestions() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_recentSearches.isNotEmpty) ...[
            Text(
              'Recent Searches',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Gap(12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _recentSearches.map((search) => 
                ActionChip(
                  label: Text(search),
                  onPressed: () => _performSearch(search),
                  avatar: const Icon(Icons.history, size: 16),
                ),
              ).toList(),
            ),
            const Gap(24),
          ],
          
          Text(
            'Popular Searches',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Gap(12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _popularSearches.map((search) => 
              ActionChip(
                label: Text(search),
                onPressed: () => _performSearch(search),
                avatar: const Icon(Icons.trending_up, size: 16),
              ),
            ).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscoverContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCategorySection('Featured Decks', _allDecks.take(2).toList()),
          const Gap(24),
          _buildCategorySection('Most Popular', _allDecks.where((d) => d.isPublic).toList()),
          const Gap(24),
          _buildCategorySection('Recently Updated', _allDecks.take(3).toList()),
        ],
      ),
    );
  }

  Widget _buildCategorySection(String title, List<Deck> decks) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('See All'),
            ),
          ],
        ),
        const Gap(12),
        ...decks.asMap().entries.map((entry) {
          return _buildDeckCard(entry.value, entry.key);
        }),
      ],
    );
  }

  Widget _buildDeckCard(Deck deck, int index) {
    return AnimatedCard(
      animationDelay: Duration(milliseconds: 100 * index),
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _viewDeck(deck),
        borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    _getLanguageFlag(deck.language),
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const Gap(16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            deck.name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (deck.isPublic)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.success.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'PUBLIC',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.success,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const Gap(4),
                    Text(
                      deck.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.hint,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Gap(8),
                    Row(
                      children: [
                        Icon(Icons.style, size: 14, color: AppColors.hint),
                        const Gap(4),
                        Text(
                          '${deck.totalCards} cards',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.hint,
                          ),
                        ),
                        const Gap(16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getDifficultyColor(deck.difficulty).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            deck.difficulty,
                            style: TextStyle(
                              fontSize: 12,
                              color: _getDifficultyColor(deck.difficulty),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Gap(8),
              PopupMenuButton<String>(
                onSelected: (value) => _handleDeckAction(value, deck),
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'view', child: Text('View Deck')),
                  const PopupMenuItem(value: 'clone', child: Text('Clone Deck')),
                  const PopupMenuItem(value: 'share', child: Text('Share')),
                  if (deck.isPublic)
                    const PopupMenuItem(value: 'report', child: Text('Report')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: AppColors.hint,
          ),
          const Gap(24),
          Text(
            'No results found',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Gap(8),
          Text(
            'Try adjusting your search terms or filters',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.hint,
            ),
            textAlign: TextAlign.center,
          ),
          const Gap(32),
          OutlinedButton(
            onPressed: _clearAllFilters,
            child: const Text('Clear Filters'),
          ),
        ],
      ),
    );
  }

  void _performSearch(String query) {
    _searchController.text = query;
    setState(() {
      _searchQuery = query;
      _isSearching = true;
    });
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.hint,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Filters',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Gap(24),
                    
                    _buildFilterSection('Language', _selectedLanguage, [
                      'All', 'Spanish', 'French', 'German', 'Japanese', 'English', 'Italian'
                    ], (value) => setState(() => _selectedLanguage = value)),
                    
                    const Gap(16),
                    
                    _buildFilterSection('Difficulty', _selectedDifficulty, [
                      'All', 'Beginner', 'Intermediate', 'Advanced'
                    ], (value) => setState(() => _selectedDifficulty = value)),
                    
                    const Gap(16),
                    
                    _buildFilterSection('Sort By', _sortBy, [
                      'Popularity', 'Recent', 'Name', 'Cards'
                    ], (value) => setState(() => _sortBy = value)),
                    
                    const Gap(16),
                    
                    SwitchListTile(
                      title: const Text('Show Public Decks Only'),
                      value: _showOnlyPublic,
                      onChanged: (value) => setState(() => _showOnlyPublic = value),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _clearAllFilters,
                      child: const Text('Clear All'),
                    ),
                  ),
                  const Gap(12),
                  Expanded(
                    child: GradientButton(
                      text: 'Apply',
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection(String title, String currentValue, List<String> options, ValueChanged<String> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const Gap(8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = currentValue == option;
            return GestureDetector(
              onTap: () => onChanged(option),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? AppColors.primary.withOpacity(0.2) 
                      : AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                  ),
                ),
                child: Text(
                  option,
                  style: TextStyle(
                    color: isSelected ? AppColors.primary : Colors.white,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _clearAllFilters() {
    setState(() {
      _selectedLanguage = 'All';
      _selectedDifficulty = 'All';
      _selectedCategory = 'All';
      _showOnlyPublic = false;
      _sortBy = 'Popularity';
    });
    Navigator.pop(context);
  }

  void _viewDeck(Deck deck) {
    context.go('${AppRoutes.study}?deckId=${deck.id}');
  }

  void _handleDeckAction(String action, Deck deck) {
    switch (action) {
      case 'view':
        _viewDeck(deck);
        break;
      case 'clone':
        _showSnackBar('Deck cloned to your library');
        break;
      case 'share':
        _showSnackBar('Share link copied to clipboard');
        break;
      case 'report':
        _showSnackBar('Deck reported for review');
        break;
    }
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
      case 'italian':
        return '🇮🇹';
      default:
        return '🌍';
    }
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return AppColors.success;
      case 'intermediate':
        return AppColors.warning;
      case 'advanced':
        return AppColors.error;
      default:
        return AppColors.primary;
    }
  }
}