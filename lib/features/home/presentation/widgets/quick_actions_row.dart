import 'package:flutter/material.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_dimensions.dart';

/// Row of quick action buttons for the dashboard.
class QuickActionsRow extends StatelessWidget {
  const QuickActionsRow({
    super.key,
    required this.onReportIncident,
    required this.onShareLocation,
    required this.onSafeRoute,
  });

  final VoidCallback onReportIncident;
  final VoidCallback onShareLocation;
  final VoidCallback onSafeRoute;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: _QuickActionButton(
            title: 'Report Incident',
            icon: Icons.add_alert_rounded,
            color: AppColors.accent,
            isPrimary: true,
            onTap: onReportIncident,
          ),
        ),
        const SizedBox(width: AppDimensions.space12),
        Expanded(
          child: _QuickActionButton(
            title: 'Share Route',
            icon: Icons.share_location_rounded,
            color: AppColors.info,
            onTap: onShareLocation,
          ),
        ),
        const SizedBox(width: AppDimensions.space12),
        Expanded(
          child: _QuickActionButton(
            title: 'Safe Path',
            icon: Icons.route_rounded,
            color: AppColors.safeZone,
            onTap: onSafeRoute,
          ),
        ),
      ],
    );
  }
}

class _QuickActionButton extends StatefulWidget {
  const _QuickActionButton({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
    this.isPrimary = false,
  });

  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool isPrimary;

  @override
  State<_QuickActionButton> createState() => _QuickActionButtonState();
}

class _QuickActionButtonState extends State<_QuickActionButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) => _controller.forward();
  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onTap();
  }
  void _handleTapCancel() => _controller.reverse();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: Container(
          height: 80,
          padding: const EdgeInsets.all(AppDimensions.space12),
          decoration: BoxDecoration(
            color: widget.isPrimary 
                ? widget.color.withValues(alpha: 0.15)
                : AppColors.surfaceVariant.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            border: Border.all(
              color: widget.isPrimary
                  ? widget.color.withValues(alpha: 0.5)
                  : AppColors.outline,
            ),
            boxShadow: widget.isPrimary
                ? [
                    BoxShadow(
                      color: widget.color.withValues(alpha: 0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.icon,
                color: widget.isPrimary ? widget.color : AppColors.onSurface,
                size: widget.isPrimary ? 28 : 24,
              ),
              const SizedBox(height: AppDimensions.space8),
              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: widget.isPrimary ? widget.color : AppColors.onSurfaceVariant,
                  fontSize: 11,
                  fontWeight: widget.isPrimary ? FontWeight.w700 : FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
