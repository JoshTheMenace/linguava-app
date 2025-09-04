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

class EditDeckScreen extends StatefulWidget {
  final String deckId;
  
  const EditDeckScreen({super.key, required this.deckId});

  @override
  State<EditDeckScreen> createState() => _EditDeckScreenState();
}

class _EditDeckScreenState extends State<EditDeckScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  // Deck settings
  List<String> _tags = [];
  String _language = 'Spanish';
  String _difficulty = 'Beginner';
  bool _isPublic = false;
  String? _imageUrl;
  
  // Mock current deck data
  late Deck _currentDeck;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadDeckData();
  }

  void _loadDeckData() {
    // Mock deck data - in real app, this would be loaded from database
    _currentDeck = Deck(
      id: widget.deckId,
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
    );
    
    // Populate form fields
    _nameController.text = _currentDeck.name;
    _descriptionController.text = _currentDeck.description;
    _tags = List.from(_currentDeck.tags);
    _language = _currentDeck.language;
    _difficulty = _currentDeck.difficulty;
    _isPublic = _currentDeck.isPublic;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
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
              _buildTabBar(),
              Expanded(
                child: _buildTabContent(),
              ),
              _buildBottomActions(),
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
                  'Edit Deck',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${_currentDeck.totalCards} cards',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.hint,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'duplicate', child: Text('Duplicate Deck')),
              const PopupMenuItem(value: 'export', child: Text('Export Deck')),
              const PopupMenuItem(value: 'reset_progress', child: Text('Reset Progress')),
              const PopupMenuItem(value: 'delete', child: Text('Delete Deck')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
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
          Tab(text: 'Settings'),
          Tab(text: 'Cards'),
          Tab(text: 'Stats'),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildSettingsTab(),
        _buildCardsTab(),
        _buildStatsTab(),
      ],
    );
  }

  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Basic Information',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Gap(16),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Deck Name',
                      prefixIcon: Icon(Icons.folder),
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Please enter a deck name';
                      }
                      return null;
                    },
                  ),
                  const Gap(16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      prefixIcon: Icon(Icons.description),
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Please enter a description';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            
            const Gap(16),
            
            AnimatedCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Language & Difficulty',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Gap(16),
                  
                  // Language dropdown
                  DropdownButtonFormField<String>(
                    value: _language,
                    decoration: const InputDecoration(
                      labelText: 'Language',
                      prefixIcon: Icon(Icons.language),
                    ),
                    items: ['Spanish', 'French', 'German', 'Japanese', 'English', 'Italian', 'Portuguese']
                        .map((lang) => DropdownMenuItem(
                              value: lang,
                              child: Row(
                                children: [
                                  Text(_getLanguageFlag(lang)),
                                  const Gap(8),
                                  Text(lang),
                                ],
                              ),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _language = value ?? 'Spanish';
                      });
                    },
                  ),
                  
                  const Gap(16),
                  
                  // Difficulty selector
                  Text(
                    'Difficulty Level',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Gap(8),
                  Row(
                    children: ['Beginner', 'Intermediate', 'Advanced'].map((level) {
                      final isSelected = _difficulty == level;
                      final color = _getDifficultyColor(level);
                      
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: GestureDetector(
                            onTap: () => setState(() => _difficulty = level),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected 
                                    ? color.withOpacity(0.2) 
                                    : AppColors.divider.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? color : AppColors.divider,
                                  width: 1.5,
                                ),
                              ),
                              child: Text(
                                level,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: isSelected ? color : AppColors.hint,
                                  fontWeight: isSelected 
                                      ? FontWeight.w600 
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            
            const Gap(16),
            
            AnimatedCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tags',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Gap(12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ..._tags.map((tag) => Chip(
                        label: Text(tag),
                        onDeleted: () => _removeTag(tag),
                        deleteIcon: const Icon(Icons.close, size: 16),
                      )),
                      ActionChip(
                        label: const Text('Add Tag'),
                        onPressed: _showAddTagDialog,
                        avatar: const Icon(Icons.add, size: 16),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const Gap(16),
            
            AnimatedCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sharing & Privacy',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Gap(16),
                  
                  SwitchListTile(
                    title: const Text('Make deck public'),
                    subtitle: const Text('Allow others to discover and use this deck'),
                    value: _isPublic,
                    onChanged: (value) => setState(() => _isPublic = value),
                    contentPadding: EdgeInsets.zero,
                  ),
                  
                  if (_isPublic) ...[
                    const Gap(12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: AppColors.primary),
                          const Gap(12),
                          Expanded(
                            child: Text(
                              'Your deck will be visible in the shared decks section',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardsTab() {
    // Mock cards data
    final cards = [
      {'front': 'Hola', 'back': 'Hello', 'difficulty': 'easy'},
      {'front': 'Gracias', 'back': 'Thank you', 'difficulty': 'easy'},
      {'front': 'Por favor', 'back': 'Please', 'difficulty': 'medium'},
      {'front': 'Lo siento', 'back': 'I am sorry', 'difficulty': 'medium'},
      {'front': 'No entiendo', 'back': 'I don\'t understand', 'difficulty': 'hard'},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${cards.length} Cards',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => context.go('${AppRoutes.addCard}?deckId=${widget.deckId}'),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Card'),
              ),
            ],
          ),
          
          const Gap(16),
          
          ...cards.asMap().entries.map((entry) {
            final index = entry.key;
            final card = entry.value;
            
            return AnimatedCard(
              animationDelay: Duration(milliseconds: 100 * index),
              margin: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _getDifficultyColor(card['difficulty']!.toLowerCase()),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const Gap(16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          card['front']!,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          card['back']!,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.hint,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) => _handleCardAction(value, index),
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                      const PopupMenuItem(value: 'duplicate', child: Text('Duplicate')),
                      const PopupMenuItem(value: 'reset', child: Text('Reset Progress')),
                      const PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStatsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          AnimatedCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Deck Statistics',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Gap(16),
                
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        'Total Cards',
                        '${_currentDeck.totalCards}',
                        Icons.style,
                        AppColors.primary,
                      ),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        'Reviewed',
                        '${_currentDeck.reviewedCards}',
                        Icons.check_circle,
                        AppColors.success,
                      ),
                    ),
                  ],
                ),
                
                const Gap(16),
                
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        'Mastered',
                        '${_currentDeck.masteredCards}',
                        Icons.star,
                        AppColors.warning,
                      ),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        'Accuracy',
                        '${(_currentDeck.masteredCards / _currentDeck.reviewedCards * 100).round()}%',
                        Icons.trending_up,
                        AppColors.secondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const Gap(16),
          
          AnimatedCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Progress Overview',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Gap(16),
                
                _buildProgressBar(
                  'Overall Progress',
                  _currentDeck.progressPercentage,
                  AppColors.primary,
                ),
                
                const Gap(12),
                
                _buildProgressBar(
                  'Mastery Rate',
                  _currentDeck.masteryPercentage,
                  AppColors.success,
                ),
              ],
            ),
          ),
          
          const Gap(16),
          
          AnimatedCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Deck Information',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Gap(16),
                
                _buildInfoRow('Created', _formatDate(_currentDeck.createdAt)),
                _buildInfoRow('Last Updated', _formatDate(_currentDeck.updatedAt)),
                _buildInfoRow('Language', _currentDeck.language),
                _buildInfoRow('Difficulty', _currentDeck.difficulty),
                _buildInfoRow('Public', _currentDeck.isPublic ? 'Yes' : 'No'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const Gap(8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.hint,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar(String label, double progress, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              '${(progress * 100).round()}%',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const Gap(8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: AppColors.divider,
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 6,
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.hint,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => context.go(AppRoutes.home),
                child: const Text('Cancel'),
              ),
            ),
            const Gap(12),
            Expanded(
              flex: 2,
              child: GradientButton(
                text: 'Save Changes',
                icon: const Icon(Icons.save, color: Colors.white, size: 20),
                onPressed: _saveDeck,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  void _showAddTagDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Tag'),
        content: TextFormField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter tag name',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() {
                  _tags.add(controller.text);
                });
              }
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'duplicate':
        _showSnackBar('Deck duplicated successfully');
        break;
      case 'export':
        _showSnackBar('Deck exported successfully');
        break;
      case 'reset_progress':
        _showResetProgressDialog();
        break;
      case 'delete':
        _showDeleteDeckDialog();
        break;
    }
  }

  void _handleCardAction(String action, int cardIndex) {
    switch (action) {
      case 'edit':
        _showSnackBar('Card edit functionality coming soon');
        break;
      case 'duplicate':
        _showSnackBar('Card duplicated');
        break;
      case 'reset':
        _showSnackBar('Card progress reset');
        break;
      case 'delete':
        _showSnackBar('Card deleted');
        break;
    }
  }

  void _showResetProgressDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Progress'),
        content: const Text('This will reset all learning progress for this deck. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnackBar('Progress reset successfully');
            },
            child: Text(
              'Reset',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDeckDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Deck'),
        content: Text('Are you sure you want to delete "${_currentDeck.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.go(AppRoutes.home);
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

  void _saveDeck() {
    if (_formKey.currentState!.validate()) {
      // Mock save operation
      _showSnackBar('Deck updated successfully!');
      context.go(AppRoutes.home);
    }
  }

  void _showExitDialog() {
    // Check if there are unsaved changes
    bool hasChanges = _nameController.text != _currentDeck.name ||
                     _descriptionController.text != _currentDeck.description ||
                     _language != _currentDeck.language ||
                     _difficulty != _currentDeck.difficulty ||
                     _isPublic != _currentDeck.isPublic;
    
    if (hasChanges) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Discard Changes?'),
          content: const Text('You have unsaved changes. Are you sure you want to exit?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.go(AppRoutes.home);
              },
              child: const Text('Discard'),
            ),
          ],
        ),
      );
    } else {
      context.go(AppRoutes.home);
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
      case 'portuguese':
        return '🇵🇹';
      default:
        return '🌍';
    }
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
      case 'easy':
        return AppColors.success;
      case 'intermediate':
      case 'medium':
        return AppColors.warning;
      case 'advanced':
      case 'hard':
        return AppColors.error;
      default:
        return AppColors.primary;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}