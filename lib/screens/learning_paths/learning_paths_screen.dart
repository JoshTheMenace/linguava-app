import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_routes.dart';
import '../../widgets/common/gradient_button.dart';
import '../../widgets/common/loading_screen.dart';
import '../../providers/learning_path_provider.dart';
import '../../models/learning_path.dart' as models;
import '../../models/user_path_progress.dart' as models;

class LearningPathsScreen extends ConsumerStatefulWidget {
  const LearningPathsScreen({super.key});

  @override
  ConsumerState<LearningPathsScreen> createState() => _LearningPathsScreenState();
}

class _LearningPathsScreenState extends ConsumerState<LearningPathsScreen> {
  String _selectedLanguage = 'All';
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    final learningPathsAsync = ref.watch(learningPathsProvider);
    final activePathsAsync = ref.watch(activePathsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Learning Paths'),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.onBackground,
        elevation: 0,
      ),
      backgroundColor: AppColors.background,
      body: learningPathsAsync.when(
        loading: () => const LoadingScreen(),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppColors.error),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Failed to load learning paths',
                style: Theme.of(context).textTheme.headlineSmall,
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
                onPressed: () => ref.refresh(learningPathsProvider),
              ),
            ],
          ),
        ),
        data: (paths) => RefreshIndicator(
          onRefresh: () async {
            ref.refresh(learningPathsProvider);
            ref.refresh(activePathsProvider);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Continue Learning Section
                  activePathsAsync.when(
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (activePaths) => activePaths.isNotEmpty
                        ? _buildContinueLearningSection(activePaths)
                        : const SizedBox.shrink(),
                  ),
                  
                  const SizedBox(height: AppSpacing.lg),
                  
                  // Filters
                  _buildFilters(paths),
                  
                  const SizedBox(height: AppSpacing.lg),
                  
                  // Available Paths
                  Text(
                    'Available Learning Paths',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.onBackground,
                    ),
                  ),
                  
                  const SizedBox(height: AppSpacing.md),
                  
                  // Path Cards
                  ..._buildFilteredPaths(paths),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContinueLearningSection(List<models.UserPathProgress> activePaths) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Continue Learning',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.onBackground,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: activePaths.length,
            itemBuilder: (context, index) {
              final progress = activePaths[index];
              return _buildActivePathCard(progress);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActivePathCard(models.UserPathProgress progress) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: AppSpacing.md),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Current Path', // TODO: Get actual path name
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '${progress.completedLessons} lessons completed',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                LinearProgressIndicator(
                  value: progress.progressPercentage / 100,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${progress.progressPercentage.toStringAsFixed(1)}% complete',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.go(
                      '${AppRoutes.learningPathProgress}/${progress.pathId}',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
                      ),
                    ),
                    child: const Text('Continue'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilters(List<models.LearningPath> paths) {
    final languages = ['All', ...paths.map((p) => p.language).toSet().toList()..sort()];
    final categories = ['All', ...paths.map((p) => p.category).toSet().toList()..sort()];

    return Row(
      children: [
        Expanded(
          child: _buildFilterDropdown(
            'Language',
            _selectedLanguage,
            languages,
            (value) => setState(() => _selectedLanguage = value!),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _buildFilterDropdown(
            'Category',
            _selectedCategory,
            categories,
            (value) => setState(() => _selectedCategory = value!),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterDropdown(
    String label,
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.onBackground,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.outline),
            borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              onChanged: onChanged,
              items: items.map((item) => DropdownMenuItem(
                value: item,
                child: Text(item),
              )).toList(),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildFilteredPaths(List<models.LearningPath> paths) {
    final filteredPaths = paths.where((path) {
      final languageMatch = _selectedLanguage == 'All' || path.language == _selectedLanguage;
      final categoryMatch = _selectedCategory == 'All' || path.category == _selectedCategory;
      return languageMatch && categoryMatch;
    }).toList();

    if (filteredPaths.isEmpty) {
      return [
        const SizedBox(height: AppSpacing.xl),
        Center(
          child: Column(
            children: [
              Icon(
                Icons.search_off,
                size: 64,
                color: AppColors.onBackground.withOpacity(0.5),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'No learning paths found',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.onBackground.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Try adjusting your filters',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.onBackground.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
      ];
    }

    return filteredPaths.map((path) => Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: _buildPathCard(path),
    )).toList();
  }

  Widget _buildPathCard(models.LearningPath path) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
      ),
      child: InkWell(
        onTap: () => context.go('${AppRoutes.learningPathProgress}/${path.id}'),
        borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          path.name,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.onBackground,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Row(
                          children: [
                            _buildChip(path.language, AppColors.primary),
                            const SizedBox(width: AppSpacing.sm),
                            _buildChip(path.level, AppColors.secondary),
                            const SizedBox(width: AppSpacing.sm),
                            _buildChip(path.category, AppColors.accent),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (path.isOfficial)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        border: Border.all(color: AppColors.success),
                        borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
                      ),
                      child: const Text(
                        'Official',
                        style: TextStyle(
                          color: AppColors.success,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                path.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.onBackground.withOpacity(0.8),
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: AppColors.onBackground.withOpacity(0.6),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    '${path.estimatedHours} hours',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.onBackground.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Icon(
                    Icons.menu_book,
                    size: 16,
                    color: AppColors.onBackground.withOpacity(0.6),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    '${path.totalLessons} lessons',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.onBackground.withOpacity(0.6),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: AppColors.onBackground.withOpacity(0.4),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}