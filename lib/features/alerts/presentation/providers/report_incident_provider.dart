import 'package:flutter/material.dart';

import '../../../../core/services/location_service.dart';
import '../../../../core/utils/logger.dart';
import '../../../map/data/models/incident_model.dart';
import '../../../map/data/models/lat_lng_model.dart';
import '../../domain/repositories/incident_repository.dart';

/// State management for the incident reporting workflow.
class ReportIncidentProvider extends ChangeNotifier {
  ReportIncidentProvider({
    required IncidentRepository repository,
  }) : _repository = repository;

  final IncidentRepository _repository;

  bool _isLoading = false;
  String? _errorMessage;
  bool _isSuccess = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isSuccess => _isSuccess;

  /// Submits an incident report.
  Future<bool> submitReport({
    required IncidentType type,
    required IncidentSeverity severity,
    required String description,
    String? imagePath,
    required String userId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _isSuccess = false;
    notifyListeners();

    try {
      // 1. Get current location
      final position = await LocationService.instance.getCurrentPosition();
      final location = LatLngModel(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      // 2. Upload image if provided
      String? uploadedImageUrl;
      if (imagePath != null && imagePath.isNotEmpty) {
        uploadedImageUrl = await _repository.uploadIncidentImage(imagePath);
      }

      // 3. Create incident model
      final incident = IncidentModel(
        id: 'inc_${DateTime.now().millisecondsSinceEpoch}',
        title: _generateTitle(type),
        description: description,
        location: location,
        severity: severity,
        type: type,
        reportedAt: DateTime.now(),
        reportedBy: userId,
        imageUrl: uploadedImageUrl,
      );

      // 4. Submit to repository
      await _repository.submitIncident(incident);

      _isSuccess = true;
      AppLogger.info('Report submitted successfully', tag: 'ReportProvider');
      return true;
    } catch (e, st) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      AppLogger.error('Failed to submit report', error: e, stackTrace: st, tag: 'ReportProvider');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Reset provider state when the form is closed or reset.
  void reset() {
    _isLoading = false;
    _errorMessage = null;
    _isSuccess = false;
    notifyListeners();
  }

  String _generateTitle(IncidentType type) {
    return switch (type) {
      IncidentType.accident => 'Traffic Accident',
      IncidentType.roadBlock => 'Road Blocked',
      IncidentType.poorLighting => 'Poor Lighting',
      IncidentType.suspiciousActivity => 'Suspicious Activity',
      IncidentType.theft => 'Theft / Break-in',
      IncidentType.assault => 'Assault Reported',
      IncidentType.harassment => 'Harassment Reported',
      IncidentType.naturalHazard => 'Natural Hazard',
      IncidentType.other => 'Other Incident',
    };
  }
}
