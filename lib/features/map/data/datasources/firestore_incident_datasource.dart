import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/incident_model.dart';
import '../models/lat_lng_model.dart';

/// Production Firestore datasource for incidents.
class FirestoreIncidentDatasource {
  FirestoreIncidentDatasource._();

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionPath = 'incidents';

  /// Get all incidents (limited to 100 for performance).
  static Future<List<IncidentModel>> getIncidents() async {
    final snapshot = await _firestore
        .collection(_collectionPath)
        .orderBy('reportedAt', descending: true)
        .limit(100)
        .get();

    return snapshot.docs
        .map((doc) => IncidentModel.fromJson({'id': doc.id, ...doc.data()}))
        .toList();
  }

  /// Real-time stream of all incidents.
  static Stream<List<IncidentModel>> getIncidentsStream() {
    return _firestore
        .collection(_collectionPath)
        .orderBy('reportedAt', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => IncidentModel.fromJson({'id': doc.id, ...doc.data()}))
            .toList());
  }

  /// Get incidents near a specific location within a radius.
  /// (Uses a basic bounding box query in Firestore, precise distance
  /// filtering can be applied client-side).
  static Future<List<IncidentModel>> getIncidentsNear({
    required LatLngModel center,
    double radiusKm = 5.0,
  }) async {
    // 1 degree of latitude is ~111 km.
    final latDelta = radiusKm / 111.0;
    // 1 degree of longitude is ~111 km * cos(latitude).
    // For simplicity in a basic bounding box, we use a slightly larger delta.
    

    final minLat = center.latitude - latDelta;
    final maxLat = center.latitude + latDelta;
    
    // Firestore only allows one range filter per query.
    // We filter by latitude on server, and longitude on client.
    final snapshot = await _firestore
        .collection(_collectionPath)
        .where('location.latitude', isGreaterThanOrEqualTo: minLat)
        .where('location.latitude', isLessThanOrEqualTo: maxLat)
        .get();

    final incidents = snapshot.docs
        .map((doc) => IncidentModel.fromJson({'id': doc.id, ...doc.data()}))
        .where((inc) {
          // Client-side precise filtering
          final dist = inc.location.roughDistanceTo(center);
          return dist < (radiusKm * 0.009) * (radiusKm * 0.009);
        })
        .toList();

    return incidents;
  }

  /// Add a new incident.
  static Future<void> addIncident(IncidentModel incident) async {
    final data = incident.toJson();
    data.remove('id'); // Firestore auto-generates ID or we use doc(id)
    await _firestore.collection(_collectionPath).doc(incident.id).set(data);
  }
}
