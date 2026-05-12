import '../../../../core/utils/logger.dart';
import '../../../map/data/datasources/firestore_incident_datasource.dart';
import '../../../map/data/models/incident_model.dart';
import '../../domain/repositories/incident_repository.dart';

/// Production implementation of [IncidentRepository] using Firestore.
class IncidentRepositoryImpl implements IncidentRepository {
  @override
  Future<void> submitIncident(IncidentModel incident) async {
    try {
      await FirestoreIncidentDatasource.addIncident(incident);
      AppLogger.info('Successfully submitted incident: ${incident.id}', tag: 'IncidentRepo');
    } catch (e, st) {
      AppLogger.error('Failed to submit incident', error: e, stackTrace: st, tag: 'IncidentRepo');
      throw Exception('Failed to submit report. Please try again.');
    }
  }

  @override
  Future<List<IncidentModel>> getIncidents() async {
    try {
      return await FirestoreIncidentDatasource.getIncidents();
    } catch (e, st) {
      AppLogger.error('Failed to get incidents', error: e, stackTrace: st, tag: 'IncidentRepo');
      throw Exception('Failed to load incidents.');
    }
  }

  @override
  Stream<List<IncidentModel>> getIncidentsStream() {
    return FirestoreIncidentDatasource.getIncidentsStream();
  }

  @override
  Future<String?> uploadIncidentImage(String imagePath) async {
    try {
      // TODO: Implement actual Firebase Storage upload here.
      // For now, simulate network upload delay and return a mock URL.
      AppLogger.info('Uploading image: $imagePath', tag: 'IncidentRepo');
      await Future.delayed(const Duration(seconds: 2));
      return 'https://example.com/mock_image.jpg';
    } catch (e, st) {
      AppLogger.error('Failed to upload image', error: e, stackTrace: st, tag: 'IncidentRepo');
      return null;
    }
  }
}
