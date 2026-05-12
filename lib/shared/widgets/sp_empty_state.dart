import 'package:flutter/material.dart';

import '../../config/theme/app_colors.dart';
import '../../config/theme/app_dimensions.dart';

/// Empty state / error state widget for SafePath AI.
///
/// Displays a centered icon, title, optional message,
/// and optional action button.
///
/// ```dart
/// SpEmptyState(
///   icon: Icons.warning_amber_rounded,
///   title: 'No Alerts',
///   message: 'There are no safety alerts in your area.',
///   actionLabel: 'Refresh',
///   onAction: () {},
/// )
/// ```
class SpEmptyState extends StatelessWidget {
  const SpEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    this.iconColor,
    this.iconSize = 72,
  });

  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color? iconColor;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.space32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Icon with subtle glow ──
            Container(
              padding: const EdgeInsets.all(AppDimensions.space20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (iconColor ?? AppColors.primary).withValues(alpha: 0.08),
                boxShadow: [
                  BoxShadow(
                    color:
                        (iconColor ?? AppColors.primary).withValues(alpha: 0.1),
                    blurRadius: 24,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Icon(
                icon,
                size: iconSize,
                color: (iconColor ?? AppColors.primary).withValues(alpha: 0.6),
              ),
            ),

            const SizedBox(height: AppDimensions.space24),

            // ── Title ──
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.onBackground,
                  ),
              textAlign: TextAlign.center,
            ),

            // ── Message ──
            if (message != null) ...[
              const SizedBox(height: AppDimensions.space8),
              Text(
                message!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
            ],

            // ── Action Button ──
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppDimensions.space24),
              OutlinedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(actionLabel!),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusMedium),
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
