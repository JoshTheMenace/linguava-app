import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/constants/app_routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../widgets/common/animated_card.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = 'week';

  // Mock data for charts
  final Map<String, List<FlSpot>> _studyData = {
    'week': [
      const FlSpot(0, 12), // Monday
      const FlSpot(1, 25), // Tuesday
      const FlSpot(2, 18), // Wednesday
      const FlSpot(3, 32), // Thursday
      const FlSpot(4, 45), // Friday
      const FlSpot(5, 28), // Saturday
      const FlSpot(6, 15), // Sunday
    ],
    'month': [
      const FlSpot(0, 180),
      const FlSpot(1, 220),
      const FlSpot(2, 195),
      const FlSpot(3, 240),
    ],
    'year': [
      const FlSpot(0, 2400),
      const FlSpot(1, 2800),
      const FlSpot(2, 2600),
      const FlSpot(3, 3200),
    ],
  };

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
              _buildPeriodSelector(),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Learning Analytics',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Track your progress and insights',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.hint,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _showExportOptions(),
            icon: const Icon(Icons.file_download, color: Colors.white),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.surfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: ['week', 'month', 'year'].map((period) {
          final isSelected = _selectedPeriod == period;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedPeriod = period;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(
                            colors: [AppColors.primary, AppColors.secondary],
                          )
                        : null,
                    color: !isSelected ? AppColors.surfaceVariant : null,
                    borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
                  ),
                  child: Text(
                    period.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : AppColors.hint,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
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
          Tab(text: 'Overview'),
          Tab(text: 'Performance'),
          Tab(text: 'Insights'),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildOverviewTab(),
        _buildPerformanceTab(),
        _buildInsightsTab(),
      ],
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          _buildStatsOverview(),
          const Gap(20),
          _buildStudyChart(),
          const Gap(20),
          _buildStreakCard(),
          const Gap(20),
          _buildRecentActivity(),
        ],
      ),
    );
  }

  Widget _buildStatsOverview() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Cards Studied',
            '247',
            Icons.style,
            AppColors.primary,
            '+12% this week',
          ),
        ),
        const Gap(12),
        Expanded(
          child: _buildStatCard(
            'Time Studied',
            '8.5h',
            Icons.schedule,
            AppColors.secondary,
            '+5% this week',
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, String trend) {
    return AnimatedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
              Text(
                trend,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const Gap(16),
          Text(
            value,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.hint,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudyChart() {
    return AnimatedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Study Activity',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Gap(16),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 10,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: AppColors.divider,
                      strokeWidth: 0.5,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final titles = _getAxisTitles();
                        if (value.toInt() >= 0 && value.toInt() < titles.length) {
                          return Text(
                            titles[value.toInt()],
                            style: TextStyle(
                              color: AppColors.hint,
                              fontSize: 12,
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 10,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            color: AppColors.hint,
                            fontSize: 12,
                          ),
                        );
                      },
                      reservedSize: 30,
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (_studyData[_selectedPeriod]!.length - 1).toDouble(),
                minY: 0,
                maxY: _getMaxY(),
                lineBarsData: [
                  LineChartBarData(
                    spots: _studyData[_selectedPeriod]!,
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: AppColors.primary,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.primary.withOpacity(0.3),
                          AppColors.primary.withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakCard() {
    return AnimatedCard(
      backgroundColor: AppColors.primaryWithOpacity10,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.secondary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.local_fire_department,
              color: Colors.white,
              size: 32,
            ),
          ),
          const Gap(16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '12 Day Streak!',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  'Keep it up! Study tomorrow to maintain your streak.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            color: AppColors.primary,
            size: 16,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    return AnimatedCard(
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
          ..._getRecentActivities().map((activity) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: activity['color'] as Color,
                    shape: BoxShape.circle,
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: Text(
                    activity['text'] as String,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                Text(
                  activity['time'] as String,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.hint,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildPerformanceTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          _buildAccuracyChart(),
          const Gap(20),
          _buildDifficultyBreakdown(),
          const Gap(20),
          _buildDeckPerformance(),
        ],
      ),
    );
  }

  Widget _buildAccuracyChart() {
    return AnimatedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Accuracy Rate',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Gap(16),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    color: AppColors.success,
                    value: 78,
                    title: 'Correct\n78%',
                    radius: 60,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    color: AppColors.warning,
                    value: 15,
                    title: 'Hard\n15%',
                    radius: 60,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    color: AppColors.error,
                    value: 7,
                    title: 'Again\n7%',
                    radius: 60,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
                borderData: FlBorderData(show: false),
                sectionsSpace: 2,
                centerSpaceRadius: 40,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyBreakdown() {
    return AnimatedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Card Difficulty Breakdown',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Gap(16),
          _buildDifficultyBar('Easy', 0.65, AppColors.success),
          const Gap(8),
          _buildDifficultyBar('Medium', 0.25, AppColors.warning),
          const Gap(8),
          _buildDifficultyBar('Hard', 0.10, AppColors.error),
        ],
      ),
    );
  }

  Widget _buildDifficultyBar(String label, double percentage, Color color) {
    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.hint,
            ),
          ),
        ),
        Expanded(
          child: LinearProgressIndicator(
            value: percentage,
            backgroundColor: AppColors.divider,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
        const Gap(8),
        Text(
          '${(percentage * 100).round()}%',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildDeckPerformance() {
    final decks = [
      {'name': 'Spanish Basics', 'accuracy': 0.85, 'studied': 45},
      {'name': 'French Grammar', 'accuracy': 0.72, 'studied': 32},
      {'name': 'Business English', 'accuracy': 0.91, 'studied': 28},
    ];

    return AnimatedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Deck Performance',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Gap(16),
          ...decks.map((deck) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        deck['name'] as String,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${deck['studied']} cards studied',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.hint,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${((deck['accuracy'] as double) * 100).round()}%',
                    style: TextStyle(
                      color: AppColors.success,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildInsightsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          _buildInsightCard(
            'Peak Performance Time',
            '2:00 PM - 4:00 PM',
            'You perform 23% better during afternoon hours',
            Icons.access_time,
            AppColors.primary,
          ),
          const Gap(16),
          _buildInsightCard(
            'Best Learning Method',
            'Spaced Repetition',
            'Cards reviewed using FSRS show 40% better retention',
            Icons.psychology,
            AppColors.secondary,
          ),
          const Gap(16),
          _buildInsightCard(
            'Recommended Study Duration',
            '25-30 minutes',
            'Optimal session length based on your performance data',
            Icons.timer,
            AppColors.success,
          ),
          const Gap(16),
          _buildWeeklyGoals(),
          const Gap(16),
          _buildLanguageProgress(),
        ],
      ),
    );
  }

  Widget _buildInsightCard(String title, String value, String description, IconData icon, Color color) {
    return AnimatedCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const Gap(16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.hint,
                  ),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  description,
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

  Widget _buildWeeklyGoals() {
    return AnimatedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Weekly Goals',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '4/7 completed',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const Gap(16),
          LinearProgressIndicator(
            value: 4/7,
            backgroundColor: AppColors.divider,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            minHeight: 6,
          ),
          const Gap(12),
          Text(
            '3 more days to complete your weekly goal!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.hint,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageProgress() {
    final languages = [
      {'name': 'Spanish', 'progress': 0.78, 'level': 'Intermediate'},
      {'name': 'French', 'progress': 0.45, 'level': 'Beginner'},
      {'name': 'German', 'progress': 0.23, 'level': 'Beginner'},
    ];

    return AnimatedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Language Progress',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Gap(16),
          ...languages.map((lang) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      lang['name'] as String,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      lang['level'] as String,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.hint,
                      ),
                    ),
                  ],
                ),
                const Gap(8),
                LinearProgressIndicator(
                  value: lang['progress'] as double,
                  backgroundColor: AppColors.divider,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  minHeight: 4,
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  void _showExportOptions() {
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
              'Export Options',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Gap(16),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('Export as PDF'),
              onTap: () {
                Navigator.pop(context);
                _showSnackBar('PDF export started');
              },
            ),
            ListTile(
              leading: const Icon(Icons.table_chart),
              title: const Text('Export as CSV'),
              onTap: () {
                Navigator.pop(context);
                _showSnackBar('CSV export started');
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share Report'),
              onTap: () {
                Navigator.pop(context);
                _showSnackBar('Report shared');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  List<String> _getAxisTitles() {
    switch (_selectedPeriod) {
      case 'week':
        return ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      case 'month':
        return ['Week 1', 'Week 2', 'Week 3', 'Week 4'];
      case 'year':
        return ['Q1', 'Q2', 'Q3', 'Q4'];
      default:
        return [];
    }
  }

  double _getMaxY() {
    final spots = _studyData[_selectedPeriod]!;
    final maxValue = spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);
    return (maxValue * 1.2).ceilToDouble();
  }

  List<Map<String, dynamic>> _getRecentActivities() {
    return [
      {
        'text': 'Completed Spanish Basics deck',
        'time': '2 hours ago',
        'color': AppColors.success,
      },
      {
        'text': 'Achieved 7-day streak',
        'time': '1 day ago',
        'color': AppColors.secondary,
      },
      {
        'text': 'Added 15 new cards to French Grammar',
        'time': '2 days ago',
        'color': AppColors.primary,
      },
      {
        'text': 'Reached 85% accuracy in Business English',
        'time': '3 days ago',
        'color': AppColors.success,
      },
    ];
  }
}