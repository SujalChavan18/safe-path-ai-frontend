import '../../../map/data/models/incident_model.dart';

/// Abstract repository interface for managing incidents.
///
/// Ensures the presentation layer is decoupled from the underlying
/// data source (e.g., Firebase, REST API, or Mock).
abstract class IncidentRepository {
  /// Submit a new safety incident report.
  Future<void> submitIncident(IncidentModel incident);

  /// Fetch a list of recent active incidents.
  Future<List<IncidentModel>> getIncidents();

  /// Real-time stream of incidents.
  Stream<List<IncidentModel>> getIncidentsStream();

  /// Upload an image associated with an incident and return the URL.
  /// 
  /// Returns `null` if the upload fails or no image was provided.
  Future<String?> uploadIncidentImage(String imagePath);
}
