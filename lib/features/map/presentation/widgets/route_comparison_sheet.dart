import 'package:flutter/material.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_dimensions.dart';
import '../../../auth/presentation/widgets/primary_auth_button.dart';
import '../../data/models/safe_route_model.dart';
import '../providers/navigation_provider.dart';

/// A bottom sheet that allows users to compare and select a safe route.
class RouteComparisonSheet extends StatelessWidget {
  const RouteComparisonSheet({
    super.key,
    required this.provider,
  });

  final NavigationProvider provider;

  @override
  Widget build(BuildContext context) {
    if (provider.status != NavigationStatus.routesReady ||
        provider.availableRoutes.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: AppDimensions.space20,
        left: AppDimensions.space20,
        right: AppDimensions.space20,
        bottom: MediaQuery.of(context).padding.bottom + AppDimensions.space20,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.95),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusLarge),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
        border: const Border(
          top: BorderSide(color: AppColors.outline),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header & Sort Toggles
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Route Options',
                style: TextStyle(
                  color: AppColors.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: RouteSortMode.values.map((mode) {
                  final isSelected = provider.sortMode == mode;
                  return Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: InkWell(
                      onTap: () => provider.setSortMode(mode),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withValues(alpha: 0.2)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.outline,
                          ),
                        ),
                        child: Text(
                          mode.name.toUpperCase(),
                          style: TextStyle(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.onSurfaceVariant,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.space16),

          // Route List
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 220),
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: provider.availableRoutes.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final route = provider.availableRoutes[index];
                final isSelected = provider.selectedRoute?.id == route.id;
                return _RouteCard(
                  route: route,
                  isSelected: isSelected,
                  onTap: () => provider.selectRoute(route.id),
                );
              },
            ),
          ),
          const SizedBox(height: AppDimensions.space20),

          // Start Button
          PrimaryAuthButton(
            text: 'Start Navigation',
            onPressed: provider.selectedRoute != null
                ? provider.startNavigation
                : () {},
          ),
        ],
      ),
    );
  }
}

class _RouteCard extends StatelessWidget {
  const _RouteCard({
    required this.route,
    required this.isSelected,
    required this.onTap,
  });

  final SafeRouteModel route;
  final bool isSelected;
  final VoidCallback onTap;

  String _formatDistance(double meters) {
    if (meters < 1000) return '${meters.toStringAsFixed(0)}m';
    return '${(meters / 1000).toStringAsFixed(1)}km';
  }

  String _formatTime(int seconds) {
    final minutes = (seconds / 60).ceil();
    if (minutes < 60) return '$minutes min';
    final hours = minutes ~/ 60;
    final remaining = minutes % 60;
    return '${hours}h ${remaining}m';
  }

  @override
  Widget build(BuildContext context) {
    final safetyColor = route.safetyRating.color;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.space12),
        decoration: BoxDecoration(
          color: isSelected
              ? safetyColor.withValues(alpha: 0.1)
              : AppColors.background,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          border: Border.all(
            color: isSelected ? safetyColor : AppColors.outline,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: safetyColor.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.directions_walk_rounded,
                color: safetyColor,
                size: 20,
              ),
            ),
            const SizedBox(width: AppDimensions.space12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          route.name,
                          style: TextStyle(
                            color: AppColors.onSurface,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w500,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        _formatTime(route.durationSeconds),
                        style: TextStyle(
                          color: isSelected ? safetyColor : AppColors.onSurface,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDistance(route.distanceMeters),
                        style: const TextStyle(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: safetyColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: safetyColor.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          route.safetyRating.label.toUpperCase(),
                          style: TextStyle(
                            color: safetyColor,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
