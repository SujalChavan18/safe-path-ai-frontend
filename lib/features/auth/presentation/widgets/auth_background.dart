import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../config/theme/app_colors.dart';

/// Animated futuristic gradient background for authentication screens.
///
/// Uses rotating blur circles (blobs) to create a slow-moving,
/// living background effect typical in modern cyberpunk/glassmorphic UI.
class AuthBackground extends StatefulWidget {
  const AuthBackground({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<AuthBackground> createState() => _AuthBackgroundState();
}

class _AuthBackgroundState extends State<AuthBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ── Solid Base ──
        Container(color: AppColors.background),

        // ── Animated Blobs ──
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final t = _controller.value * 2 * math.pi;
            return Stack(
              children: [
                // Top Right Blob (Cyan)
                Positioned(
                  top: -100 + math.sin(t) * 50,
                  right: -100 + math.cos(t) * 50,
                  child: _Blob(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    size: 400,
                  ),
                ),
                // Bottom Left Blob (Violet)
                Positioned(
                  bottom: -150 + math.cos(t) * 60,
                  left: -100 + math.sin(t) * 60,
                  child: _Blob(
                    color: AppColors.secondary.withValues(alpha: 0.15),
                    size: 500,
                  ),
                ),
                // Center Right Blob (Cyan)
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.4 +
                      math.sin(t + math.pi) * 80,
                  right: -150 + math.cos(t + math.pi) * 40,
                  child: _Blob(
                    color: AppColors.primaryDark.withValues(alpha: 0.1),
                    size: 300,
                  ),
                ),
              ],
            );
          },
        ),

        // ── Foreground Content ──
        SafeArea(child: widget.child),
      ],
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: 100,
            spreadRadius: 50,
          ),
        ],
      ),
    );
  }
}
