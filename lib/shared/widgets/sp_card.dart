import 'dart:ui';

import 'package:flutter/material.dart';

import '../../config/theme/app_colors.dart';
import '../../config/theme/app_dimensions.dart';

/// Glassmorphic card with subtle border glow for SafePath AI.
///
/// Features frosted glass effect with backdrop blur,
/// optional gradient border, and configurable padding.
///
/// ```dart
/// SpCard(
///   child: Text('Safety Score: 92'),
///   glowColor: AppColors.success,
/// )
/// ```
class SpCard extends StatelessWidget {
  const SpCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.glowColor,
    this.onTap,
    this.borderRadius,
    this.blurAmount = 10.0,
    this.opacity = 0.05,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  /// Optional colored glow on the border. Use safety colors for context.
  final Color? glowColor;
  final VoidCallback? onTap;
  final double? borderRadius;
  final double blurAmount;

  /// Background opacity (0.0 – 1.0).
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? AppDimensions.radiusMedium;
    final effectiveGlow = glowColor ?? AppColors.primary;

    return Container(
      margin: margin ??
          const EdgeInsets.symmetric(
            horizontal: AppDimensions.space16,
            vertical: AppDimensions.space8,
          ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: glowColor != null
            ? [
                BoxShadow(
                  color: effectiveGlow.withValues(alpha: 0.15),
                  blurRadius: 16,
                  spreadRadius: -2,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: blurAmount,
            sigmaY: blurAmount,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(radius),
              child: Container(
                padding: padding ??
                    const EdgeInsets.all(AppDimensions.space16),
                decoration: BoxDecoration(
                  color: AppColors.glassBackground.withValues(alpha: opacity),
                  borderRadius: BorderRadius.circular(radius),
                  border: Border.all(
                    color: glowColor != null
                        ? effectiveGlow.withValues(alpha: 0.3)
                        : AppColors.glassBorder,
                    width: AppDimensions.borderThin,
                  ),
                ),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
