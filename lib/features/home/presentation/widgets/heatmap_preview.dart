import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_dimensions.dart';
import '../../../map/presentation/providers/map_provider.dart';
import '../../../map/services/map_style_service.dart';

/// A miniature, non-interactive map preview showing the heatmap.
class HeatmapPreview extends StatelessWidget {
  const HeatmapPreview({
    super.key,
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Consumer<MapProvider>(
      builder: (context, mapProvider, _) {
        final position = mapProvider.userLocation ?? mapProvider.cameraPosition.target;

        return GestureDetector(
          onTap: onTap,
          child: Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
              border: Border.all(color: AppColors.outline),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
              child: Stack(
                children: [
                  // ── Map Background ──
                  // We disable all gestures to make it a pure preview
                  GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: position,
                      zoom: 13.0,
                    ),
                    style: MapStyleService.darkStyle,
                    circles: mapProvider.circles,
                    markers: mapProvider.markers, // Optionally hide markers to focus on heatmap
                    zoomControlsEnabled: false,
                    scrollGesturesEnabled: false,
                    tiltGesturesEnabled: false,
                    rotateGesturesEnabled: false,
                    zoomGesturesEnabled: false,
                    myLocationButtonEnabled: false,
                    mapToolbarEnabled: false,
                    compassEnabled: false,
                  ),

                  // ── Gradient Overlay ──
                  // Adds a vignette effect to blend the map into the dark theme
                  Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          Colors.transparent,
                          AppColors.surface.withValues(alpha: 0.8),
                        ],
                        radius: 1.2,
                        center: Alignment.center,
                      ),
                    ),
                  ),

                  // ── Title & Expand Button ──
                  Positioned(
                    top: AppDimensions.space12,
                    left: AppDimensions.space16,
                    right: AppDimensions.space12,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surface.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                            border: Border.all(color: AppColors.outline),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.gradient_rounded,
                                color: AppColors.dangerZone,
                                size: 14,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Risk Heatmap',
                                style: TextStyle(
                                  color: AppColors.onSurface,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.surface.withValues(alpha: 0.8),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.open_in_full_rounded,
                            color: AppColors.onSurfaceVariant,
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
