import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';

class LoadingScreen extends StatelessWidget {
  final String? message;
  final bool showLogo;
  final Widget? customLoader;

  const LoadingScreen({
    super.key,
    this.message,
    this.showLogo = true,
    this.customLoader,
  });

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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (showLogo) ...[
                _buildLogo(),
                const Gap(48),
              ],
              customLoader ?? _buildDefaultLoader(),
              if (message != null) ...[
                const Gap(24),
                Text(
                  message!,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.hint,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Icon(
        Icons.school,
        color: Colors.white,
        size: 50,
      ),
    )
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(
          duration: 2000.ms,
          color: Colors.white.withOpacity(0.3),
        )
        .then()
        .scale(
          begin: const Offset(1.0, 1.0),
          end: const Offset(1.05, 1.05),
          duration: 1000.ms,
          curve: Curves.easeInOut,
        )
        .then()
        .scale(
          begin: const Offset(1.05, 1.05),
          end: const Offset(1.0, 1.0),
          duration: 1000.ms,
          curve: Curves.easeInOut,
        );
  }

  Widget _buildDefaultLoader() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer ring
        SizedBox(
          width: 60,
          height: 60,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(
              AppColors.primary.withOpacity(0.3),
            ),
          ),
        )
            .animate(onPlay: (controller) => controller.repeat())
            .rotate(duration: 2000.ms, curve: Curves.linear),
        
        // Inner ring
        SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondary),
          ),
        )
            .animate(onPlay: (controller) => controller.repeat())
            .rotate(
              duration: 1500.ms,
              curve: Curves.linear,
              begin: 1.0,
              end: 0.0,
            ),
        
        // Center dot
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary,
          ),
        )
            .animate(onPlay: (controller) => controller.repeat(reverse: true))
            .scale(
              duration: 800.ms,
              begin: const Offset(1.0, 1.0),
              end: const Offset(1.5, 1.5),
              curve: Curves.easeInOut,
            ),
      ],
    );
  }
}

class PulsingLoader extends StatelessWidget {
  final double size;
  final Color? color;
  final String? text;

  const PulsingLoader({
    super.key,
    this.size = 50,
    this.color,
    this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                color ?? AppColors.primary,
                (color ?? AppColors.primary).withOpacity(0.6),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: (color ?? AppColors.primary).withOpacity(0.3),
                blurRadius: size * 0.3,
                spreadRadius: 0,
              ),
            ],
          ),
        )
            .animate(onPlay: (controller) => controller.repeat(reverse: true))
            .scale(
              duration: 1000.ms,
              begin: const Offset(1.0, 1.0),
              end: const Offset(1.2, 1.2),
              curve: Curves.easeInOut,
            )
            .then()
            .fadeOut(duration: 200.ms)
            .then()
            .fadeIn(duration: 200.ms),
        
        if (text != null) ...[
          const Gap(16),
          Text(
            text!,
            style: TextStyle(
              color: color ?? AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}

class DotLoader extends StatefulWidget {
  final Color? color;
  final double dotSize;
  final int dotCount;

  const DotLoader({
    super.key,
    this.color,
    this.dotSize = 8,
    this.dotCount = 3,
  });

  @override
  State<DotLoader> createState() => _DotLoaderState();
}

class _DotLoaderState extends State<DotLoader>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.dotCount,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      ),
    );

    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) {
          _controllers[i].repeat(reverse: true);
        }
      });
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        widget.dotCount,
        (index) => AnimatedBuilder(
          animation: _controllers[index],
          builder: (context, child) {
            return Transform.scale(
              scale: 0.5 + (_controllers[index].value * 0.5),
              child: Container(
                width: widget.dotSize,
                height: widget.dotSize,
                margin: EdgeInsets.symmetric(horizontal: widget.dotSize * 0.25),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color ?? AppColors.primary,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class WaveLoader extends StatefulWidget {
  final Color? color;
  final double size;
  final int waveCount;

  const WaveLoader({
    super.key,
    this.color,
    this.size = 50,
    this.waveCount = 3,
  });

  @override
  State<WaveLoader> createState() => _WaveLoaderState();
}

class _WaveLoaderState extends State<WaveLoader>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: List.generate(
              widget.waveCount,
              (index) {
                final delay = index / widget.waveCount;
                final animValue = (_controller.value - delay) % 1.0;
                
                return Container(
                  width: widget.size * animValue,
                  height: widget.size * animValue,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: (widget.color ?? AppColors.primary)
                          .withOpacity(1 - animValue),
                      width: 2,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}