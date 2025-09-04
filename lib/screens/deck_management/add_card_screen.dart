import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import '../../core/constants/app_routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../widgets/common/animated_card.dart';
import '../../widgets/common/gradient_button.dart';

class AddCardScreen extends StatefulWidget {
  final String? deckId;
  
  const AddCardScreen({super.key, this.deckId});

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  final _frontController = TextEditingController();
  final _backController = TextEditingController();
  final _hintController = TextEditingController();
  final _pronunciationController = TextEditingController();
  final _exampleController = TextEditingController();
  
  // Card settings
  List<String> _tags = [];
  String _difficulty = 'medium';
  bool _enableTTS = false;
  bool _enableAI = true;
  
  // AI suggestions
  bool _showAISuggestions = false;
  List<String> _aiSuggestions = [];
  
  // Media
  String? _frontImagePath;
  String? _backImagePath;
  String? _audioPath;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Listen to text changes for AI suggestions
    _frontController.addListener(_onTextChanged);
    _backController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _frontController.dispose();
    _backController.dispose();
    _hintController.dispose();
    _pronunciationController.dispose();
    _exampleController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    if (_enableAI && _frontController.text.isNotEmpty && _backController.text.isEmpty) {
      _generateAISuggestions();
    }
  }

  void _generateAISuggestions() {
    setState(() {
      _showAISuggestions = true;
      // Mock AI suggestions
      _aiSuggestions = [
        'Hello (greeting)',
        'Hi (informal greeting)',
        'Good morning (morning greeting)',
      ];
    });
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
                  'Add New Card',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.deckId != null ? 'To Spanish Basics' : 'Select deck later',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.hint,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _toggleAI(),
            icon: Icon(
              Icons.auto_awesome,
              color: _enableAI ? AppColors.secondary : AppColors.hint,
            ),
            style: IconButton.styleFrom(
              backgroundColor: _enableAI 
                  ? AppColors.secondary.withOpacity(0.2)
                  : AppColors.surfaceVariant,
            ),
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
          Tab(text: 'Basic'),
          Tab(text: 'Advanced'),
          Tab(text: 'Media'),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildBasicTab(),
        _buildAdvancedTab(),
        _buildMediaTab(),
      ],
    );
  }

  Widget _buildBasicTab() {
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
                    'Front Side (Question)',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Gap(12),
                  TextFormField(
                    controller: _frontController,
                    decoration: const InputDecoration(
                      hintText: 'Enter the question or term...',
                      prefixIcon: Icon(Icons.help_outline),
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Please enter the front side content';
                      }
                      return null;
                    },
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            
            const Gap(16),
            
            AnimatedCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Back Side (Answer)',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      if (_enableAI)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppColors.secondary, AppColors.primary],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.auto_awesome,
                                size: 12,
                                color: Colors.white,
                              ),
                              const Gap(4),
                              Text(
                                'AI',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const Gap(12),
                  TextFormField(
                    controller: _backController,
                    decoration: const InputDecoration(
                      hintText: 'Enter the answer or definition...',
                      prefixIcon: Icon(Icons.lightbulb_outline),
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Please enter the back side content';
                      }
                      return null;
                    },
                    maxLines: 3,
                  ),
                  
                  if (_showAISuggestions && _aiSuggestions.isNotEmpty) ...[
                    const Gap(12),
                    Text(
                      'AI Suggestions',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Gap(8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _aiSuggestions.map((suggestion) => 
                        GestureDetector(
                          onTap: () => _applySuggestion(suggestion),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppColors.secondary.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.auto_awesome,
                                  size: 12,
                                  color: AppColors.secondary,
                                ),
                                const Gap(4),
                                Text(
                                  suggestion,
                                  style: TextStyle(
                                    color: AppColors.secondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ).toList(),
                    ),
                  ],
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
                        deleteIcon: Icon(Icons.close, size: 16),
                      )),
                      ActionChip(
                        label: const Text('Add Tag'),
                        onPressed: _showAddTagDialog,
                        avatar: const Icon(Icons.add, size: 16),
                      ),
                    ],
                  ),
                  if (_tags.isEmpty) ...[
                    const Gap(8),
                    Text(
                      'Add tags to organize and search your cards',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.hint,
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

  Widget _buildAdvancedTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          AnimatedCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Additional Information',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Gap(16),
                TextFormField(
                  controller: _hintController,
                  decoration: const InputDecoration(
                    labelText: 'Hint (optional)',
                    hintText: 'Add a helpful hint...',
                    prefixIcon: Icon(Icons.tips_and_updates),
                  ),
                  maxLines: 2,
                ),
                const Gap(16),
                TextFormField(
                  controller: _pronunciationController,
                  decoration: const InputDecoration(
                    labelText: 'Pronunciation (optional)',
                    hintText: 'Add pronunciation guide...',
                    prefixIcon: Icon(Icons.record_voice_over),
                  ),
                ),
                const Gap(16),
                TextFormField(
                  controller: _exampleController,
                  decoration: const InputDecoration(
                    labelText: 'Example Sentence (optional)',
                    hintText: 'Add an example sentence...',
                    prefixIcon: Icon(Icons.format_quote),
                  ),
                  maxLines: 3,
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
                  'Card Settings',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
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
                  children: ['easy', 'medium', 'hard'].map((level) {
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
                              level.toUpperCase(),
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
                
                const Gap(20),
                
                // TTS toggle
                SwitchListTile(
                  title: Text('Enable Text-to-Speech'),
                  subtitle: Text('Generate audio pronunciation'),
                  value: _enableTTS,
                  onChanged: (value) => setState(() => _enableTTS = value),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          AnimatedCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Images',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Gap(16),
                
                // Front image
                _buildImagePicker(
                  'Front Side Image',
                  _frontImagePath,
                  (path) => setState(() => _frontImagePath = path),
                ),
                
                const Gap(16),
                
                // Back image
                _buildImagePicker(
                  'Back Side Image',
                  _backImagePath,
                  (path) => setState(() => _backImagePath = path),
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
                  'Audio',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Gap(16),
                
                _buildAudioPicker(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePicker(String label, String? imagePath, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const Gap(8),
        GestureDetector(
          onTap: () => _pickImage(onChanged),
          child: Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.divider,
                style: BorderStyle.solid,
              ),
            ),
            child: imagePath != null
                ? Stack(
                    children: [
                      Center(
                        child: Icon(
                          Icons.image,
                          size: 48,
                          color: AppColors.primary,
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () => onChanged(null),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.error,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate,
                        size: 48,
                        color: AppColors.hint,
                      ),
                      const Gap(8),
                      Text(
                        'Tap to add image',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.hint,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildAudioPicker() {
    return Column(
      children: [
        if (_audioPath != null) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.audiotrack, color: AppColors.primary),
                const Gap(12),
                Expanded(
                  child: Text(
                    'Audio recorded',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => setState(() => _audioPath = null),
                  icon: Icon(Icons.delete, color: AppColors.error),
                ),
              ],
            ),
          ),
          const Gap(16),
        ],
        
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _recordAudio,
                icon: const Icon(Icons.mic),
                label: const Text('Record Audio'),
              ),
            ),
            const Gap(12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _pickAudioFile,
                icon: const Icon(Icons.upload_file),
                label: const Text('Upload File'),
              ),
            ),
          ],
        ),
      ],
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
                onPressed: _previewCard,
                child: const Text('Preview'),
              ),
            ),
            const Gap(12),
            Expanded(
              flex: 2,
              child: GradientButton(
                text: 'Add Card',
                icon: const Icon(Icons.add, color: Colors.white, size: 20),
                onPressed: _saveCard,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleAI() {
    setState(() {
      _enableAI = !_enableAI;
      if (!_enableAI) {
        _showAISuggestions = false;
        _aiSuggestions.clear();
      }
    });
  }

  void _applySuggestion(String suggestion) {
    _backController.text = suggestion;
    setState(() {
      _showAISuggestions = false;
      _aiSuggestions.clear();
    });
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

  void _pickImage(Function(String?) onChanged) {
    // Mock image picker
    onChanged('mock_image_path.jpg');
    _showSnackBar('Image selected');
  }

  void _recordAudio() {
    setState(() {
      _audioPath = 'mock_audio_path.mp3';
    });
    _showSnackBar('Audio recorded');
  }

  void _pickAudioFile() {
    setState(() {
      _audioPath = 'mock_audio_file.mp3';
    });
    _showSnackBar('Audio file selected');
  }

  void _previewCard() {
    if (_formKey.currentState!.validate()) {
      // Show preview dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Card Preview'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Front: ${_frontController.text}'),
              const Gap(8),
              Text('Back: ${_backController.text}'),
              if (_tags.isNotEmpty) ...[
                const Gap(8),
                Text('Tags: ${_tags.join(', ')}'),
              ],
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
  }

  void _saveCard() {
    if (_formKey.currentState!.validate()) {
      // Mock save operation
      _showSnackBar('Card added successfully!');
      context.go(AppRoutes.home);
    }
  }

  void _showExitDialog() {
    if (_frontController.text.isNotEmpty || _backController.text.isNotEmpty) {
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

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'easy':
        return AppColors.success;
      case 'medium':
        return AppColors.warning;
      case 'hard':
        return AppColors.error;
      default:
        return AppColors.primary;
    }
  }
}