import 'package:flutter/material.dart';

import '../../config/theme/app_colors.dart';
import '../../config/theme/app_dimensions.dart';

/// Styled text input field for SafePath AI.
///
/// Extends Material's input decoration with the app's dark futuristic aesthetic,
/// optional prefix/suffix icons, and validation support.
///
/// ```dart
/// SpTextField(
///   label: 'Email',
///   hint: 'Enter your email',
///   prefixIcon: Icons.email_outlined,
///   validator: Validators.email,
/// )
/// ```
class SpTextField extends StatefulWidget {
  const SpTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.obscureText = false,
    this.enabled = true,
    this.keyboardType,
    this.textInputAction,
    this.maxLines = 1,
    this.maxLength,
    this.autofocus = false,
    this.focusNode,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool obscureText;
  final bool enabled;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final int maxLines;
  final int? maxLength;
  final bool autofocus;
  final FocusNode? focusNode;

  @override
  State<SpTextField> createState() => _SpTextFieldState();
}

class _SpTextFieldState extends State<SpTextField> {
  late bool _obscured;

  @override
  void initState() {
    super.initState();
    _obscured = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscured,
      enabled: widget.enabled,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      maxLines: widget.obscureText ? 1 : widget.maxLines,
      maxLength: widget.maxLength,
      autofocus: widget.autofocus,
      focusNode: widget.focusNode,
      validator: widget.validator,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onSubmitted,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.onSurface,
          ),
      cursorColor: AppColors.primary,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        prefixIcon: widget.prefixIcon != null
            ? Icon(widget.prefixIcon, size: AppDimensions.iconMedium)
            : null,
        suffixIcon: _buildSuffix(),
      ),
    );
  }

  Widget? _buildSuffix() {
    // Password visibility toggle
    if (widget.obscureText) {
      return IconButton(
        icon: Icon(
          _obscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          size: AppDimensions.iconMedium,
          color: AppColors.onSurfaceVariant,
        ),
        onPressed: () => setState(() => _obscured = !_obscured),
      );
    }

    // Custom suffix icon
    if (widget.suffixIcon != null) {
      return IconButton(
        icon: Icon(
          widget.suffixIcon,
          size: AppDimensions.iconMedium,
          color: AppColors.onSurfaceVariant,
        ),
        onPressed: widget.onSuffixTap,
      );
    }

    return null;
  }
}
