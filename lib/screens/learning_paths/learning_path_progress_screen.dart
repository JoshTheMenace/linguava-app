import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../widgets/common/gradient_button.dart';
import '../../widgets/common/loading_screen.dart';
import '../../providers/learning_path_provider.dart';
import '../../models/lesson.dart' as models;
import '../../models/user_lesson_progress.dart' as models;

class LearningPathProgressScreen extends ConsumerStatefulWidget {
  final String pathId;

  const LearningPathProgressScreen({
    super.key,
    required this.pathId,
  });

  @override
  ConsumerState<LearningPathProgressScreen> createState() => _LearningPathProgressScreenState();
}

class _LearningPathProgressScreenState extends ConsumerState<LearningPathProgressScreen> {
  @override
  Widget build(BuildContext context) {
    final pathAsync = ref.watch(learningPathProvider(widget.pathId));
    final lessonsAsync = ref.watch(pathLessonsProvider(widget.pathId));
    final progressAsync = ref.watch(pathProgressProvider(widget.pathId));

    return Scaffold(
      backgroundColor: const Color(0xFF1a237e), // Deep night sky blue
      body: Stack(
        children: [
          // Back button
          Positioned(
            top: 16 + MediaQuery.of(context).padding.top,
            left: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => context.pop(),
              ),
            ),
          ),
          // Path title
          Positioned(
            top: 16 + MediaQuery.of(context).padding.top,
            left: 0,
            right: 0,
            child: Center(
              child: pathAsync.when(
                data: (path) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    path?.name ?? 'Learning Path',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                loading: () => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Loading...',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                error: (_, __) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Error Loading Path',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
          // Main content
          pathAsync.when(
            loading: () => const LoadingScreen(),
            error: (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.white),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Failed to load learning path',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  GradientButton(
                    text: 'Retry',
                    onPressed: () => ref.refresh(learningPathProvider(widget.pathId)),
                  ),
                ],
              ),
            ),
            data: (path) {
              if (path == null) {
                return const Center(
                  child: Text('Learning path not found', style: TextStyle(color: Colors.white)),
                );
              }

              return lessonsAsync.when(
                loading: () => const LoadingScreen(),
                error: (error, stack) => Center(
                  child: Text('Failed to load lessons: $error', style: const TextStyle(color: Colors.white)),
                ),
                data: (lessons) {
                  // Get lesson progress instead of path progress
                  final lessonProgressAsync = ref.watch(lessonsProgressProvider(widget.pathId));
                  return lessonProgressAsync.when(
                    loading: () => const LoadingScreen(),
                    error: (error, stack) => _buildJapanMap(path, lessons, []),
                    data: (progressList) => _buildJapanMap(path, lessons, progressList),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildJapanMap(dynamic path, List<models.Lesson> lessons, List<models.UserLessonProgress> progressList) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF1a237e), // Deep night sky blue
            Color(0xFF3949ab), // Lighter blue
            Color(0xFF303f9f), // Medium blue
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        children: [
          // Stars background
          ..._buildStars(),
          // Lesson nodes positioned like a map of Japan
          ..._buildLessonNodes(lessons, progressList),
          // Progress overlay
          _buildProgressOverlay(path, lessons, progressList),
        ],
      ),
    );
  }

  List<Widget> _buildStars() {
    final random = math.Random(42); // Fixed seed for consistent stars
    return List.generate(100, (index) {
      return Positioned(
        left: random.nextDouble() * 400,
        top: random.nextDouble() * 800 + 100,
        child: Container(
          width: random.nextDouble() * 3 + 1,
          height: random.nextDouble() * 3 + 1,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.7),
            shape: BoxShape.circle,
          ),
        ),
      );
    });
  }

  List<Widget> _buildLessonNodes(List<models.Lesson> lessons, List<models.UserLessonProgress> progressList) {
    final japanPositions = _getJapanLessonPositions(lessons.length);
    
    return lessons.asMap().entries.map((entry) {
      final index = entry.key;
      final lesson = entry.value;
      final position = japanPositions[index % japanPositions.length];
      
      final progress = progressList.firstWhere(
        (p) => p.lessonId == lesson.id,
        orElse: () => models.UserLessonProgress(
          userId: '',
          lessonId: lesson.id,
          isCompleted: false,
          isUnlocked: index == 0,
          completedCards: 0,
          totalCards: 0,
          timeSpent: 0,
          startedAt: null,
          completedAt: null,
          updatedAt: DateTime.now(),
        ),
      );

      return _buildLessonNode(lesson, progress, position, index);
    }).toList();
  }

