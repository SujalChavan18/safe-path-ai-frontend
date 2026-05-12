import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_dimensions.dart';
import '../../services/map_style_service.dart';
import '../providers/map_provider.dart';
import '../providers/navigation_provider.dart';
import '../../../alerts/presentation/widgets/sos_button.dart';
import '../../../alerts/presentation/widgets/sos_modal.dart';
import '../widgets/incident_marker_sheet.dart';
import '../widgets/map_controls_overlay.dart';
import '../widgets/route_comparison_sheet.dart';

/// Main map screen for SafePath AI.
///
/// Displays a full-screen Google Map with:
/// - Dark futuristic styling
/// - Incident markers with severity coloring
/// - Heatmap circle overlays
/// - Route polylines
/// - Floating control buttons
/// - Bottom sheet on marker tap
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer2<MapProvider, NavigationProvider>(
        builder: (context, mapProvider, navProvider, _) {
          if (mapProvider.isLoading) {
            return const _MapLoadingState();
          }

          if (mapProvider.error != null) {
            return _MapErrorState(
              message: mapProvider.error!,
              onRetry: mapProvider.refresh,
            );
          }

          return Stack(
            children: [
              // ── Google Map ──
              GoogleMap(
                initialCameraPosition: mapProvider.cameraPosition,
                mapType: mapProvider.mapType,
                style: MapStyleService.darkStyle,
                onMapCreated: mapProvider.onMapCreated,
                onCameraMove: mapProvider.onCameraMove,
                onCameraIdle: mapProvider.onCameraIdle,
                markers: {
                  ...mapProvider.markers,
                  ...navProvider.routeMarkers,
                },
                circles: mapProvider.circles,
                polylines: navProvider.polylines,
                myLocationEnabled: false, // Custom marker instead
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
                compassEnabled: true,
                onTap: (_) => mapProvider.clearSelectedIncident(),
                padding: const EdgeInsets.only(
                  bottom: AppDimensions.bottomNavHeight + 16,
                ),
              ),

              // ── Controls overlay ──
              MapControlsOverlay(
                mapProvider: mapProvider,
                navigationProvider: navProvider,
              ),

              // ── Incident count badge ──
              Positioned(
                top: MediaQuery.of(context).padding.top + AppDimensions.space12,
                left: AppDimensions.space16,
                child: _IncidentCountBadge(
                  total: mapProvider.incidentCount,
                  critical: mapProvider.criticalCount,
                ),
              ),

              // ── Navigation info bar ──
              if (navProvider.isNavigating && navProvider.selectedRoute != null)
                Positioned(
                  top: MediaQuery.of(context).padding.top + AppDimensions.space12,
                  left: 0,
                  right: 0,
                  child: _NavigationInfoBar(provider: navProvider),
                ),

              // ── Route Comparison Sheet ──
              if (navProvider.status == NavigationStatus.routesReady)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: RouteComparisonSheet(provider: navProvider),
                ),

              // ── Incident detail sheet ──
              if (mapProvider.selectedIncident != null)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: IncidentMarkerSheet(
                    incident: mapProvider.selectedIncident!,
                    onClose: mapProvider.clearSelectedIncident,
                  ),
                ),

              // ── SOS Button ──
              if (mapProvider.selectedIncident == null && !navProvider.isNavigating)
                Positioned(
                  bottom: AppDimensions.bottomNavHeight + AppDimensions.space24,
                  left: AppDimensions.space16,
                  child: SosButton(
                    onPressed: () => SosModal.show(context),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  PRIVATE WIDGETS
// ═══════════════════════════════════════════════════════════

class _MapLoadingState extends StatelessWidget {
  const _MapLoadingState();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 2.5,
            ),
            SizedBox(height: AppDimensions.space16),
            Text(
              'Loading safety map...',
              style: TextStyle(
                color: AppColors.onSurfaceVariant,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapErrorState extends StatelessWidget {
  const _MapErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.map_outlined,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: AppDimensions.space16),
            Text(
              'Map Error',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppDimensions.space8),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.space32,
              ),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.space24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact badge showing incident counts.
class _IncidentCountBadge extends StatelessWidget {
  const _IncidentCountBadge({
    required this.total,
    required this.critical,
  });

  final int total;
  final int critical;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.space12,
        vertical: AppDimensions.space8,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: AppColors.outline),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: AppColors.primary,
            size: 18,
          ),
          const SizedBox(width: AppDimensions.space6),
          Text(
            '$total incidents',
            style: const TextStyle(
              color: AppColors.onSurface,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (critical > 0) ...[
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              width: 1,
              height: 14,
              color: AppColors.outline,
            ),
            Icon(
              Icons.error_rounded,
              color: AppColors.dangerZone,
              size: 14,
            ),
            const SizedBox(width: 3),
            Text(
              '$critical critical',
              style: const TextStyle(
                color: AppColors.dangerZone,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Top bar showing active navigation info.
class _NavigationInfoBar extends StatelessWidget {
  const _NavigationInfoBar({required this.provider});

  final NavigationProvider provider;

  @override
  Widget build(BuildContext context) {
    final route = provider.selectedRoute!;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.space16),
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.space16,
        vertical: AppDimensions.space12,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: route.safetyRating.color.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: route.safetyRating.color.withValues(alpha: 0.1),
            blurRadius: 12,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.navigation_rounded,
            color: route.safetyRating.color,
            size: 22,
          ),
          const SizedBox(width: AppDimensions.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  route.name,
                  style: const TextStyle(
                    color: AppColors.onSurface,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${provider.distanceRemainingFormatted} • ${provider.timeRemainingFormatted}',
                  style: const TextStyle(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: provider.stopNavigation,
            icon: const Icon(Icons.close_rounded),
            iconSize: 20,
            color: AppColors.onSurfaceVariant,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }
}
