import 'package:flutter/material.dart';

import '../../config/theme/app_colors.dart';
import '../../config/theme/app_dimensions.dart';

/// Custom transparent app bar for SafePath AI.
///
/// Extends the futuristic aesthetic with a gradient bottom border
/// and optional action buttons.
///
/// ```dart
/// SpAppBar(
///   title: 'Safety Map',
///   actions: [IconButton(...)],
/// )
/// ```
class SpAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SpAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.leading,
    this.actions,
    this.showBackButton = true,
    this.showBottomBorder = true,
    this.backgroundColor,
    this.centerTitle = true,
  });

  final String? title;
  final Widget? titleWidget;
  final Widget? leading;
  final List<Widget>? actions;
  final bool showBackButton;
  final bool showBottomBorder;
  final Color? backgroundColor;
  final bool centerTitle;

  @override
  Size get preferredSize => const Size.fromHeight(AppDimensions.appBarHeight);

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.transparent,
        border: showBottomBorder
            ? const Border(
                bottom: BorderSide(
                  color: AppColors.outline,
                  width: AppDimensions.borderThin,
                ),
              )
            : null,
      ),
      child: AppBar(
        backgroundColor: Colors.transparent,
        leading: leading ??
            (showBackButton && canPop
                ? IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_rounded,
                      size: 20,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  )
                : null),
        title: titleWidget ??
            (title != null
                ? Text(
                    title!,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          letterSpacing: 0.5,
                        ),
                  )
                : null),
        centerTitle: centerTitle,
        actions: actions,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
    );
  }
}
