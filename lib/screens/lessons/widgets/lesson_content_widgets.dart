import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../models/lesson_content.dart';
import '../../../widgets/common/flip_card.dart';

class LessonContentWidget extends StatelessWidget {
  final LessonContent content;
  final Function(dynamic) onAnswerChanged;
  final dynamic userAnswer;

  const LessonContentWidget({
    super.key,
    required this.content,
    required this.onAnswerChanged,
    this.userAnswer,
  });

  @override
  Widget build(BuildContext context) {
    switch (content.type) {
      case LessonContentType.explanation:
        return ExplanationWidget(
          content: content as ExplanationContent,
          onRead: () => onAnswerChanged(true),
        );
      case LessonContentType.flashcard:
        return FlashcardWidget(
          key: ValueKey(content.id),
          content: content as FlashcardContent,
          onFlipped: () => onAnswerChanged(true),
        );
      case LessonContentType.multipleChoice:
        return MultipleChoiceWidget(
          content: content as MultipleChoiceContent,
          selectedAnswer: userAnswer,
          onAnswerSelected: onAnswerChanged,
        );
      case LessonContentType.fillInBlank:
        return FillInBlankWidget(
          content: content as FillInBlankContent,
          answers: userAnswer ?? [],
          onAnswersChanged: onAnswerChanged,
        );
      case LessonContentType.matching:
        return MatchingWidget(
          content: content as MatchingContent,
          matches: userAnswer ?? {},
          onMatchesChanged: onAnswerChanged,
        );
    }
  }
}

class ExplanationWidget extends StatefulWidget {
  final ExplanationContent content;
  final VoidCallback onRead;

  const ExplanationWidget({
    super.key,
    required this.content,
    required this.onRead,
  });

  @override
  State<ExplanationWidget> createState() => _ExplanationWidgetState();
}

