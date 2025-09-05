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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Deck> _mockDecks = [
    Deck(
      id: '1',
      name: 'Spanish Basics',
      description: 'Essential Spanish vocabulary for beginners',
      totalCards: 150,
      reviewedCards: 89,
      masteredCards: 45,
      language: 'Spanish',
      difficulty: 'Beginner',
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      updatedAt: DateTime.now(),
      creatorId: 'user1',
      tags: ['Spanish', 'Vocabulary', 'Beginner'],
    ),
    Deck(
      id: '2',
      name: 'French Grammar',
      description: 'Master French grammar rules and exceptions',
      totalCards: 200,
      reviewedCards: 156,
      masteredCards: 98,
      language: 'French',
      difficulty: 'Intermediate',
      createdAt: DateTime.now().subtract(const Duration(days: 14)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      creatorId: 'user1',
      tags: ['French', 'Grammar', 'Intermediate'],
    ),
    Deck(
      id: '3',
      name: 'Business English',
      description: 'Professional English vocabulary and phrases',
      totalCards: 120,
      reviewedCards: 45,
      masteredCards: 12,
      language: 'English',
      difficulty: 'Advanced',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      updatedAt: DateTime.now(),
      creatorId: 'user1',
      tags: ['English', 'Business', 'Advanced'],
    ),
  ];

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
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.style,
            title: 'Total Cards',
            value: '470',
            color: AppColors.primary,
          ),
        ),
        const Gap(12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.trending_up,
            title: 'Streak',
            value: '12 days',
            color: AppColors.secondary,
          ),
        ),
        const Gap(12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.school,
            title: 'Mastered',
            value: '155',
            color: AppColors.success,
          ),
        ),
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
                onPressed: () {
                  context.go(AppRoutes.study);
                },
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
        ...List.generate(
          _mockDecks.length,
          (index) => _buildDeckCard(_mockDecks[index], index),
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
}