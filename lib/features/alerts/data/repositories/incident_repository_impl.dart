import '../../../../core/utils/logger.dart';
import '../../../map/data/datasources/backend_incident_datasource.dart';
import '../../../map/data/models/incident_model.dart';
import '../../domain/repositories/incident_repository.dart';

/// Backend-powered implementation of IncidentRepository.
class IncidentRepositoryImpl implements IncidentRepository {
  @override
  Future<void> submitIncident(
    IncidentModel incident,
  ) async {
    try {
      await BackendIncidentDatasource.submitIncident(
        incident,
      );

      AppLogger.info(
        'Successfully submitted incident: ${incident.id}',
        tag: 'IncidentRepo',
      );
    } catch (e, st) {
      AppLogger.error(
        'Failed to submit incident',
        error: e,
        stackTrace: st,
        tag: 'IncidentRepo',
      );

      throw Exception(
        'Failed to submit report.',
      );
    }
  }

  @override
  Future<List<IncidentModel>> getIncidents() async {
    try {
      return await BackendIncidentDatasource.getIncidents();
    } catch (e, st) {
      AppLogger.error(
        'Failed to get incidents',
        error: e,
        stackTrace: st,
        tag: 'IncidentRepo',
      );

      throw Exception(
        'Failed to load incidents.',
      );
    }
  }

  @override
  Stream<List<IncidentModel>> getIncidentsStream() async* {
    while (true) {
      try {
        final incidents =
            await BackendIncidentDatasource.getIncidents();

        yield incidents;

        await Future.delayed(
          const Duration(seconds: 10),
        );
      } catch (_) {
        yield [];

        await Future.delayed(
          const Duration(seconds: 10),
        );
      }
    }
  }

  @override
  Future<String?> uploadIncidentImage(
    String imagePath,
  ) async {
    // Future backend upload integration
    return null;
  }
}