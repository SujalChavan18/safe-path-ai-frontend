import 'package:flutter/material.dart';

import '../../../../core/services/location_service.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/models/alert_model.dart';
import '../../domain/repositories/alert_repository.dart';

class AlertProvider extends ChangeNotifier {
  AlertProvider({required AlertRepository repository}) : _repository = repository;

  final AlertRepository _repository;

  bool _isLoading = false;
  String? _error;
  List<AlertModel> _alerts = [];
  
  // SOS specific state
  bool _isSosTriggering = false;
  String? _sosError;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<AlertModel> get alerts => _alerts;

  bool get isSosTriggering => _isSosTriggering;
  String? get sosError => _sosError;

  int get unreadCount => _alerts.where((a) => !a.isRead).length;

  Future<void> loadAlerts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _alerts = await _repository.getAlerts();
    } catch (e, st) {
      _error = 'Failed to load alerts.';
      AppLogger.error('Failed to load alerts', error: e, stackTrace: st, tag: 'AlertProvider');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(String alertId) async {
    try {
      await _repository.markAsRead(alertId);
      final index = _alerts.indexWhere((a) => a.id == alertId);
      if (index != -1) {
        _alerts[index] = _alerts[index].copyWith(isRead: true);
        notifyListeners();
      }
    } catch (e) {
      AppLogger.error('Failed to mark alert as read: $e', tag: 'AlertProvider');
    }
  }

  Future<bool> triggerSOS({String? emergencyType}) async {
    _isSosTriggering = true;
    _sosError = null;
    notifyListeners();

    try {
      final position = await LocationService.instance.getCurrentPosition();
      await _repository.triggerSOS(
        latitude: position.latitude,
        longitude: position.longitude,
        emergencyType: emergencyType,
      );
      
      AppLogger.info('SOS Successfully triggered!', tag: 'AlertProvider');
      return true;
    } catch (e, st) {
      _sosError = 'Failed to trigger SOS. Please dial 911 directly.';
      AppLogger.error('SOS Failure', error: e, stackTrace: st, tag: 'AlertProvider');
      return false;
    } finally {
      _isSosTriggering = false;
      notifyListeners();
    }
  }
}
