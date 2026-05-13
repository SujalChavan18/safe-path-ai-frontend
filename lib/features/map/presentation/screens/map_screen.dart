import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_dimensions.dart';
import '../providers/map_provider.dart';
import '../providers/navigation_provider.dart';
import '../../../alerts/presentation/widgets/sos_button.dart';
import '../../../alerts/presentation/widgets/sos_modal.dart';
import '../widgets/incident_marker_sheet.dart';
import '../widgets/map_controls_overlay.dart';
import '../widgets/route_comparison_sheet.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _controller;

  static const CameraPosition _fallbackPosition =
      CameraPosition(
    target: LatLng(12.9716, 77.5946), // Bengaluru
    zoom: 14,
  );

  bool _cameraMoved = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer2<MapProvider, NavigationProvider>(
        builder: (
          context,
          mapProvider,
          navProvider,
          _,
        ) {
          if (mapProvider.isLoading) {
            return const _MapLoadingState();
          }

          if (mapProvider.error != null) {
            return _MapErrorState(
              message: mapProvider.error!,
              onRetry: mapProvider.refresh,
            );
          }

          // AUTO MOVE CAMERA TO USER LOCATION
          if (!_cameraMoved &&
              mapProvider.currentPosition != null &&
              _controller != null) {
            _cameraMoved = true;

            Future.microtask(() async {
              await _controller!.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(
                    target: LatLng(
                      mapProvider
                          .currentPosition!
                          .latitude,
                      mapProvider
                          .currentPosition!
                          .longitude,
                    ),
                    zoom: 16,
                  ),
                ),
              );
            });
          }

          return Stack(
            children: [
              GoogleMap(
                initialCameraPosition:
                    _fallbackPosition,

                mapType: MapType.normal,

                myLocationEnabled: true,

                myLocationButtonEnabled: true,

                zoomControlsEnabled: true,

                compassEnabled: true,

                mapToolbarEnabled: true,

                trafficEnabled: false,

                buildingsEnabled: true,

                indoorViewEnabled: true,

                markers: {
                  // TEST MARKER
                  const Marker(
                    markerId:
                        MarkerId('bengaluru_test'),
                    position:
                        LatLng(12.9716, 77.5946),
                    infoWindow: InfoWindow(
                      title:
                          'Bengaluru Test Marker',
                    ),
                  ),

                  // INCIDENT MARKERS
                  ...mapProvider.markers,

                  // ROUTE MARKERS
                  ...navProvider.routeMarkers,
                },

                circles: mapProvider.circles,

                polylines: navProvider.polylines,

                onMapCreated: (controller) async {
                  _controller = controller;

                  mapProvider.onMapCreated(
                    controller,
                  );

                  // SMALL DELAY FOR MAP LOAD
                  await Future.delayed(
                    const Duration(seconds: 1),
                  );

                  // MOVE TO USER LOCATION
                  if (mapProvider.currentPosition !=
                      null) {
                    await controller.animateCamera(
                      CameraUpdate.newCameraPosition(
                        CameraPosition(
                          target: LatLng(
                            mapProvider
                                .currentPosition!
                                .latitude,
                            mapProvider
                                .currentPosition!
                                .longitude,
                          ),
                          zoom: 16,
                        ),
                      ),
                    );
                  } else {
                    // FALLBACK TO BENGALURU
                    await controller.animateCamera(
                      CameraUpdate.newCameraPosition(
                        _fallbackPosition,
                      ),
                    );
                  }
                },

                onTap: (_) {
                  mapProvider
                      .clearSelectedIncident();
                },

                padding: const EdgeInsets.only(
                  bottom:
                      AppDimensions
                              .bottomNavHeight +
                          16,
                ),
              ),

              // CONTROLS
              MapControlsOverlay(
                mapProvider: mapProvider,
                navigationProvider: navProvider,
              ),

              // INCIDENT BADGE
              Positioned(
                top:
                    MediaQuery.of(context)
                            .padding
                            .top +
                        AppDimensions.space12,
                left: AppDimensions.space16,
                child: _IncidentCountBadge(
                  total:
                      mapProvider.incidentCount,
                  critical:
                      mapProvider.criticalCount,
                ),
              ),

              // NAVIGATION BAR
              if (navProvider.isNavigating &&
                  navProvider.selectedRoute !=
                      null)
                Positioned(
                  top:
                      MediaQuery.of(context)
                              .padding
                              .top +
                          AppDimensions.space12,
                  left: 0,
                  right: 0,
                  child: _NavigationInfoBar(
                    provider: navProvider,
                  ),
                ),

              // ROUTE SHEET
              if (navProvider.status ==
                  NavigationStatus.routesReady)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: RouteComparisonSheet(
                    provider: navProvider,
                  ),
                ),

              // INCIDENT SHEET
              if (mapProvider.selectedIncident !=
                  null)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: IncidentMarkerSheet(
                    incident:
                        mapProvider
                            .selectedIncident!,
                    onClose:
                        mapProvider
                            .clearSelectedIncident,
                  ),
                ),

              // SOS BUTTON
              if (mapProvider.selectedIncident ==
                      null &&
                  !navProvider.isNavigating)
                Positioned(
                  bottom:
                      AppDimensions
                              .bottomNavHeight +
                          AppDimensions.space24,
                  left: AppDimensions.space16,
                  child: SosButton(
                    onPressed: () =>
                        SosModal.show(context),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

// LOADING STATE

class _MapLoadingState extends StatelessWidget {
  const _MapLoadingState();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

// ERROR STATE

class _MapErrorState extends StatelessWidget {
  const _MapErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.map_outlined,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(message),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

// INCIDENT COUNT BADGE

class _IncidentCountBadge
    extends StatelessWidget {
  const _IncidentCountBadge({
    required this.total,
    required this.critical,
  });

  final int total;

  final int critical;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius:
            BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Colors.cyanAccent,
            size: 18,
          ),
          const SizedBox(width: 6),
          Text(
            '$total incidents',
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// NAVIGATION INFO BAR

class _NavigationInfoBar
    extends StatelessWidget {
  const _NavigationInfoBar({
    required this.provider,
  });

  final NavigationProvider provider;

  @override
  Widget build(BuildContext context) {
    final route =
        provider.selectedRoute!;

    return Container(
      margin:
          const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius:
            BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.navigation,
            color: Colors.cyanAccent,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              route.name,
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          ),
          IconButton(
            onPressed:
                provider.stopNavigation,
            icon: const Icon(
              Icons.close,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}