  List<Offset> _getJapanLessonPositions(int lessonCount) {
    // Positions roughly resembling Japan's geography (scaled for mobile screen)
    return [
      const Offset(0.7, 0.15),  // Hokkaido - Lesson 1
      const Offset(0.65, 0.25), // Northern Honshu - Lesson 2
      const Offset(0.6, 0.35),  // Tokyo area - Lesson 3
      const Offset(0.55, 0.4),  // Central Honshu - Lesson 4
      const Offset(0.5, 0.45),  // Nagoya area - Lesson 5
      const Offset(0.45, 0.5),  // Kansai region - Lesson 6
      const Offset(0.4, 0.55),  // Osaka/Kyoto - Lesson 7
      const Offset(0.35, 0.6),  // Western Honshu - Lesson 8
      const Offset(0.3, 0.65),  // Hiroshima area - Lesson 9
      const Offset(0.25, 0.7),  // Shikoku - Lesson 10
      const Offset(0.2, 0.75),  // Northern Kyushu - Lesson 11
      const Offset(0.15, 0.8),  // Central Kyushu - Lesson 12
      const Offset(0.1, 0.85),  // Southern Kyushu - Lesson 13
      const Offset(0.75, 0.3),  // Eastern coast - Lesson 14
      const Offset(0.8, 0.4),   // Far east - Lesson 15
      const Offset(0.85, 0.5),  // Eastern islands - Lesson 16
      const Offset(0.9, 0.6),   // Far eastern islands - Lesson 17
      const Offset(0.05, 0.9),  // Okinawa - Lesson 18
      const Offset(0.68, 0.2),  // Northern route - Lesson 19
      const Offset(0.72, 0.45), // Final destination - Lesson 20
    ];
  }

  Widget _buildLessonNode(models.Lesson lesson, models.UserLessonProgress progress, Offset position, int index) {
    final screenSize = MediaQuery.of(context).size;
    
    Color nodeColor;
    IconData nodeIcon;
    bool isInteractive = false;
    
    if (progress.isCompleted) {
      nodeColor = const Color(0xFF4CAF50); // Green
      nodeIcon = Icons.check_circle;
      isInteractive = true;
    } else if (progress.isUnlocked) {
      nodeColor = const Color(0xFFFFC107); // Amber
      nodeIcon = Icons.play_circle;
      isInteractive = true;
    } else {
      nodeColor = const Color(0xFF9E9E9E); // Grey
      nodeIcon = Icons.lock;
      isInteractive = false;
    }

    return Positioned(
      left: position.dx * screenSize.width - 30,
      top: position.dy * screenSize.height - 30,
      child: GestureDetector(
        onTap: isInteractive ? () => _showLessonDetails(lesson, progress) : null,
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: nodeColor,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: nodeColor.withOpacity(0.5),
                blurRadius: 15,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(nodeIcon, color: Colors.white, size: 24),
              if (isInteractive)
                Text(
                  '${index + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressOverlay(dynamic path, List<models.Lesson> lessons, List<models.UserLessonProgress> progressList) {
    final completedCount = progressList.where((p) => p.isCompleted).length;
    final totalCount = lessons.length;
    final progressPercentage = totalCount > 0 ? (completedCount / totalCount) * 100 : 0.0;

    return Positioned(
      bottom: 50,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(
              'Journey Progress',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$completedCount of $totalCount lessons completed',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progressPercentage / 100,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
            ),
            const SizedBox(height: 8),
            Text(
              '${progressPercentage.toStringAsFixed(1)}% Complete',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLessonDetails(models.Lesson lesson, models.UserLessonProgress progress) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1a237e),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              lesson.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              lesson.description,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildDetailChip(Icons.schedule, '${lesson.estimatedMinutes} min'),
                if (progress.totalCards > 0)
                  _buildDetailChip(Icons.style, '${progress.totalCards} cards'),
              ],
            ),
            const SizedBox(height: 20),
            GradientButton(
              text: progress.isCompleted ? 'Review Lesson' : 'Start Lesson',
              onPressed: () {
                Navigator.pop(context);
                context.push('/lesson/${lesson.id}');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

}