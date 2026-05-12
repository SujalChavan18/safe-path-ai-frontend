import 'package:flutter/material.dart';

import '../../../../config/theme/app_colors.dart';
import 'lat_lng_model.dart';

/// Severity level of a safety incident.
enum IncidentSeverity {
  low,
  medium,
  high,
  critical;

  /// Display label.
  String get label => switch (this) {
        low => 'Low',
        medium => 'Medium',
        high => 'High',
        critical => 'Critical',
      };

  /// Color associated with this severity.
  Color get color => switch (this) {
        low => AppColors.info,
        medium => AppColors.cautionZone,
        high => AppColors.accent,
        critical => AppColors.dangerZone,
      };

  /// Google Maps marker hue.
  double get markerHue => switch (this) {
        low => 210.0, // blue
        medium => 50.0, // yellow
        high => 30.0, // orange
        critical => 0.0, // red
      };
}

/// Type/category of a safety incident.
enum IncidentType {
  theft,
  assault,
  harassment,
  accident,
  poorLighting,
  suspiciousActivity,
  naturalHazard,
  roadBlock,
  other;

  /// Display label.
  String get label => switch (this) {
        theft => 'Theft',
        assault => 'Assault',
        harassment => 'Harassment',
        accident => 'Accident',
        poorLighting => 'Poor Lighting',
        suspiciousActivity => 'Suspicious Activity',
        naturalHazard => 'Natural Hazard',
        roadBlock => 'Road Block',
        other => 'Other',
      };

  /// Icon for this incident type.
  IconData get icon => switch (this) {
        theft => Icons.money_off_rounded,
        assault => Icons.person_off_rounded,
        harassment => Icons.report_rounded,
        accident => Icons.car_crash_rounded,
        poorLighting => Icons.lightbulb_outline_rounded,
        suspiciousActivity => Icons.visibility_rounded,
        naturalHazard => Icons.flood_rounded,
        roadBlock => Icons.block_rounded,
        other => Icons.warning_amber_rounded,
      };
}

/// A safety incident reported at a specific location.
class IncidentModel {
  const IncidentModel({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.severity,
    required this.type,
    required this.reportedAt,
    this.reportedBy,
    this.isVerified = false,
    this.upvotes = 0,
    this.imageUrl,
  });

  final String id;
  final String title;
  final String description;
  final LatLngModel location;
  final IncidentSeverity severity;
  final IncidentType type;
  final DateTime reportedAt;
  final String? reportedBy;
  final bool isVerified;
  final int upvotes;
  final String? imageUrl;

  /// Create from a JSON map.
  factory IncidentModel.fromJson(Map<String, dynamic> json) {
    return IncidentModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      location: LatLngModel.fromJson(json['location'] as Map<String, dynamic>),
      severity: IncidentSeverity.values.byName(json['severity'] as String),
      type: IncidentType.values.byName(json['type'] as String),
      reportedAt: DateTime.parse(json['reportedAt'] as String),
      reportedBy: json['reportedBy'] as String?,
      isVerified: json['isVerified'] as bool? ?? false,
      upvotes: json['upvotes'] as int? ?? 0,
      imageUrl: json['imageUrl'] as String?,
    );
  }

  /// Convert to a JSON map.
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'location': location.toJson(),
        'severity': severity.name,
        'type': type.name,
        'reportedAt': reportedAt.toIso8601String(),
        'reportedBy': reportedBy,
        'isVerified': isVerified,
        'upvotes': upvotes,
        'imageUrl': imageUrl,
      };

  /// How long ago this incident was reported, as a human-readable string.
  String get timeAgo {
    final diff = DateTime.now().difference(reportedAt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  /// Create a copy with optional field overrides.
  IncidentModel copyWith({
    String? id,
    String? title,
    String? description,
    LatLngModel? location,
    IncidentSeverity? severity,
    IncidentType? type,
    DateTime? reportedAt,
    String? reportedBy,
    bool? isVerified,
    int? upvotes,
    String? imageUrl,
  }) {
    return IncidentModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      severity: severity ?? this.severity,
      type: type ?? this.type,
      reportedAt: reportedAt ?? this.reportedAt,
      reportedBy: reportedBy ?? this.reportedBy,
      isVerified: isVerified ?? this.isVerified,
      upvotes: upvotes ?? this.upvotes,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is IncidentModel && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
