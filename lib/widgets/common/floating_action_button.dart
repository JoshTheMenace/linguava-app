import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';

class CustomFloatingActionButton extends StatefulWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String? tooltip;
  final List<Color>? gradientColors;
  final double size;
  final bool isPulsing;
  final Widget? child;

  const CustomFloatingActionButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.tooltip,
    this.gradientColors,
    this.size = 56,
    this.isPulsing = false,
    this.child,
  });

  @override
  State<CustomFloatingActionButton> createState() => _CustomFloatingActionButtonState();
}

class _CustomFloatingActionButtonState extends State<CustomFloatingActionButton>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));
    
    if (widget.isPulsing) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _scaleController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _scaleController.reverse();
  }

  void _onTapCancel() {
    _scaleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.gradientColors ?? [AppColors.primary, AppColors.secondary];
    
    Widget button = GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: colors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: colors.first.withOpacity(0.4),
                    blurRadius: 12,
                    spreadRadius: 0,
                    offset: const Offset(0, 6),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    spreadRadius: 0,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(widget.size / 2),
                  onTap: widget.onPressed,
                  child: widget.child ??
                      Icon(
                        widget.icon,
                        color: Colors.white,
                        size: widget.size * 0.4,
                      ),
                ),
              ),
            ),
          );
        },
      ),
    );

    if (widget.isPulsing) {
      button = button
          .animate(controller: _pulseController)
          .scale(
            end: const Offset(1.1, 1.1),
            curve: Curves.easeInOut,
          )
          .then()
          .shimmer(
            duration: const Duration(milliseconds: 800),
            color: Colors.white.withOpacity(0.3),
          );
    }

    if (widget.tooltip != null) {
      button = Tooltip(
        message: widget.tooltip!,
        child: button,
      );
    }

    return button;
  }
}

class ExpandableFAB extends StatefulWidget {
  final List<ExpandableFABAction> actions;
  final IconData mainIcon;
  final String? tooltip;
  final List<Color>? gradientColors;

  const ExpandableFAB({
    super.key,
    required this.actions,
    required this.mainIcon,
    this.tooltip,
    this.gradientColors,
  });

  @override
  State<ExpandableFAB> createState() => _ExpandableFABState();
}

class _ExpandableFABState extends State<ExpandableFAB>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...widget.actions.asMap().entries.map((entry) {
          final index = entry.key;
          final action = entry.value;
          return AnimatedBuilder(
            animation: _expandAnimation,
            builder: (context, child) {
              final delay = index * 0.1;
              final animationValue = Curves.easeOutBack.transform(
                (_expandAnimation.value - delay).clamp(0.0, 1.0),
              );
              
              return Transform.scale(
                scale: animationValue,
                child: Transform.translate(
                  offset: Offset(0, -(1 - animationValue) * 20),
                  child: Opacity(
                    opacity: animationValue,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              action.label,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          CustomFloatingActionButton(
                            onPressed: () {
                              action.onPressed();
                              _toggle();
                            },
                            icon: action.icon,
                            size: 48,
                            gradientColors: action.gradientColors,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        }),
        CustomFloatingActionButton(
          onPressed: _toggle,
          icon: _isExpanded ? Icons.close : widget.mainIcon,
          tooltip: widget.tooltip,
          gradientColors: widget.gradientColors,
        ),
      ],
    );
  }
}

class ExpandableFABAction {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final List<Color>? gradientColors;

  const ExpandableFABAction({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.gradientColors,
  });
}