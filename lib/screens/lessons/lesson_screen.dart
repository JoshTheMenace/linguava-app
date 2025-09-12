import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../widgets/common/gradient_button.dart';
import '../../widgets/common/loading_screen.dart';
import '../../models/lesson.dart' as models;
import '../../models/lesson_content.dart';
import '../lessons/widgets/lesson_content_widgets.dart';
import '../../providers/lesson_content_provider.dart';
import '../../providers/learning_path_provider.dart';

class LessonScreen extends ConsumerStatefulWidget {
  final String lessonId;
  final String? pathId;

  const LessonScreen({
    super.key,
    required this.lessonId,
    this.pathId,
  });

  @override
  ConsumerState<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends ConsumerState<LessonScreen> {
  int currentContentIndex = 0;
  Map<String, dynamic> userAnswers = {};
  bool isContentComplete = false;

  @override
  Widget build(BuildContext context) {
    final lessonAsync = ref.watch(lessonProvider(widget.lessonId));
    final contentAsync = ref.watch(lessonContentProvider(widget.lessonId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.onBackground,
        elevation: 0,
        title: lessonAsync.when(
          data: (lesson) => Text(lesson?.name ?? 'Lesson'),
          loading: () => const Text('Loading...'),
          error: (_, __) => const Text('Lesson'),
        ),
        actions: [
          // Progress indicator
          contentAsync.when(
            data: (contentData) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: Text(
                  '${currentContentIndex + 1}/${contentData?.contents.length ?? 0}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: contentAsync.when(
        loading: () => const LoadingScreen(),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppColors.error),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Failed to load lesson content',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              GradientButton(
                text: 'Retry',
                onPressed: () => ref.refresh(lessonContentProvider(widget.lessonId)),
              ),
            ],
          ),
        ),
        data: (contentData) {
          if (contentData == null || contentData.contents.isEmpty) {
            return _buildEmptyContent();
          }

          return Column(
            children: [
              // Progress bar
              _buildProgressBar(contentData.contents.length),
              
              // Content area
              Expanded(
                child: _buildContentArea(contentData),
              ),
              
              // Navigation buttons
              _buildNavigationButtons(contentData),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProgressBar(int totalContents) {
    final progress = totalContents > 0 ? (currentContentIndex + 1) / totalContents : 0.0;
    
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.onBackground.withOpacity(0.7),
                ),
              ),
              Text(
                '${(progress * 100).round()}%',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.outline.withOpacity(0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildContentArea(LessonContentData contentData) {
    if (currentContentIndex >= contentData.contents.length) {
      return _buildLessonComplete();
    }

    final content = contentData.contents[currentContentIndex];
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: SingleChildScrollView(
        child: LessonContentWidget(
          key: ValueKey('${content.id}_$currentContentIndex'),
          content: content,
          onAnswerChanged: (answer) {
            setState(() {
              userAnswers[content.id] = answer;
              _checkIfContentComplete(content);
            });
          },
          userAnswer: userAnswers[content.id],
        ),
      ),
    );
  }

  Widget _buildNavigationButtons(LessonContentData contentData) {
    final isFirstContent = currentContentIndex == 0;
    final isLastContent = currentContentIndex >= contentData.contents.length - 1;
    
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(
            color: AppColors.outline.withOpacity(0.3),
          ),
        ),
      ),
      child: Row(
        children: [
          // Previous button
          if (!isFirstContent)
            Expanded(
              child: OutlinedButton(
                onPressed: _goToPreviousContent,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Previous'),
              ),
            ),
          
          if (!isFirstContent) const SizedBox(width: AppSpacing.md),
          
          // Next button
          Expanded(
            child: GradientButton(
              text: isLastContent ? 'Complete Lesson' : 'Next',
              onPressed: isContentComplete || _isContentTypeViewOnly() ? _goToNextContent : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.school_outlined, size: 64, color: AppColors.outline),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No content available',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'This lesson doesn\'t have content yet.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.onBackground.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          GradientButton(
            text: 'Go Back',
            onPressed: () => context.pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonComplete() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: const BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check,
              color: Colors.white,
              size: 50,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Lesson Complete!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.success,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Great job! You\'ve completed this lesson.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.onBackground.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              OutlinedButton(
                onPressed: () => context.pop(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                ),
                child: const Text('Back to Map'),
              ),
              GradientButton(
                text: 'Continue Journey',
                onPressed: () {
                  _completeLesson();
                  context.pop();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _goToPreviousContent() {
    if (currentContentIndex > 0) {
      setState(() {
        currentContentIndex--;
        isContentComplete = false;
      });
    }
  }

  void _goToNextContent() {
    final contentAsync = ref.read(lessonContentProvider(widget.lessonId));
    contentAsync.whenData((contentData) {
      if (contentData != null) {
        if (currentContentIndex < contentData.contents.length - 1) {
          setState(() {
            currentContentIndex++;
            isContentComplete = false;
          });
        } else {
          // Lesson complete
          _completeLesson();
        }
      }
    });
  }

  void _checkIfContentComplete(LessonContent content) {
    final answer = userAnswers[content.id];
    
    switch (content.type) {
      case LessonContentType.explanation:
        // Explanations are always "complete" when viewed
        isContentComplete = true;
        break;
      case LessonContentType.flashcard:
        // Flashcards are complete when user has seen both sides
        isContentComplete = answer != null;
        break;
      case LessonContentType.multipleChoice:
        // Multiple choice is complete when an answer is selected
        isContentComplete = answer != null;
        break;
      case LessonContentType.fillInBlank:
        // Fill in blank is complete when all blanks are filled
        final fillContent = content as FillInBlankContent;
        final answers = answer as List<String>?;
        isContentComplete = answers != null && 
          answers.length == fillContent.answers.length &&
          answers.every((a) => a.isNotEmpty);
        break;
      case LessonContentType.matching:
        // Matching is complete when all pairs are matched
        final matches = answer as Map<String, String>?;
        final matchContent = content as MatchingContent;
        isContentComplete = matches != null && 
          matches.length == matchContent.pairs.length;
        break;
    }
  }

  bool _isContentTypeViewOnly() {
    final contentAsync = ref.read(lessonContentProvider(widget.lessonId));
    return contentAsync.when(
      data: (contentData) {
        if (contentData == null || currentContentIndex >= contentData.contents.length) {
          return false;
        }
        final content = contentData.contents[currentContentIndex];
        return content.type == LessonContentType.explanation;
      },
      loading: () => false,
      error: (_, __) => false,
    );
  }

  void _completeLesson() async {
    try {
      // Mark lesson as complete in the learning path service
      final learningPathService = ref.read(learningPathServiceProvider);
      await learningPathService.completeLesson('current_user', widget.lessonId);
      
      // Add flashcard content to SRS system
      final contentAsync = ref.read(lessonContentProvider(widget.lessonId));
      contentAsync.whenData((contentData) async {
        if (contentData != null) {
          for (final content in contentData.contents) {
            if (content.type == LessonContentType.flashcard) {
              final flashcard = content as FlashcardContent;
              // TODO: Create flashcard in SRS system from lesson content
              print('Adding flashcard to SRS: ${flashcard.front} -> ${flashcard.back}');
            }
          }
        }
      });
      
      print('Lesson completed: ${widget.lessonId}');
      
      // Show completion snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lesson completed! New cards added to your review deck.'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (error) {
      print('Error completing lesson: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error completing lesson: $error'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}