class _ExplanationWidgetState extends State<ExplanationWidget> {
  @override
  void initState() {
    super.initState();
    // Mark as read after a short delay
    Future.delayed(const Duration(seconds: 1), () {
      widget.onRead();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              widget.content.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            
            if (widget.content.instruction != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                widget.content.instruction!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.onBackground.withOpacity(0.7),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            
            const SizedBox(height: AppSpacing.lg),
            
            // Main content
            Text(
              widget.content.content,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            
            // Examples
            if (widget.content.examples != null && widget.content.examples!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Examples:',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              ...widget.content.examples!.map((example) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(color: AppColors.primary)),
                    Expanded(
                      child: Text(
                        example,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
            ],
            
            // Image placeholder
            if (widget.content.imageUrl != null) ...[
              const SizedBox(height: AppSpacing.lg),
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: AppColors.outline.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
                  border: Border.all(
                    color: AppColors.outline.withOpacity(0.3),
                  ),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.image, size: 48, color: AppColors.outline),
                      SizedBox(height: AppSpacing.sm),
                      Text('Image placeholder'),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class FlashcardWidget extends StatefulWidget {
  final FlashcardContent content;
  final VoidCallback onFlipped;

  const FlashcardWidget({
    super.key,
    required this.content,
    required this.onFlipped,
  });

  @override
  State<FlashcardWidget> createState() => _FlashcardWidgetState();
}

class _FlashcardWidgetState extends State<FlashcardWidget> {
  bool hasFlipped = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title and instruction
        Text(
          widget.content.title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        
        if (widget.content.instruction != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            widget.content.instruction!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.onBackground.withOpacity(0.7),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
        
        const SizedBox(height: AppSpacing.lg),
        
        // Flip card
        Center(
          child: FlipCard(
            front: _buildFlashcardSide(
              widget.content.front,
              isPronunciation: false,
            ),
            back: _buildFlashcardSide(
              widget.content.back,
              isPronunciation: true,
              pronunciation: widget.content.pronunciation,
            ),
            onTap: () {
              if (!hasFlipped) {
                hasFlipped = true;
                widget.onFlipped();
              }
            },
          ),
        ),
        
        const SizedBox(height: AppSpacing.lg),
        
        // Instruction text
        Center(
          child: Text(
            hasFlipped 
              ? 'How well did you know this?'
              : 'Tap the card to reveal the answer',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.onBackground.withOpacity(0.7),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFlashcardSide(String text, {bool isPronunciation = false, String? pronunciation}) {
    return Container(
      width: 300,
      height: 200,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            if (isPronunciation && pronunciation != null) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                pronunciation,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class MultipleChoiceWidget extends StatelessWidget {
  final MultipleChoiceContent content;
  final int? selectedAnswer;
  final Function(int) onAnswerSelected;

  const MultipleChoiceWidget({
    super.key,
    required this.content,
    this.selectedAnswer,
    required this.onAnswerSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              content.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            
            if (content.instruction != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                content.instruction!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.onBackground.withOpacity(0.7),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            
            const SizedBox(height: AppSpacing.lg),
            
            // Question
            Text(
              content.question,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const SizedBox(height: AppSpacing.lg),
            
            // Options
            ...content.options.asMap().entries.map((entry) {
              final index = entry.key;
              final option = entry.value;
              final isSelected = selectedAnswer == index;
              final isCorrect = index == content.correctAnswerIndex;
              final showResult = selectedAnswer != null;
              
              Color? backgroundColor;
              Color? borderColor;
              
              if (showResult) {
                if (isCorrect) {
                  backgroundColor = AppColors.success.withOpacity(0.1);
                  borderColor = AppColors.success;
                } else if (isSelected && !isCorrect) {
                  backgroundColor = AppColors.error.withOpacity(0.1);
                  borderColor = AppColors.error;
                }
              } else if (isSelected) {
                backgroundColor = AppColors.primary.withOpacity(0.1);
                borderColor = AppColors.primary;
              }
              
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: InkWell(
                  onTap: selectedAnswer == null ? () => onAnswerSelected(index) : null,
                  borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      border: Border.all(
                        color: borderColor ?? AppColors.outline.withOpacity(0.3),
                      ),
                      borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: borderColor ?? AppColors.outline,
                            ),
                            color: isSelected ? (borderColor ?? AppColors.primary) : null,
                          ),
                          child: isSelected
                            ? Icon(
                                showResult && !isCorrect ? Icons.close : Icons.check,
                                size: 16,
                                color: Colors.white,
                              )
                            : null,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            option,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: isSelected ? FontWeight.w600 : null,
                            ),
                          ),
                        ),
                        if (showResult && isCorrect)
                          const Icon(Icons.check_circle, color: AppColors.success),
                      ],
                    ),
                  ),
                ),
              );
            }),
            
            // Explanation after answer
            if (selectedAnswer != null && content.explanation != null) ...[
              const SizedBox(height: AppSpacing.lg),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  border: Border.all(color: AppColors.info.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.lightbulb_outline, color: AppColors.info),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          'Explanation',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.info,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      content.explanation!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class FillInBlankWidget extends StatefulWidget {
  final FillInBlankContent content;
  final List<String> answers;
  final Function(List<String>) onAnswersChanged;

  const FillInBlankWidget({
    super.key,
    required this.content,
    required this.answers,
    required this.onAnswersChanged,
  });

  @override
  State<FillInBlankWidget> createState() => _FillInBlankWidgetState();
}

class _FillInBlankWidgetState extends State<FillInBlankWidget> {
  late List<TextEditingController> controllers;

  @override
  void initState() {
    super.initState();
    final blankCount = widget.content.text.split('[blank]').length - 1;
    controllers = List.generate(blankCount, (index) {
      final controller = TextEditingController();
      if (index < widget.answers.length) {
        controller.text = widget.answers[index];
      }
      controller.addListener(() {
        final newAnswers = controllers.map((c) => c.text).toList();
        widget.onAnswersChanged(newAnswers);
      });
      return controller;
    });
  }

  @override
  void dispose() {
    for (final controller in controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              widget.content.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            
            if (widget.content.instruction != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                widget.content.instruction!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.onBackground.withOpacity(0.7),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            
            const SizedBox(height: AppSpacing.lg),
            
            // Text with blanks
            _buildTextWithBlanks(),
            
            // Hint
            if (widget.content.hint != null) ...[
              const SizedBox(height: AppSpacing.lg),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lightbulb_outline, color: AppColors.warning),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'Hint: ${widget.content.hint!}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTextWithBlanks() {
    final parts = widget.content.text.split('[blank]');
    final widgets = <Widget>[];
    
    for (int i = 0; i < parts.length; i++) {
      // Add text part
      if (parts[i].isNotEmpty) {
        widgets.add(
          Text(
            parts[i],
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        );
      }
      
      // Add blank field (except after the last part)
      if (i < parts.length - 1 && i < controllers.length) {
        widgets.add(
          Container(
            width: 120,
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            child: TextField(
              controller: controllers[i],
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: '___',
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primary),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.outline),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
            ),
          ),
        );
      }
    }
    
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.end,
      children: widgets,
    );
  }
}

class MatchingWidget extends StatefulWidget {
  final MatchingContent content;
  final Map<String, String> matches;
  final Function(Map<String, String>) onMatchesChanged;

  const MatchingWidget({
    super.key,
    required this.content,
    required this.matches,
    required this.onMatchesChanged,
  });

  @override
  State<MatchingWidget> createState() => _MatchingWidgetState();
}

class _MatchingWidgetState extends State<MatchingWidget> {
  String? selectedLeft;
  late List<String> leftItems;
  late List<String> rightItems;

  @override
  void initState() {
    super.initState();
    leftItems = widget.content.pairs.map((pair) => pair.left).toList();
    rightItems = widget.content.pairs.map((pair) => pair.right).toList();
    
    if (widget.content.shuffle) {
      rightItems.shuffle();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              widget.content.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            
            if (widget.content.instruction != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                widget.content.instruction!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.onBackground.withOpacity(0.7),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            
            const SizedBox(height: AppSpacing.lg),
            
            // Matching interface
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left column
                Expanded(
                  child: Column(
                    children: leftItems.map((item) => _buildLeftItem(item)).toList(),
                  ),
                ),
                
                const SizedBox(width: AppSpacing.lg),
                
                // Right column
                Expanded(
                  child: Column(
                    children: rightItems.map((item) => _buildRightItem(item)).toList(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeftItem(String item) {
    final isSelected = selectedLeft == item;
    final isMatched = widget.matches.containsKey(item);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: GestureDetector(
        onTap: isMatched ? null : () {
          setState(() {
            selectedLeft = isSelected ? null : item;
          });
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: isMatched 
              ? AppColors.success.withOpacity(0.1)
              : isSelected 
                ? AppColors.primary.withOpacity(0.1)
                : AppColors.surface,
            border: Border.all(
              color: isMatched 
                ? AppColors.success
                : isSelected 
                  ? AppColors.primary
                  : AppColors.outline.withOpacity(0.3),
            ),
            borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
          ),
          child: Text(
            item,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: isSelected || isMatched ? FontWeight.w600 : null,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRightItem(String item) {
    final matchedLeft = widget.matches.entries
        .firstWhere((entry) => entry.value == item, orElse: () => const MapEntry('', ''))
        .key;
    final isMatched = matchedLeft.isNotEmpty;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: GestureDetector(
        onTap: selectedLeft != null && !isMatched ? () {
          final newMatches = Map<String, String>.from(widget.matches);
          newMatches[selectedLeft!] = item;
          widget.onMatchesChanged(newMatches);
          setState(() {
            selectedLeft = null;
          });
        } : null,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: isMatched 
              ? AppColors.success.withOpacity(0.1)
              : selectedLeft != null 
                ? AppColors.primary.withOpacity(0.05)
                : AppColors.surface,
            border: Border.all(
              color: isMatched 
                ? AppColors.success
                : AppColors.outline.withOpacity(0.3),
            ),
            borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
          ),
          child: Text(
            item,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: isMatched ? FontWeight.w600 : null,
            ),
          ),
        ),
      ),
    );
  }
}