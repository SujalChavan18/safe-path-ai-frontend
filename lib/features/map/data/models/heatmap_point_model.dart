import 'lat_lng_model.dart';

/// A weighted geographic point for heatmap visualization.
///
/// Used to represent incident density or danger intensity
/// at a specific location. Higher [weight] values produce
/// more intense heatmap coloring.
class HeatmapPointModel {
  const HeatmapPointModel({
    required this.location,
    required this.weight,
    this.type,
  });

  final LatLngModel location;

  /// Weight/intensity value (0.0 – 1.0).
  ///
  /// Determines the visual intensity on the heatmap:
  /// - 0.0–0.3: Low (green/blue tint)
  /// - 0.3–0.6: Medium (yellow tint)
  /// - 0.6–1.0: High (red tint)
  final double weight;

  /// Optional category for filtering heatmap layers.
  final String? type;

  /// Radius in meters for this heatmap point's influence area.
  double get radiusMeters {
    if (weight >= 0.8) return 120.0;
    if (weight >= 0.5) return 80.0;
    return 50.0;
  }

  /// Create from a JSON map.
  factory HeatmapPointModel.fromJson(Map<String, dynamic> json) {
    return HeatmapPointModel(
      location: LatLngModel.fromJson(json['location'] as Map<String, dynamic>),
      weight: (json['weight'] as num).toDouble(),
      type: json['type'] as String?,
    );
  }

  /// Convert to a JSON map.
  Map<String, dynamic> toJson() => {
        'location': location.toJson(),
        'weight': weight,
        'type': type,
      };
}
