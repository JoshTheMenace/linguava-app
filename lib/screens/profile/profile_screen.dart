import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import '../../core/constants/app_routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/animated_card.dart';
import '../../widgets/common/gradient_button.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  
  // Mock user data
  final String _userName = 'Sarah Johnson';
  final String _userEmail = 'sarah.johnson@email.com';
  final String _joinDate = 'January 2024';
  final String _profileImageUrl = '';
  
  // Stats
  final int _totalDecks = 12;
  final int _totalCards = 2450;
  final int _studyStreak = 23;
  final int _totalStudyTime = 147; // hours
  final double _averageAccuracy = 87.5;
  
  // Achievements
  final List<Map<String, dynamic>> _achievements = [
    {
      'title': 'First Steps',
      'description': 'Created your first deck',
      'icon': Icons.baby_changing_station,
      'color': Colors.blue,
      'unlocked': true,
      'date': '2024-01-15',
    },
    {
      'title': 'Study Streak 7',
      'description': 'Studied for 7 consecutive days',
      'icon': Icons.local_fire_department,
      'color': Colors.orange,
      'unlocked': true,
      'date': '2024-02-01',
    },
    {
      'title': 'Master Learner',
      'description': 'Achieved 90% accuracy on 100 cards',
      'icon': Icons.school,
      'color': Colors.green,
      'unlocked': true,
      'date': '2024-02-15',
    },
    {
      'title': 'Speed Demon',
      'description': 'Completed a deck in under 5 minutes',
      'icon': Icons.flash_on,
      'color': Colors.yellow,
      'unlocked': true,
      'date': '2024-02-20',
    },
    {
      'title': 'Polyglot',
      'description': 'Study 5 different languages',
      'icon': Icons.language,
      'color': Colors.purple,
      'unlocked': false,
      'progress': 3,
      'target': 5,
    },
    {
      'title': 'Study Streak 30',
      'description': 'Study for 30 consecutive days',
      'icon': Icons.local_fire_department,
      'color': Colors.red,
      'unlocked': false,
      'progress': 23,
      'target': 30,
    },
  ];
  
  // Recent Activity
  final List<Map<String, dynamic>> _recentActivity = [
    {
      'action': 'Completed study session',
      'deck': 'Spanish Basics',
      'time': '2 hours ago',
      'icon': Icons.check_circle,
      'color': Colors.green,
    },
    {
      'action': 'Created new deck',
      'deck': 'French Verbs',
      'time': '1 day ago',
      'icon': Icons.add_circle,
      'color': Colors.blue,
    },
    {
      'action': 'Achieved 90% accuracy',
      'deck': 'German Vocabulary',
      'time': '2 days ago',
      'icon': Icons.star,
      'color': Colors.orange,
    },
    {
      'action': 'Completed study session',
      'deck': 'Japanese Kanji',
      'time': '3 days ago',
      'icon': Icons.check_circle,
      'color': Colors.green,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleSignOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(authProvider.notifier).signOut();
      if (mounted) {
        context.go(AppRoutes.home);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    
    if (kDebugMode) {
      print('=== PROFILE SCREEN AUTH STATE ===');
      print('Is authenticated: ${authState.isAuthenticated}');
      print('Is loading: ${authState.isLoading}');
      print('Has completed onboarding: ${authState.hasCompletedOnboarding}');
      print('User profile: ${authState.userProfile}');
    }
    
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
          child: authState.isAuthenticated 
              ? _buildAuthenticatedProfile()
              : _buildAuthPrompt(),
        ),
      ),
    );
  }

  Widget _buildAuthenticatedProfile() {
    return Column(
      children: [
        _buildAppBar(),
        _buildProfileHeader(),
        _buildTabBar(),
        Expanded(
          child: _buildTabContent(),
        ),
      ],
    );
  }

  Widget _buildAuthPrompt() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          _buildAppBar(),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [AppColors.secondary, AppColors.primary],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.secondary.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.person_outline,
                      size: 64,
                      color: Colors.white,
                    ),
                  )
                      .animate()
                      .scale(duration: 800.ms, curve: Curves.elasticOut)
                      .fadeIn(duration: 600.ms),
                  
                  const Gap(32),
                  
                  Text(
                    'Sign In to View Profile',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  )
                      .animate()
                      .fadeIn(delay: 400.ms, duration: 600.ms)
                      .slideY(begin: 0.3, end: 0),
                  
                  const Gap(16),
                  
                  Text(
                    'Access your learning progress, achievements, and personalized insights by signing in to your account.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  )
                      .animate()
                      .fadeIn(delay: 600.ms, duration: 600.ms)
                      .slideY(begin: 0.3, end: 0),
                  
                  const Gap(48),
                  
                  Row(
                    children: [
                      Expanded(
                        child: GradientButton(
                          onPressed: () => context.go(AppRoutes.login),
                          text: 'Sign In',
                        ),
                      ),
                      const Gap(16),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => context.go(AppRoutes.signup),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(color: AppColors.primary),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
                            ),
                          ),
                          child: Text(
                            'Create Account',
                            style: TextStyle(color: AppColors.primary),
                          ),
                        ),
                      ),
                    ],
                  )
                      .animate()
                      .fadeIn(delay: 800.ms, duration: 600.ms)
                      .slideY(begin: 0.3, end: 0),
                  
                  const Gap(24),
                  
                  TextButton(
                    onPressed: () => context.go(AppRoutes.home),
                    child: Text(
                      'Continue Browsing',
                      style: TextStyle(
                        color: AppColors.hint,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 1000.ms, duration: 600.ms),
                ],
              ),
            ),
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
            onPressed: () => context.go(AppRoutes.home),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.surfaceVariant,
            ),
          ),
          const Gap(16),
          Expanded(
            child: Text(
              'Profile',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            onPressed: () => context.go(AppRoutes.settings),
            icon: const Icon(Icons.settings, color: Colors.white),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.surfaceVariant,
            ),
          ),
          const Gap(8),
          IconButton(
            onPressed: () => _handleSignOut(),
            icon: const Icon(Icons.logout, color: Colors.white),
            style: IconButton.styleFrom(
              backgroundColor: Colors.red.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    final authState = ref.watch(authProvider);
    final userName = authState.userProfile?['full_name'] ?? _userName;
    final userEmail = authState.userProfile?['email'] ?? _userEmail;
    
    return AnimatedCard(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        children: [
          Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      userName.split(' ').map((name) => name[0]).join('').toUpperCase(),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.surface, width: 2),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const Gap(20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Gap(4),
                    Text(
                      userEmail,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.hint,
                      ),
                    ),
                    const Gap(4),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 16, color: AppColors.hint),
                        const Gap(4),
                        Text(
                          'Joined $_joinDate',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.hint,
                          ),
                        ),
                      ],
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
                child: _buildStatItem('Decks', _totalDecks.toString(), Icons.folder),
              ),
              Expanded(
                child: _buildStatItem('Cards', _totalCards.toString(), Icons.style),
              ),
              Expanded(
                child: _buildStatItem('Streak', '${_studyStreak}d', Icons.local_fire_department),
              ),
              Expanded(
                child: _buildStatItem('Hours', _totalStudyTime.toString(), Icons.schedule),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 0.ms, duration: 600.ms).slideY(begin: -0.1, end: 0);
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary, size: 24),
        ),
        const Gap(8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
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
          Tab(text: 'Overview'),
          Tab(text: 'Achievements'),
          Tab(text: 'Activity'),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildOverviewTab(),
        _buildAchievementsTab(),
        _buildActivityTab(),
      ],
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        children: [
          AnimatedCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Learning Progress',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Gap(20),
                
                _buildProgressItem(
                  'Overall Accuracy',
                  _averageAccuracy / 100,
                  '${_averageAccuracy.toStringAsFixed(1)}%',
                  AppColors.success,
                ),
                
                const Gap(16),
                
                _buildProgressItem(
                  'Weekly Goal Progress',
                  0.73,
                  '73%',
                  AppColors.primary,
                ),
                
                const Gap(16),
                
                _buildProgressItem(
                  'Monthly Cards Studied',
                  0.65,
                  '650 / 1000',
                  AppColors.warning,
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
                  'Study Insights',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Gap(16),
                
                _buildInsightItem(
                  'Most Active Time',
                  '7:00 PM - 9:00 PM',
                  Icons.schedule,
                  AppColors.primary,
                ),
                
                _buildInsightItem(
                  'Favorite Language',
                  'Spanish (42% of time)',
                  Icons.language,
                  AppColors.secondary,
                ),
                
                _buildInsightItem(
                  'Average Session',
                  '15 minutes',
                  Icons.timer,
                  AppColors.success,
                ),
                
                _buildInsightItem(
                  'Best Streak',
                  '31 days',
                  Icons.local_fire_department,
                  AppColors.warning,
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Achievements',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () => _tabController.animateTo(1),
                      child: const Text('View All'),
                    ),
                  ],
                ),
                const Gap(16),
                
                ..._achievements.where((a) => a['unlocked'] == true).take(3).map((achievement) {
                  return _buildMiniAchievementCard(achievement);
                }),
              ],
            ),
          ),
          
          const Gap(24),
        ],
      ),
    );
  }

  Widget _buildProgressItem(String label, double progress, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
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

  Widget _buildInsightItem(String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const Gap(16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.hint,
                  ),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniAchievementCard(Map<String, dynamic> achievement) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: achievement['color'].withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              achievement['icon'],
              color: achievement['color'],
              size: 20,
            ),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement['title'],
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  achievement['date'],
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.hint,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Achievements',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_achievements.where((a) => a['unlocked'] == true).length} / ${_achievements.length}',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          
          const Gap(16),
          
          ..._achievements.asMap().entries.map((entry) {
            final index = entry.key;
            final achievement = entry.value;
            return _buildAchievementCard(achievement, index);
          }),
          
          const Gap(24),
        ],
      ),
    );
  }

  Widget _buildAchievementCard(Map<String, dynamic> achievement, int index) {
    final isUnlocked = achievement['unlocked'] == true;
    
    return AnimatedCard(
      animationDelay: Duration(milliseconds: 100 * index),
      margin: const EdgeInsets.only(bottom: 12),
      child: Opacity(
        opacity: isUnlocked ? 1.0 : 0.6,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isUnlocked 
                    ? achievement['color'].withOpacity(0.2)
                    : AppColors.divider.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                achievement['icon'],
                color: isUnlocked ? achievement['color'] : AppColors.hint,
                size: 32,
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
                          achievement['title'],
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isUnlocked ? Colors.white : AppColors.hint,
                          ),
                        ),
                      ),
                      if (isUnlocked)
                        Icon(Icons.check_circle, color: achievement['color'], size: 20),
                    ],
                  ),
                  const Gap(4),
                  Text(
                    achievement['description'],
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.hint,
                    ),
                  ),
                  if (!isUnlocked && achievement.containsKey('progress')) ...[
                    const Gap(8),
                    Row(
                      children: [
                        Expanded(
                          child: LinearProgressIndicator(
                            value: achievement['progress'] / achievement['target'],
                            backgroundColor: AppColors.divider,
                            valueColor: AlwaysStoppedAnimation<Color>(achievement['color']),
                            minHeight: 4,
                          ),
                        ),
                        const Gap(8),
                        Text(
                          '${achievement['progress']}/${achievement['target']}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: achievement['color'],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (isUnlocked && achievement.containsKey('date')) ...[
                    const Gap(4),
                    Text(
                      'Unlocked ${achievement['date']}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: achievement['color'],
                        fontWeight: FontWeight.w500,
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

  Widget _buildActivityTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Activity',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const Gap(16),
          
          ..._recentActivity.asMap().entries.map((entry) {
            final index = entry.key;
            final activity = entry.value;
            return _buildActivityCard(activity, index);
          }),
          
          const Gap(24),
          
          Center(
            child: OutlinedButton(
              onPressed: () {},
              child: const Text('Load More Activity'),
            ),
          ),
          
          const Gap(24),
        ],
      ),
    );
  }

  Widget _buildActivityCard(Map<String, dynamic> activity, int index) {
    return AnimatedCard(
      animationDelay: Duration(milliseconds: 100 * index),
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: activity['color'].withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              activity['icon'],
              color: activity['color'],
              size: 24,
            ),
          ),
          const Gap(16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity['action'],
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Gap(2),
                Text(
                  activity['deck'],
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                const Gap(2),
                Text(
                  activity['time'],
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.hint,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}