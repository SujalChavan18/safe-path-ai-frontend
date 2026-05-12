import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_dimensions.dart';

/// Animated circular gauge displaying the current area's safety score.
class SafetyScoreCard extends StatefulWidget {
  const SafetyScoreCard({
    super.key,
    required this.score,
    required this.locationName,
  });

  /// Safety score from 0 to 100.
  final int score;

  /// The name of the current area (e.g., "Downtown SF").
  final String locationName;

  @override
  State<SafetyScoreCard> createState() => _SafetyScoreCardState();
}

class _SafetyScoreCardState extends State<SafetyScoreCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    // Animate from 0 to the actual score
    _animation = Tween<double>(begin: 0, end: widget.score.toDouble()).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _controller.forward();
  }

  @override
  void didUpdateWidget(SafetyScoreCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.score != oldWidget.score) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.score.toDouble(),
      ).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return AppColors.safeZone;
    if (score >= 50) return AppColors.cautionZone;
    return AppColors.dangerZone;
  }

  String _getScoreLabel(double score) {
    if (score >= 80) return 'Safe';
    if (score >= 50) return 'Caution';
    return 'High Risk';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.space20),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        children: [
          // ── Text Info ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      color: AppColors.primary,
                      size: 16,
                    ),
                    const SizedBox(width: AppDimensions.space8),
                    Text(
                      widget.locationName,
                      style: const TextStyle(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.space8),
                AnimatedBuilder(
                  animation: _animation,
                  builder: (context, _) {
                    final color = _getScoreColor(_animation.value);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getScoreLabel(_animation.value),
                          style: TextStyle(
                            color: color,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.space4),
                        Text(
                          'Based on real-time incident data',
                          style: TextStyle(
                            color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),

          // ── Circular Gauge ──
          SizedBox(
            width: 100,
            height: 100,
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                final score = _animation.value;
                final color = _getScoreColor(score);
                
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    CustomPaint(
                      painter: _GaugePainter(
                        score: score,
                        color: color,
                        backgroundColor: AppColors.surface,
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            score.toInt().toString(),
                            style: TextStyle(
                              color: color,
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              height: 1.0,
                            ),
                          ),
                          Text(
                            '/100',
                            style: TextStyle(
                              color: AppColors.onSurfaceVariant,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              height: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  _GaugePainter({
    required this.score,
    required this.color,
    required this.backgroundColor,
  });

  final double score;
  final Color color;
  final Color backgroundColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width / 2, size.height / 2) - 8;
    const strokeWidth = 12.0;

    // Draw background track
    final bgPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi * 0.75, // Start angle
      math.pi * 1.5, // Sweep angle
      false,
      bgPaint,
    );

    // Draw score arc
    final scorePaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Add glow
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..strokeWidth = strokeWidth + 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final sweepAngle = (score / 100) * (math.pi * 1.5);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi * 0.75,
      sweepAngle,
      false,
      glowPaint,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi * 0.75,
      sweepAngle,
      false,
      scorePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) {
    return oldDelegate.score != score || oldDelegate.color != color;
  }
}
