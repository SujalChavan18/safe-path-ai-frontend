import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../config/theme/app_colors.dart';
import '../data/models/heatmap_point_model.dart';
import '../data/models/incident_model.dart';

/// Generates heatmap visualizations from weighted geographic data.
///
/// Since `google_maps_flutter` doesn't natively support heatmap tiles,
/// this service approximates heatmaps using semi-transparent [Circle]
/// overlays. Each circle's radius and color intensity is determined
/// by the point's weight.
///
/// **Future enhancement**: Replace with `google_maps_flutter_heatmap`
/// plugin or custom tile overlay for true raster heatmaps.
class HeatmapService {
  HeatmapService._();

  /// Convert incidents to heatmap points based on severity.
  static List<HeatmapPointModel> getHeatmapPoints(List<IncidentModel> incidents) {
    return incidents.map((incident) {
      final weight = switch (incident.severity) {
        IncidentSeverity.critical => 1.0,
        IncidentSeverity.high => 0.75,
        IncidentSeverity.medium => 0.5,
        IncidentSeverity.low => 0.25,
      };
      return HeatmapPointModel(
        location: incident.location,
        weight: weight,
        type: incident.type.name,
      );
    }).toList();
  }

  /// Build a set of circles representing heatmap intensity.
  ///
  /// Higher-weight points produce larger, more opaque circles.
  static Set<Circle> buildHeatmapCircles({
    required List<HeatmapPointModel> points,
  }) {
    return points.asMap().entries.map((entry) {
      final index = entry.key;
      final point = entry.value;

      return Circle(
        circleId: CircleId('heatmap_$index'),
        center: point.location.toGoogleLatLng(),
        radius: point.radiusMeters,
        fillColor: _getHeatColor(point.weight),
        strokeColor: _getHeatColor(point.weight).withValues(alpha: 0.3),
        strokeWidth: 1,
        zIndex: 0,
      );
    }).toSet();
  }

  /// Get the color for a heatmap point based on its weight.
  ///
  /// Uses a gradient from green (safe) → yellow → red (dangerous).
  static Color _getHeatColor(double weight) {
    final clamped = weight.clamp(0.0, 1.0);

    if (clamped >= 0.8) {
      return AppColors.dangerZone.withValues(alpha: 0.35);
    } else if (clamped >= 0.6) {
      return AppColors.accent.withValues(alpha: 0.28);
    } else if (clamped >= 0.4) {
      return AppColors.cautionZone.withValues(alpha: 0.22);
    } else if (clamped >= 0.2) {
      return AppColors.info.withValues(alpha: 0.15);
    } else {
      return AppColors.safeZone.withValues(alpha: 0.10);
    }
  }

  /// Build safety zone circles (larger, lower opacity).
  ///
  /// Used as an alternative to polygon-based safety zones.
  static Set<Circle> buildSafetyRadiusCircles({
    required LatLng center,
    required double radiusMeters,
    Color? color,
  }) {
    return {
      Circle(
        circleId: const CircleId('safety_radius_outer'),
        center: center,
        radius: radiusMeters,
        fillColor: (color ?? AppColors.primary).withValues(alpha: 0.05),
        strokeColor: (color ?? AppColors.primary).withValues(alpha: 0.2),
        strokeWidth: 1,
        zIndex: 0,
      ),
      Circle(
        circleId: const CircleId('safety_radius_inner'),
        center: center,
        radius: radiusMeters * 0.5,
        fillColor: (color ?? AppColors.primary).withValues(alpha: 0.08),
        strokeColor: (color ?? AppColors.primary).withValues(alpha: 0.3),
        strokeWidth: 1,
        zIndex: 0,
      ),
    };
  }

  /// Normalize heatmap weights to 0.0–1.0 range.
  ///
  /// Use when raw weight values are not pre-normalized.
  static List<HeatmapPointModel> normalizeWeights(
    List<HeatmapPointModel> points,
  ) {
    if (points.isEmpty) return [];

    final maxWeight = points.map((p) => p.weight).reduce(
        (a, b) => a > b ? a : b);
    if (maxWeight == 0) return points;

    return points
        .map((p) => HeatmapPointModel(
              location: p.location,
              weight: p.weight / maxWeight,
              type: p.type,
            ))
        .toList();
  }
}
