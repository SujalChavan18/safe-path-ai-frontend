import 'package:flutter/material.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_dimensions.dart';

/// Secondary button for Google Sign-In with glassmorphic styling.
class SocialLoginButton extends StatefulWidget {
  const SocialLoginButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  final VoidCallback onPressed;
  final bool isLoading;

  @override
  State<SocialLoginButton> createState() => _SocialLoginButtonState();
}

class _SocialLoginButtonState extends State<SocialLoginButton>
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

  void _handleTapDown(TapDownDetails details) {
    if (!widget.isLoading) _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    if (!widget.isLoading) {
      _controller.reverse();
      widget.onPressed();
    }
  }

  void _handleTapCancel() {
    if (!widget.isLoading) _controller.reverse();
  }

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
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            border: Border.all(color: AppColors.outline),
          ),
          child: Center(
            child: widget.isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: AppColors.onSurface,
                      strokeWidth: 2.5,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Google 'G' Icon (Simulated with text for simplicity,
                      // or use an asset image if you have one. We will use a colorful text G)
                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(text: 'G', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 20)),
                            TextSpan(text: 'o', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 20)),
                            TextSpan(text: 'o', style: TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold, fontSize: 20)),
                            TextSpan(text: 'g', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 20)),
                            TextSpan(text: 'l', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 20)),
                            TextSpan(text: 'e', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 20)),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppDimensions.space12),
                      const Text(
                        'Continue with Google',
                        style: TextStyle(
                          color: AppColors.onSurface,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
