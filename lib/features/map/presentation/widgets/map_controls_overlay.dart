import 'package:flutter/material.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_dimensions.dart';
import '../../data/models/incident_model.dart';
import '../providers/map_provider.dart';
import '../providers/navigation_provider.dart';

/// Floating control buttons overlaid on the map.
class MapControlsOverlay extends StatefulWidget {
  const MapControlsOverlay({
    super.key,
    required this.mapProvider,
    required this.navigationProvider,
  });

  final MapProvider mapProvider;
  final NavigationProvider navigationProvider;

  @override
  State<MapControlsOverlay> createState() => _MapControlsOverlayState();
}

class _MapControlsOverlayState extends State<MapControlsOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    // Start animation shortly after build
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildAnimatedBtn({
    required Widget child,
    required int index,
    required int total,
  }) {
    final start = index / total * 0.5;
    final end = start + 0.5;
    final animation = Tween<Offset>(
      begin: const Offset(1.5, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      ),
    );

    return SlideTransition(
      position: animation,
      child: FadeTransition(
        opacity: CurvedAnimation(
          parent: _controller,
          curve: Interval(start, end, curve: Curves.easeIn),
        ),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mapProv = widget.mapProvider;
    final navProv = widget.navigationProvider;
    const totalBtns = 5;

    return Positioned(
      right: AppDimensions.space16,
      bottom: AppDimensions.bottomNavHeight + AppDimensions.space24,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildAnimatedBtn(
            index: 0,
            total: totalBtns,
            child: _ControlBtn(
              icon: Icons.layers_rounded,
              tooltip: 'Map layers',
              onTap: () => _showLayerSheet(context),
            ),
          ),
          const SizedBox(height: AppDimensions.space8),
          _buildAnimatedBtn(
            index: 1,
            total: totalBtns,
            child: _ControlBtn(
              icon: _mapTypeIcon,
              tooltip: 'Map type',
              onTap: mapProv.toggleMapType,
            ),
          ),
          const SizedBox(height: AppDimensions.space8),
          _buildAnimatedBtn(
            index: 2,
            total: totalBtns,
            child: _ControlBtn(
              icon: Icons.route_rounded,
              tooltip: 'Safe routes',
              isActive: navProv.hasRoutes,
              activeColor: AppColors.safeZone,
              onTap: () {
                if (navProv.hasRoutes) {
                  navProv.reset();
                } else {
                  navProv.loadMockRoutes();
                }
              },
            ),
          ),
          const SizedBox(height: AppDimensions.space8),
          _buildAnimatedBtn(
            index: 3,
            total: totalBtns,
            child: _ControlBtn(
              icon: Icons.fit_screen_rounded,
              tooltip: 'Fit all',
              onTap: mapProv.fitAllIncidents,
            ),
          ),
          const SizedBox(height: AppDimensions.space12),
          _buildAnimatedBtn(
            index: 4,
            total: totalBtns,
            child: _ControlBtn(
              icon: mapProv.isTrackingLocation
                  ? Icons.my_location_rounded
                  : Icons.location_searching_rounded,
              tooltip: 'My location',
              isPrimary: true,
              isActive: mapProv.isTrackingLocation,
              onTap: () {
                if (mapProv.isTrackingLocation) {
                  mapProv.stopLocationTracking();
                } else {
                  mapProv.goToCurrentLocation();
                  mapProv.startLocationTracking();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  IconData get _mapTypeIcon => switch (widget.mapProvider.mapType.toString()) {
        'MapType.satellite' => Icons.satellite_alt_rounded,
        'MapType.terrain' => Icons.terrain_rounded,
        _ => Icons.map_outlined,
      };

  void _showLayerSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusLarge),
        ),
      ),
      builder: (_) => _LayerSheet(mapProvider: widget.mapProvider),
    );
  }
}

class _ControlBtn extends StatelessWidget {
  const _ControlBtn({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.isPrimary = false,
    this.isActive = false,
    this.activeColor,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool isPrimary;
  final bool isActive;
  final Color? activeColor;

  @override
  Widget build(BuildContext context) {
    final color = isActive
        ? (activeColor ?? AppColors.primary)
        : AppColors.onSurfaceVariant;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: isPrimary
            ? AppColors.primary.withValues(alpha: 0.15)
            : AppColors.surface.withValues(alpha: 0.9),
        shape: const CircleBorder(),
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.4),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Container(
            width: isPrimary ? 52 : 44,
            height: isPrimary ? 52 : 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isPrimary
                    ? AppColors.primary.withValues(alpha: 0.3)
                    : AppColors.outline,
              ),
            ),
            child: Icon(
              icon,
              color: isPrimary ? AppColors.primary : color,
              size: isPrimary ? 24 : 20,
            ),
          ),
        ),
      ),
    );
  }
}

