import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';

class FlipCard extends StatefulWidget {
  final Widget front;
  final Widget back;
  final bool isFlipped;
  final VoidCallback? onTap;
  final Duration flipDuration;

  const FlipCard({
    super.key,
    required this.front,
    required this.back,
    this.isFlipped = false,
    this.onTap,
    this.flipDuration = const Duration(milliseconds: 600),
  });

  @override
  State<FlipCard> createState() => _FlipCardState();
}

class _FlipCardState extends State<FlipCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.flipDuration,
      vsync: this,
    );
    _flipAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    if (widget.isFlipped) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(FlipCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isFlipped != oldWidget.isFlipped) {
      if (widget.isFlipped) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _flipAnimation,
        builder: (context, child) {
          final isShowingBack = _flipAnimation.value >= 0.5;
          
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(_flipAnimation.value * 3.14159),
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(
                minHeight: 300,
                maxHeight: 400,
              ),
              child: isShowingBack
                  ? Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()..rotateY(3.14159),
                      child: _buildCardSide(widget.back, isBack: true),
                    )
                  : _buildCardSide(widget.front),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCardSide(Widget child, {bool isBack = false}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isBack
              ? [
                  AppColors.secondary.withOpacity(0.1),
                  AppColors.primary.withOpacity(0.1),
                ]
              : [
                  AppColors.primary.withOpacity(0.1),
                  AppColors.secondary.withOpacity(0.1),
                ],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.borderRadiusLarge),
        border: Border.all(
          color: isBack ? AppColors.secondary : AppColors.primary,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: (isBack ? AppColors.secondary : AppColors.primary)
                .withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: child,
      ),
    );
  }
}

class StudyCardContent extends StatelessWidget {
  final String text;
  final bool isAnswer;
  final String? imageUrl;
  final List<String> tags;

  const StudyCardContent({
    super.key,
    required this.text,
    this.isAnswer = false,
    this.imageUrl,
    this.tags = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (imageUrl != null) ...[
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
            ),
            child: const Icon(
              Icons.image,
              size: 48,
              color: AppColors.hint,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
        
        Text(
          text,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: isAnswer ? AppColors.secondary : AppColors.primary,
          ),
          textAlign: TextAlign.center,
        ),
        
        if (tags.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            alignment: WrapAlignment.center,
            children: tags.map((tag) => Chip(
              label: Text(
                tag,
                style: const TextStyle(fontSize: 12),
              ),
              backgroundColor: isAnswer 
                  ? AppColors.secondary.withOpacity(0.2)
                  : AppColors.primary.withOpacity(0.2),
              side: BorderSide(
                color: isAnswer ? AppColors.secondary : AppColors.primary,
                width: 1,
              ),
            )).toList(),
          ),
        ],
        
        const SizedBox(height: AppSpacing.lg),
        
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isAnswer ? Icons.lightbulb : Icons.help_outline,
              color: AppColors.hint,
              size: 16,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              isAnswer ? 'Answer' : 'Question',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.hint,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}