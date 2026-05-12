import 'package:flutter/material.dart';

import '../../config/theme/app_colors.dart';

/// Animated loading indicator for SafePath AI.
///
/// Displays a pulsing gradient ring with an optional message.
///
/// ```dart
/// SpLoading(message: 'Finding safe routes…')
/// ```
class SpLoading extends StatefulWidget {
  const SpLoading({
    super.key,
    this.message,
    this.size = 48.0,
    this.color,
  });

  final String? message;
  final double size;
  final Color? color;

  @override
  State<SpLoading> createState() => _SpLoadingState();
}

class _SpLoadingState extends State<SpLoading>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveColor = widget.color ?? AppColors.primary;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: _pulseAnimation.value,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: effectiveColor.withValues(
                          alpha: 0.3 * _pulseAnimation.value,
                        ),
                        blurRadius: 20 * _pulseAnimation.value,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation(effectiveColor),
                  ),
                ),
              );
            },
          ),
          if (widget.message != null) ...[
            const SizedBox(height: 16),
            Text(
              widget.message!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
