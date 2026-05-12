import 'package:flutter/material.dart';

import '../../../../config/theme/app_colors.dart';
import 'lat_lng_model.dart';

/// Safety score rating for a route.
enum RouteSafetyRating {
  safe,
  moderate,
  caution,
  unsafe;

  String get label => switch (this) {
        safe => 'Safe',
        moderate => 'Moderate',
        caution => 'Caution',
        unsafe => 'Unsafe',
      };

  Color get color => switch (this) {
        safe => AppColors.safeZone,
        moderate => AppColors.info,
        caution => AppColors.cautionZone,
        unsafe => AppColors.dangerZone,
      };

  IconData get icon => switch (this) {
        safe => Icons.verified_user_rounded,
        moderate => Icons.shield_rounded,
        caution => Icons.shield_outlined,
        unsafe => Icons.warning_rounded,
      };
}

/// A navigable route with safety metadata.
class SafeRouteModel {
  const SafeRouteModel({
    required this.id,
    required this.name,
    required this.waypoints,
    required this.safetyScore,
    required this.distanceMeters,
    required this.durationSeconds,
    this.avoidedIncidents = 0,
    this.description,
  });

  final String id;
  final String name;

  /// Ordered list of waypoints defining the route path.
  final List<LatLngModel> waypoints;

  /// Safety score from 0 (unsafe) to 100 (very safe).
  final int safetyScore;

  /// Total route distance in meters.
  final double distanceMeters;

  /// Estimated travel duration in seconds.
  final int durationSeconds;

  /// Number of known incidents this route avoids.
  final int avoidedIncidents;

  final String? description;

  /// Derive the safety rating from the numeric score.
  RouteSafetyRating get safetyRating {
    if (safetyScore >= 80) return RouteSafetyRating.safe;
    if (safetyScore >= 60) return RouteSafetyRating.moderate;
    if (safetyScore >= 40) return RouteSafetyRating.caution;
    return RouteSafetyRating.unsafe;
  }

  /// Human-readable distance string.
  String get distanceFormatted {
    if (distanceMeters < 1000) return '${distanceMeters.toStringAsFixed(0)}m';
    return '${(distanceMeters / 1000).toStringAsFixed(1)}km';
  }

  /// Human-readable duration string.
  String get durationFormatted {
    final minutes = (durationSeconds / 60).ceil();
    if (minutes < 60) return '$minutes min';
    final hours = minutes ~/ 60;
    final remaining = minutes % 60;
    return '${hours}h ${remaining}m';
  }

  /// Create from a JSON map.
  factory SafeRouteModel.fromJson(Map<String, dynamic> json) {
    return SafeRouteModel(
      id: json['id'] as String,
      name: json['name'] as String,
      waypoints: (json['waypoints'] as List)
          .map((w) => LatLngModel.fromJson(w as Map<String, dynamic>))
          .toList(),
      safetyScore: json['safetyScore'] as int,
      distanceMeters: (json['distanceMeters'] as num).toDouble(),
      durationSeconds: json['durationSeconds'] as int,
      avoidedIncidents: json['avoidedIncidents'] as int? ?? 0,
      description: json['description'] as String?,
    );
  }

  /// Convert to a JSON map.
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'waypoints': waypoints.map((w) => w.toJson()).toList(),
        'safetyScore': safetyScore,
        'distanceMeters': distanceMeters,
        'durationSeconds': durationSeconds,
        'avoidedIncidents': avoidedIncidents,
        'description': description,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is SafeRouteModel && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
