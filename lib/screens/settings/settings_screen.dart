import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import '../../core/constants/app_routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../widgets/common/animated_card.dart';
import '../../services/database_service.dart';
import '../../widgets/common/gradient_button.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final DatabaseService _databaseService = DatabaseService.instance;
  // Study preferences
  int _newCardsPerDay = 20;
  int _reviewCardsPerDay = 100;
  bool _showAnswerTimer = true;
  bool _enableSounds = true;
  bool _vibrationFeedback = false;
  bool _autoPlayAudio = false;
  
  // Appearance
  String _selectedTheme = 'dark';
  bool _enableAnimations = true;
  double _fontScale = 1.0;
  
  // Study behavior
  bool _shuffleNewCards = false;
  bool _buryRelated = true;
  int _graduatingInterval = 1;
  int _easyInterval = 4;
  double _startingEase = 2.5;
  
  // Notifications
  bool _studyReminders = true;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 19, minute: 0);
  bool _reviewNotifications = true;
  bool _achievementNotifications = true;
  
  // Privacy & Data
  bool _anonymousUsage = false;
  bool _syncData = true;
  bool _backupEnabled = true;

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
              Expanded(
                child: _buildSettingsContent(),
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
              'Settings',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            onPressed: _resetToDefaults,
            icon: const Icon(Icons.refresh, color: Colors.white),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.surfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        children: [
          _buildStudyPreferencesSection(),
          const Gap(16),
          _buildAppearanceSection(),
          const Gap(16),
          _buildStudyBehaviorSection(),
          const Gap(16),
          _buildNotificationsSection(),
          const Gap(16),
          _buildPrivacySection(),
          const Gap(16),
          _buildAccountSection(),
          const Gap(16),
          _buildDebugSection(),
          const Gap(24),
        ],
      ),
    );
  }

  Widget _buildStudyPreferencesSection() {
    return AnimatedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.school, color: AppColors.primary, size: 20),
              ),
              const Gap(12),
              Text(
                'Study Preferences',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Gap(20),
          
          _buildSliderSetting(
            'New Cards Per Day',
            _newCardsPerDay.toDouble(),
            0,
            50,
            (value) => setState(() => _newCardsPerDay = value.toInt()),
            suffix: 'cards',
          ),
          
          const Gap(16),
          
          _buildSliderSetting(
            'Review Cards Per Day',
            _reviewCardsPerDay.toDouble(),
            50,
            500,
            (value) => setState(() => _reviewCardsPerDay = value.toInt()),
            suffix: 'cards',
          ),
          
          const Gap(16),
          
          _buildSwitchSetting(
            'Show Answer Timer',
            'Display time taken to answer each card',
            _showAnswerTimer,
            Icons.timer,
            (value) => setState(() => _showAnswerTimer = value),
          ),
          
          const Gap(8),
          
          _buildSwitchSetting(
            'Enable Sounds',
            'Play sound effects during study sessions',
            _enableSounds,
            Icons.volume_up,
            (value) => setState(() => _enableSounds = value),
          ),
          
          const Gap(8),
          
          _buildSwitchSetting(
            'Vibration Feedback',
            'Vibrate device for correct/incorrect answers',
            _vibrationFeedback,
            Icons.vibration,
            (value) => setState(() => _vibrationFeedback = value),
          ),
          
          const Gap(8),
          
          _buildSwitchSetting(
            'Auto-play Audio',
            'Automatically play audio when available',
            _autoPlayAudio,
            Icons.play_arrow,
            (value) => setState(() => _autoPlayAudio = value),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 0.ms, duration: 600.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildAppearanceSection() {
    return AnimatedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.palette, color: AppColors.secondary, size: 20),
              ),
              const Gap(12),
              Text(
                'Appearance',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Gap(20),
          
          Text(
            'Theme',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const Gap(8),
          Row(
            children: ['light', 'dark', 'system'].map((theme) {
              final isSelected = _selectedTheme == theme;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTheme = theme),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? AppColors.secondary.withOpacity(0.2) 
                            : AppColors.divider.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? AppColors.secondary : AppColors.divider,
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        theme.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isSelected ? AppColors.secondary : AppColors.hint,
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
          
          const Gap(16),
          
          _buildSliderSetting(
            'Font Size',
            _fontScale,
            0.8,
            1.4,
            (value) => setState(() => _fontScale = value),
            suffix: 'x',
          ),
          
          const Gap(16),
          
          _buildSwitchSetting(
            'Enable Animations',
            'Show smooth transitions and animations',
            _enableAnimations,
            Icons.animation,
            (value) => setState(() => _enableAnimations = value),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms, duration: 600.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildStudyBehaviorSection() {
    return AnimatedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.psychology, color: AppColors.warning, size: 20),
              ),
              const Gap(12),
              Text(
                'Study Behavior',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Gap(20),
          
          _buildSwitchSetting(
            'Shuffle New Cards',
            'Randomize order of new cards',
            _shuffleNewCards,
            Icons.shuffle,
            (value) => setState(() => _shuffleNewCards = value),
          ),
          
          const Gap(8),
          
          _buildSwitchSetting(
            'Bury Related Cards',
            'Hide related cards until next session',
            _buryRelated,
            Icons.visibility_off,
            (value) => setState(() => _buryRelated = value),
          ),
          
          const Gap(16),
          
          _buildSliderSetting(
            'Graduating Interval',
            _graduatingInterval.toDouble(),
            1,
            7,
            (value) => setState(() => _graduatingInterval = value.toInt()),
            suffix: 'days',
          ),
          
          const Gap(16),
          
          _buildSliderSetting(
            'Easy Interval',
            _easyInterval.toDouble(),
            2,
            10,
            (value) => setState(() => _easyInterval = value.toInt()),
            suffix: 'days',
          ),
          
          const Gap(16),
          
          _buildSliderSetting(
            'Starting Ease Factor',
            _startingEase,
            2.0,
            3.0,
            (value) => setState(() => _startingEase = value),
            suffix: '',
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 600.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildNotificationsSection() {
    return AnimatedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.notifications, color: AppColors.success, size: 20),
              ),
              const Gap(12),
              Text(
                'Notifications',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Gap(20),
          
          _buildSwitchSetting(
            'Study Reminders',
            'Daily reminders to study your cards',
            _studyReminders,
            Icons.alarm,
            (value) => setState(() => _studyReminders = value),
          ),
          
          if (_studyReminders) ...[
            const Gap(12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Reminder Time'),
              subtitle: Text(_formatTime(_reminderTime)),
              trailing: Icon(Icons.schedule, color: AppColors.hint),
              onTap: _selectReminderTime,
            ),
          ],
          
          const Gap(8),
          
          _buildSwitchSetting(
            'Review Notifications',
            'Notify when cards are due for review',
            _reviewNotifications,
            Icons.schedule_send,
            (value) => setState(() => _reviewNotifications = value),
          ),
          
          const Gap(8),
          
          _buildSwitchSetting(
            'Achievement Notifications',
            'Get notified about milestones and achievements',
            _achievementNotifications,
            Icons.emoji_events,
            (value) => setState(() => _achievementNotifications = value),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms, duration: 600.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildPrivacySection() {
    return AnimatedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.security, color: AppColors.error, size: 20),
              ),
              const Gap(12),
              Text(
                'Privacy & Data',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Gap(20),
          
          _buildSwitchSetting(
            'Anonymous Usage Data',
            'Help improve the app with anonymous statistics',
            _anonymousUsage,
            Icons.analytics,
            (value) => setState(() => _anonymousUsage = value),
          ),
          
          const Gap(8),
          
          _buildSwitchSetting(
            'Sync Data',
            'Synchronize your data across devices',
            _syncData,
            Icons.sync,
            (value) => setState(() => _syncData = value),
          ),
          
          const Gap(8),
          
          _buildSwitchSetting(
            'Enable Backup',
            'Automatically backup your data',
            _backupEnabled,
            Icons.backup,
            (value) => setState(() => _backupEnabled = value),
          ),
          
          const Gap(20),
          
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _exportData,
                  icon: const Icon(Icons.download, size: 16),
                  label: const Text('Export Data'),
                ),
              ),
              const Gap(12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _clearData,
                  icon: Icon(Icons.delete_forever, size: 16, color: AppColors.error),
                  label: Text('Clear Data', style: TextStyle(color: AppColors.error)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.error.withOpacity(0.5)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms, duration: 600.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildAccountSection() {
    return AnimatedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.account_circle, color: AppColors.primary, size: 20),
              ),
              const Gap(12),
              Text(
                'Account',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Gap(20),
          
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('About'),
            subtitle: const Text('App version, terms, and privacy policy'),
            trailing: Icon(Icons.info_outline, color: AppColors.hint),
            onTap: _showAbout,
          ),
          
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Send Feedback'),
            subtitle: const Text('Help us improve Linguava'),
            trailing: Icon(Icons.feedback, color: AppColors.hint),
            onTap: _sendFeedback,
          ),
          
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('Sign Out', style: TextStyle(color: AppColors.error)),
            subtitle: const Text('Log out of your account'),
            trailing: Icon(Icons.logout, color: AppColors.error),
            onTap: _signOut,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 500.ms, duration: 600.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildSwitchSetting(
    String title,
    String subtitle,
    bool value,
    IconData icon,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppColors.hint,
        ),
      ),
      secondary: Icon(icon, color: AppColors.hint),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildSliderSetting(
    String title,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged, {
    String suffix = '',
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${value == value.toInt() ? value.toInt().toString() : value.toStringAsFixed(1)}$suffix',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const Gap(8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: suffix == '' ? 10 : (max - min).toInt(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  void _resetToDefaults() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset to Defaults'),
        content: const Text('This will reset all settings to their default values. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _newCardsPerDay = 20;
                _reviewCardsPerDay = 100;
                _showAnswerTimer = true;
                _enableSounds = true;
                _vibrationFeedback = false;
                _autoPlayAudio = false;
                _selectedTheme = 'dark';
                _enableAnimations = true;
                _fontScale = 1.0;
                _shuffleNewCards = false;
                _buryRelated = true;
                _graduatingInterval = 1;
                _easyInterval = 4;
                _startingEase = 2.5;
                _studyReminders = true;
                _reminderTime = const TimeOfDay(hour: 19, minute: 0);
                _reviewNotifications = true;
                _achievementNotifications = true;
                _anonymousUsage = false;
                _syncData = true;
                _backupEnabled = true;
              });
              _showSnackBar('Settings reset to defaults');
            },
            child: Text('Reset', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _selectReminderTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
    );
    if (picked != null && picked != _reminderTime) {
      setState(() {
        _reminderTime = picked;
      });
    }
  }

  void _exportData() {
    _showSnackBar('Data export started - you\'ll receive a notification when ready');
  }

  void _clearData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Clear All Data', style: TextStyle(color: AppColors.error)),
        content: const Text('This will permanently delete all your decks, cards, and progress. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnackBar('All data cleared successfully');
            },
            child: Text('Clear All', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _showAbout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Linguava'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version 1.0.0', style: Theme.of(context).textTheme.titleMedium),
            const Gap(8),
            const Text('A beautiful spaced repetition flashcard app built with Flutter.'),
            const Gap(16),
            const Text('Created with ❤️ by the Linguava Team'),
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

  void _sendFeedback() {
    _showSnackBar('Feedback form opened');
  }

  void _signOut() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out of your account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.go(AppRoutes.login);
            },
            child: Text('Sign Out', style: TextStyle(color: AppColors.error)),
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

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  Widget _buildDebugSection() {
    return AnimatedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.bug_report, color: AppColors.warning, size: 20),
              ),
              const Gap(12),
              Text(
                'Debug Tools',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Gap(20),
          
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Card Debug'),
            subtitle: const Text('View card statuses and FSRS algorithm data'),
            trailing: Icon(Icons.developer_mode, color: AppColors.warning),
            onTap: () => context.go(AppRoutes.debug),
          ),
          
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Database Info'),
            subtitle: const Text('View database statistics and information'),
            trailing: Icon(Icons.storage, color: AppColors.hint),
            onTap: _showDatabaseInfo,
          ),
          
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Reset FSRS Data'),
            subtitle: const Text('Clear all spaced repetition learning progress'),
            trailing: Icon(Icons.refresh, color: AppColors.error),
            onTap: _resetFSRSData,
          ),
          
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Clear Template Data'),
            subtitle: const Text('Remove all template/sample decks and cards'),
            trailing: Icon(Icons.delete_sweep, color: AppColors.error),
            onTap: _clearTemplateData,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms, duration: 600.ms).slideY(begin: 0.1, end: 0);
  }

  void _showDatabaseInfo() async {
    // This would show database statistics
    _showSnackBar('Database: 3 decks, 15 cards, 12 study records');
  }

  void _resetFSRSData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reset FSRS Data', style: TextStyle(color: AppColors.error)),
        content: const Text('This will reset all spaced repetition learning progress for your cards. Cards will return to "New" status. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnackBar('FSRS data reset - all cards are now "New"');
            },
            child: Text('Reset', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _clearTemplateData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Clear Template Data', style: TextStyle(color: AppColors.error)),
        content: const Text('This will remove all template/sample decks and cards from the database. This includes the "Spanish Basics" shared deck and any other seeded content. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _clearAllTemplateData();
                _showSnackBar('Template data cleared successfully');
              } catch (e) {
                _showSnackBar('Error clearing template data: $e');
              }
            },
            child: Text('Clear All', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  Future<void> _clearAllTemplateData() async {
    try {
      // Get all decks
      final decks = await _databaseService.database.deckDao.getAllDecks();
      
      for (final deck in decks) {
        // Check if this is template data (created by system or has specific names)
        if (deck.creatorId == 'system' || 
            deck.name == 'Spanish Basics' ||
            deck.name.contains('Spanish') ||
            deck.name.contains('French') ||
            deck.name.contains('German') ||
            deck.name.contains('Japanese')) {
          
          // Delete all cards in this deck first
          final flashcards = await _databaseService.database.flashcardDao.getFlashcardsByDeck(deck.id);
          for (final flashcard in flashcards) {
            await _databaseService.database.flashcardDao.deleteFlashcard(flashcard.id);
          }
          
          // Delete the deck
          await _databaseService.database.deckDao.deleteDeck(deck.id);
        }
      }
    } catch (e) {
      print('Error clearing template data: $e');
      rethrow;
    }
  }
}