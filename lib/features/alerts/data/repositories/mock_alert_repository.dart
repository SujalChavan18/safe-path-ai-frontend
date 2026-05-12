import '../../../../core/utils/logger.dart';
import '../../../map/data/models/incident_model.dart';
import '../../domain/models/alert_model.dart';
import '../../domain/repositories/alert_repository.dart';

/// A mock implementation of [AlertRepository] for UI testing.
class MockAlertRepository implements AlertRepository {
  final List<AlertModel> _mockAlerts = [
    AlertModel(
      id: 'a1',
      title: 'Active Shooter Reported Nearby',
      message: 'Police activity at Market St & 4th. Please avoid the area immediately and seek shelter.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      severity: IncidentSeverity.critical,
      source: 'SFPD Emergency Alert',
      isRead: false,
    ),
    AlertModel(
      id: 'a2',
      title: 'Road Blocked',
      message: 'Major accident on Highway 101 Northbound. Severe delays expected. Alternative routes advised.',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      severity: IncidentSeverity.high,
      source: 'Traffic Control',
      isRead: true,
    ),
    AlertModel(
      id: 'a3',
      title: 'Weather Warning',
      message: 'Flash flood warning issued for your current route. Please exercise caution.',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      severity: IncidentSeverity.medium,
      source: 'National Weather Service',
      isRead: true,
    ),
  ];

  @override
  Future<List<AlertModel>> getAlerts() async {
    await Future.delayed(const Duration(milliseconds: 800)); // Network simulation
    return _mockAlerts;
  }

  @override
  Future<void> triggerSOS({
    required double latitude,
    required double longitude,
    String? emergencyType,
  }) async {
    AppLogger.info('Triggering SOS at $latitude, $longitude (${emergencyType ?? "General"})', tag: 'MockAlertRepo');
    await Future.delayed(const Duration(seconds: 2)); // Simulate distress beacon connection
  }

  @override
  Future<void> markAsRead(String alertId) async {
    final index = _mockAlerts.indexWhere((a) => a.id == alertId);
    if (index != -1) {
      _mockAlerts[index] = _mockAlerts[index].copyWith(isRead: true);
    }
  }
}
