import '../models/alert_model.dart';

/// Abstract repository interface for fetching alerts and triggering SOS.
abstract class AlertRepository {
  /// Fetches the user's alert history.
  Future<List<AlertModel>> getAlerts();

  /// Triggers a high-priority SOS emergency signal.
  Future<void> triggerSOS({
    required double latitude,
    required double longitude,
    String? emergencyType,
  });
  
  /// Marks an alert as read.
  Future<void> markAsRead(String alertId);
}
