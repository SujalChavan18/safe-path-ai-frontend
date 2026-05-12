import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_dimensions.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/presentation/widgets/skeleton_loader.dart';
import '../../../map/data/models/incident_model.dart';
import '../../../map/presentation/providers/map_provider.dart';
import '../widgets/alert_card.dart';
import '../widgets/heatmap_preview.dart';
import '../widgets/live_incident_feed.dart';
import '../widgets/quick_actions_row.dart';
import '../widgets/safety_score_card.dart';

/// The main dashboard screen acting as the command center.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final mapProvider = context.watch<MapProvider>();

    final incidents = mapProvider.incidents;

    // Sort incidents by time or severity for the feed
    final recentIncidents = List<IncidentModel>.from(incidents)
      ..sort((a, b) => b.reportedAt.compareTo(a.reportedAt));

    final highSeverityIncidents = incidents
        .where(
          (i) =>
              i.severity == IncidentSeverity.critical ||
              i.severity == IncidentSeverity.high,
        )
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── App Bar ──
          SliverAppBar(
            backgroundColor: AppColors.background,
            surfaceTintColor: Colors.transparent,
            pinned: true,
            expandedHeight: 120,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.space24,
                vertical: AppDimensions.space16,
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello, ${authProvider.displayName?.split(' ').first ?? 'Traveler'}',
                        style: const TextStyle(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 14,
                        ),
                      ),
                      const Text(
                        'Stay Safe Today',
                        style: TextStyle(
                          color: AppColors.onSurface,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.surfaceVariant,
                    child: Icon(
                      Icons.person,
                      color: AppColors.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Content ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.space24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Safety Score
                  SafetyScoreCard(
                    score: _calculateOverallScore(mapProvider),
                    locationName: 'San Francisco, CA',
                  ),

                  const SizedBox(height: AppDimensions.space24),

                  // Quick Actions
                  QuickActionsRow(
                    onReportIncident: () =>
                        context.pushNamed(RouteNames.reportIncidentName),
                    onShareLocation: () {
                      // Share logic
                    },
                    onSafeRoute: () {
                      context.goNamed(RouteNames.mapName);
                    },
                  ),

                  const SizedBox(height: AppDimensions.space32),

                  // Heatmap Preview
                  const Text(
                    'Risk Heatmap',
                    style: TextStyle(
                      color: AppColors.onSurface,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: AppDimensions.space16),

                  HeatmapPreview(
                    onTap: () {
                      mapProvider.toggleLayer(heatmap: true);

                      context.goNamed(RouteNames.mapName);
                    },
                  ),

                  const SizedBox(height: AppDimensions.space32),

                  // Active Alerts
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Nearby Alerts',
                        style: TextStyle(
                          color: AppColors.onSurface,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextButton(
                        onPressed: () =>
                            context.goNamed(RouteNames.alertsName),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                        ),
                        child: const Text('See All'),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppDimensions.space16),

                  // Horizontal scrolling alert cards
                  SizedBox(
                    height: 160,
                    child: mapProvider.isLoading
                        ? ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: 3,
                            itemBuilder: (context, index) => const Padding(
                              padding: EdgeInsets.only(
                                right: AppDimensions.space16,
                              ),
                              child: SkeletonLoader(
                                width: 260,
                                height: 160,
                                borderRadius:
                                    AppDimensions.radiusMedium,
                              ),
                            ),
                          )
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: highSeverityIncidents.length,
                            itemBuilder: (context, index) {
                              return AlertCard(
                                incident: highSeverityIncidents[index],
                                onTap: () {
                                  mapProvider.selectIncident(
                                    highSeverityIncidents[index].id,
                                  );

                                  context.goNamed(RouteNames.mapName);
                                },
                              );
                            },
                          ),
                  ),

                  const SizedBox(height: AppDimensions.space32),

                  // Live Feed
                  const Text(
                    'Live Incident Feed',
                    style: TextStyle(
                      color: AppColors.onSurface,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: AppDimensions.space8),

                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusLarge,
                      ),
                      border: Border.all(
                        color: AppColors.outline,
                      ),
                    ),
                    child: mapProvider.isLoading
                        ? ListView.separated(
                            padding: const EdgeInsets.all(
                              AppDimensions.space20,
                            ),
                            physics:
                                const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: 4,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 16),
                            itemBuilder: (context, index) => Row(
                              children: [
                                const SkeletonLoader(
                                  width: 40,
                                  height: 40,
                                  borderRadius: 8,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SkeletonLoader(
                                        width: 150,
                                        height: 14,
                                      ),
                                      const SizedBox(height: 8),
                                      const SkeletonLoader(
                                        width: double.infinity,
                                        height: 12,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : LiveIncidentFeed(
                            incidents: recentIncidents,
                            onIncidentTap: (id) {
                              mapProvider.selectIncident(id);

                              context.goNamed(RouteNames.mapName);
                            },
                          ),
                  ),

                  // Padding for bottom nav
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _calculateOverallScore(MapProvider provider) {
    if (provider.incidentCount == 0) return 98;

    if (provider.criticalCount > 5) return 35;

    if (provider.incidentCount > 10) return 65;

    return 85;
  }
}