import '../../../map/data/models/incident_model.dart';

/// Represents an emergency push notification or broadcast alert.
class AlertModel {
  const AlertModel({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.severity,
    this.source = 'SafePath System',
    this.isRead = false,
    this.relatedIncidentId,
  });

  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final IncidentSeverity severity;
  final String source;
  final bool isRead;
  final String? relatedIncidentId;

  AlertModel copyWith({
    bool? isRead,
  }) {
    return AlertModel(
      id: id,
      title: title,
      message: message,
      timestamp: timestamp,
      severity: severity,
      source: source,
      isRead: isRead ?? this.isRead,
      relatedIncidentId: relatedIncidentId,
    );
  }
}
