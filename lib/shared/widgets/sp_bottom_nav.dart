import 'package:flutter/material.dart';

import '../../config/theme/app_colors.dart';
import '../../config/theme/app_dimensions.dart';

/// Futuristic bottom navigation bar with glow indicator for SafePath AI.
///
/// Renders a custom bottom nav with an animated glow under the
/// selected item. Use this as an alternative to the default NavigationBar.
///
/// ```dart
/// SpBottomNav(
///   currentIndex: 0,
///   onTap: (index) {},
///   items: [...],
/// )
/// ```
class SpBottomNav extends StatelessWidget {
  const SpBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<SpBottomNavItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppDimensions.bottomNavHeight,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(
          top: BorderSide(
            color: AppColors.outline,
            width: AppDimensions.borderThin,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(
            items.length,
            (index) => _NavItem(
              item: items[index],
              isSelected: index == currentIndex,
              onTap: () => onTap(index),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final SpBottomNavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.primary : AppColors.onSurfaceVariant;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        splashColor: AppColors.primary.withValues(alpha: 0.1),
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ── Glow dot ──
            AnimatedContainer(
              duration: const Duration(milliseconds: AppDimensions.animDefault),
              curve: Curves.easeOut,
              width: isSelected ? 24 : 0,
              height: 3,
              margin: const EdgeInsets.only(bottom: AppDimensions.space4),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(AppDimensions.radiusRound),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.glowCyan,
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
            ),

            // ── Icon ──
            AnimatedSwitcher(
              duration:
                  const Duration(milliseconds: AppDimensions.animFast),
              child: Icon(
                isSelected ? item.activeIcon : item.icon,
                key: ValueKey(isSelected),
                color: color,
                size: AppDimensions.iconMedium,
              ),
            ),

            const SizedBox(height: AppDimensions.space2),

            // ── Label ──
            Text(
              item.label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: color,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

/// Data model for a bottom navigation item.
class SpBottomNavItem {
  const SpBottomNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
}
