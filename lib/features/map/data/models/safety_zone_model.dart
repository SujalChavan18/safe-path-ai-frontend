import 'package:flutter/material.dart';

import '../../../../config/theme/app_colors.dart';
import 'lat_lng_model.dart';

/// Safety classification of a geographic zone.
enum SafetyLevel {
  safe,
  moderate,
  caution,
  danger;

  String get label => switch (this) {
        safe => 'Safe Zone',
        moderate => 'Moderate',
        caution => 'Caution Zone',
        danger => 'Danger Zone',
      };

  Color get color => switch (this) {
        safe => AppColors.safeZone,
        moderate => AppColors.info,
        caution => AppColors.cautionZone,
        danger => AppColors.dangerZone,
      };

  /// Fill color with transparency for map overlay.
  Color get fillColor => color.withValues(alpha: 0.15);

  /// Stroke color for polygon border.
  Color get strokeColor => color.withValues(alpha: 0.6);
}

/// A geographic zone with a safety classification.
class SafetyZoneModel {
  const SafetyZoneModel({
    required this.id,
    required this.name,
    required this.polygon,
    required this.safetyLevel,
    this.description,
    this.incidentCount = 0,
  });

  final String id;
  final String name;

  /// Polygon vertices defining the zone boundary.
  final List<LatLngModel> polygon;

  final SafetyLevel safetyLevel;
  final String? description;

  /// Number of recent incidents within this zone.
  final int incidentCount;

  /// Create from a JSON map.
  factory SafetyZoneModel.fromJson(Map<String, dynamic> json) {
    return SafetyZoneModel(
      id: json['id'] as String,
      name: json['name'] as String,
      polygon: (json['polygon'] as List)
          .map((p) => LatLngModel.fromJson(p as Map<String, dynamic>))
          .toList(),
      safetyLevel: SafetyLevel.values.byName(json['safetyLevel'] as String),
      description: json['description'] as String?,
      incidentCount: json['incidentCount'] as int? ?? 0,
    );
  }

  /// Convert to a JSON map.
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'polygon': polygon.map((p) => p.toJson()).toList(),
        'safetyLevel': safetyLevel.name,
        'description': description,
        'incidentCount': incidentCount,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is SafetyZoneModel && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