class _LayerSheet extends StatelessWidget {
  const _LayerSheet({required this.mapProvider});
  final MapProvider mapProvider;

  @override
  Widget build(BuildContext context) {
    final layers = mapProvider.layers;
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.space20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: AppColors.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.space16),
          Text('Map Layers',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppDimensions.space16),
          _LayerTile(
            icon: Icons.location_on_rounded,
            label: 'Incident Markers',
            sub: '${mapProvider.incidentCount} active',
            active: layers.incidents,
            color: AppColors.accent,
            onChanged: (v) => mapProvider.toggleLayer(incidents: v),
          ),
          _LayerTile(
            icon: Icons.gradient_rounded,
            label: 'Danger Heatmap',
            sub: 'Incident density overlay',
            active: layers.heatmap,
            color: AppColors.dangerZone,
            onChanged: (v) => mapProvider.toggleLayer(heatmap: v),
          ),
          _LayerTile(
            icon: Icons.shield_rounded,
            label: 'Safety Zones',
            sub: 'Safety radius around you',
            active: layers.safetyZones,
            color: AppColors.safeZone,
            onChanged: (v) => mapProvider.toggleLayer(safetyZones: v),
          ),
          
          if (layers.heatmap) ...[
            const SizedBox(height: AppDimensions.space24),
            Text('Heatmap Filters',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    )),
            const SizedBox(height: AppDimensions.space16),
            
            // Severity Filter
            const Text('Severity', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: IncidentSeverity.values.map((severity) {
                  final isSelected = mapProvider.filterSeverity == severity;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(severity.label),
                      selected: isSelected,
                      onSelected: (selected) {
                        mapProvider.setFilters(
                          severity: selected ? severity : null,
                          category: mapProvider.filterCategory,
                        );
                      },
                      selectedColor: severity.color.withValues(alpha: 0.2),
                      labelStyle: TextStyle(
                        color: isSelected ? severity.color : AppColors.onSurfaceVariant,
                        fontSize: 12,
                      ),
                      side: BorderSide(
                        color: isSelected ? severity.color : AppColors.outline,
                      ),
                      backgroundColor: Colors.transparent,
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: AppDimensions.space16),

            // Category Filter
            const Text('Category', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: IncidentType.values.map((type) {
                  final isSelected = mapProvider.filterCategory == type;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(type.label),
                      selected: isSelected,
                      onSelected: (selected) {
                        mapProvider.setFilters(
                          severity: mapProvider.filterSeverity,
                          category: selected ? type : null,
                        );
                      },
                      selectedColor: AppColors.primary.withValues(alpha: 0.2),
                      labelStyle: TextStyle(
                        color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
                        fontSize: 12,
                      ),
                      side: BorderSide(
                        color: isSelected ? AppColors.primary : AppColors.outline,
                      ),
                      backgroundColor: Colors.transparent,
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
          
          const SizedBox(height: AppDimensions.space24),
        ],
      ),
    );
  }
}

class _LayerTile extends StatelessWidget {
  const _LayerTile({
    required this.icon,
    required this.label,
    required this.sub,
    required this.active,
    required this.color,
    required this.onChanged,
  });
  final IconData icon;
  final String label;
  final String sub;
  final bool active;
  final Color color;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: color.withValues(alpha: active ? 0.15 : 0.05),
          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(label,
          style: TextStyle(
            color: AppColors.onSurface, fontSize: 14,
            fontWeight: active ? FontWeight.w600 : FontWeight.w400,
          )),
      subtitle: Text(sub,
          style: const TextStyle(
              color: AppColors.onSurfaceVariant, fontSize: 12)),
      trailing: Switch.adaptive(
        value: active,
        onChanged: onChanged,
        activeTrackColor: color,
      ),
    );
  }
}
