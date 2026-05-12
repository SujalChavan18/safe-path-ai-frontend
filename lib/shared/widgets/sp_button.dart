import 'package:flutter/material.dart';

import '../../config/theme/app_colors.dart';
import '../../config/theme/app_dimensions.dart';

/// Primary button with loading state, gradient support, and icon option.
///
/// Matches the dark futuristic aesthetic with a cyan glow effect.
///
/// ```dart
/// SpButton(
///   label: 'Start Navigation',
///   onPressed: () {},
///   icon: Icons.navigation_rounded,
///   isLoading: false,
/// )
/// ```
class SpButton extends StatelessWidget {
  const SpButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.variant = SpButtonVariant.primary,
    this.isFullWidth = true,
    this.height,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final SpButtonVariant variant;
  final bool isFullWidth;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final effectiveHeight = height ?? AppDimensions.buttonHeight;

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: effectiveHeight,
      child: switch (variant) {
        SpButtonVariant.primary => _buildPrimary(context),
        SpButtonVariant.secondary => _buildSecondary(context),
        SpButtonVariant.outlined => _buildOutlined(context),
        SpButtonVariant.ghost => _buildGhost(context),
        SpButtonVariant.danger => _buildDanger(context),
      },
    );
  }

  Widget _buildPrimary(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: onPressed != null && !isLoading
            ? AppColors.primaryGradient
            : null,
        color: onPressed == null || isLoading
            ? AppColors.surfaceVariant
            : null,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        boxShadow: onPressed != null && !isLoading
            ? [
                BoxShadow(
                  color: AppColors.glowCyan,
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          ),
        ),
        child: _buildChild(AppColors.onPrimary),
      ),
    );
  }

  Widget _buildSecondary(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.secondary,
        foregroundColor: AppColors.onSecondary,
      ),
      child: _buildChild(AppColors.onSecondary),
    );
  }

  Widget _buildOutlined(BuildContext context) {
    return OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      child: _buildChild(AppColors.primary),
    );
  }

  Widget _buildGhost(BuildContext context) {
    return TextButton(
      onPressed: isLoading ? null : onPressed,
      child: _buildChild(AppColors.primary),
    );
  }

  Widget _buildDanger(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.error,
        foregroundColor: AppColors.onError,
      ),
      child: _buildChild(AppColors.onError),
    );
  }

  Widget _buildChild(Color color) {
    if (isLoading) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation(color),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: AppDimensions.space8),
          Text(label, style: TextStyle(color: color)),
        ],
      );
    }

    return Text(label);
  }
}

/// Button style variants.
enum SpButtonVariant { primary, secondary, outlined, ghost, danger }
