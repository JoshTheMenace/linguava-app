import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../models/study_card.dart';

class StudyGradeButtons extends StatelessWidget {
  final Function(StudyGrade) onGradeSelected;
  final bool isVisible;
  final Map<StudyGrade, String> nextReviewTimes;

  const StudyGradeButtons({
    super.key,
    required this.onGradeSelected,
    this.isVisible = true,
    this.nextReviewTimes = const {},
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.surface.withOpacity(0.0),
            AppColors.surface.withOpacity(0.9),
            AppColors.surface,
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'How well did you know this card?',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const Gap(16),
            Row(
              children: [
                Expanded(
                  child: _buildGradeButton(
                    context,
                    grade: StudyGrade.again,
                    label: 'Again',
                    icon: Icons.refresh,
                    color: AppColors.error,
                    nextReview: nextReviewTimes[StudyGrade.again] ?? '<1m',
                  ),
                ),
                const Gap(8),
                Expanded(
                  child: _buildGradeButton(
                    context,
                    grade: StudyGrade.hard,
                    label: 'Hard',
                    icon: Icons.trending_down,
                    color: AppColors.warning,
                    nextReview: nextReviewTimes[StudyGrade.hard] ?? '6m',
                  ),
                ),
                const Gap(8),
                Expanded(
                  child: _buildGradeButton(
                    context,
                    grade: StudyGrade.good,
                    label: 'Good',
                    icon: Icons.thumb_up,
                    color: AppColors.primary,
                    nextReview: nextReviewTimes[StudyGrade.good] ?? '1d',
                  ),
                ),
                const Gap(8),
                Expanded(
                  child: _buildGradeButton(
                    context,
                    grade: StudyGrade.easy,
                    label: 'Easy',
                    icon: Icons.trending_up,
                    color: AppColors.success,
                    nextReview: nextReviewTimes[StudyGrade.easy] ?? '4d',
                  ),
                ),
              ],
            ),
            const Gap(8),
            Text(
              'Based on FSRS algorithm for optimal memory retention',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.hint,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    )
        .animate()
        .slideY(begin: 1, duration: 300.ms, curve: Curves.easeOut)
        .fadeIn(duration: 200.ms);
  }

  Widget _buildGradeButton(
    BuildContext context, {
    required StudyGrade grade,
    required String label,
    required IconData icon,
    required Color color,
    required String nextReview,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onGradeSelected(grade),
        borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: color,
                size: 24,
              ),
              const Gap(4),
              Text(
                label,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Gap(2),
              Text(
                nextReview,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color.withOpacity(0.8),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StudyProgressBar extends StatelessWidget {
  final int currentCard;
  final int totalCards;
  final int newCards;
  final int learningCards;
  final int reviewCards;

  const StudyProgressBar({
    super.key,
    required this.currentCard,
    required this.totalCards,
    this.newCards = 0,
    this.learningCards = 0,
    this.reviewCards = 0,
  });

  @override
  Widget build(BuildContext context) {
    final progress = totalCards > 0 ? currentCard / totalCards : 0.0;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '$currentCard / $totalCards',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Gap(12),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.divider,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            minHeight: 6,
          ),
          const Gap(12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildProgressStat(
                context,
                'New',
                newCards,
                AppColors.secondary,
              ),
              _buildProgressStat(
                context,
                'Learning',
                learningCards,
                AppColors.warning,
              ),
              _buildProgressStat(
                context,
                'Review',
                reviewCards,
                AppColors.success,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressStat(
    BuildContext context,
    String label,
    int count,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            count.toString(),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const Gap(4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.hint,
          ),
        ),
      ],
    );
  }
}