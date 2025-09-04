import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';

class AnimatedCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? elevation;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final Duration animationDuration;
  final Duration animationDelay;
  final bool enableHoverEffect;
  final List<BoxShadow>? customShadows;

  const AnimatedCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.elevation,
    this.backgroundColor,
    this.borderRadius,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationDelay = Duration.zero,
    this.enableHoverEffect = true,
    this.customShadows,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.all(AppSpacing.sm),
      child: Material(
        color: backgroundColor ?? AppColors.cardBackground,
        elevation: elevation ?? AppSpacing.elevation,
        shadowColor: customShadows?.first.color ?? Colors.black.withOpacity(0.3),
        borderRadius: borderRadius ?? BorderRadius.circular(AppSpacing.borderRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius ?? BorderRadius.circular(AppSpacing.borderRadius),
          child: Container(
            padding: padding ?? const EdgeInsets.all(AppSpacing.md),
            decoration: customShadows != null
                ? BoxDecoration(
                    borderRadius: borderRadius ?? BorderRadius.circular(AppSpacing.borderRadius),
                    boxShadow: customShadows,
                  )
                : null,
            child: child,
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(
          delay: animationDelay,
          duration: animationDuration,
        )
        .slideY(
          begin: 0.1,
          end: 0,
          delay: animationDelay,
          duration: animationDuration,
        )
        .then()
        .shimmer(
          duration: const Duration(milliseconds: 600),
          color: AppColors.primary.withOpacity(0.1),
        );
  }
}

class GlassCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final double opacity;

  const GlassCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.borderRadius,
    this.opacity = 0.1,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.circular(AppSpacing.borderRadius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(opacity),
            Colors.white.withOpacity(opacity * 0.5),
          ],
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius ?? BorderRadius.circular(AppSpacing.borderRadius),
          child: Container(
            padding: padding ?? const EdgeInsets.all(AppSpacing.md),
            child: child,
          ),
        ),
      ),
    );
  }
}