import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_dimensions.dart';
import '../../../map/data/models/incident_model.dart';
import '../providers/alert_provider.dart';
import '../../../auth/presentation/widgets/primary_auth_button.dart';

/// Detailed view for a specific emergency alert.
class AlertDetailScreen extends StatelessWidget {
  const AlertDetailScreen({
    super.key,
    required this.alertId,
  });

  final String alertId;

  @override
  Widget build(BuildContext context) {
    // We look up the alert from the provider synchronously since it's already loaded.
    // In a real app, you might want to fetch it if it's missing (e.g. deep linked).
    final alertProvider = context.read<AlertProvider>();
    final alert = alertProvider.alerts.where((a) => a.id == alertId).firstOrNull;

    if (alert == null) {
      return Scaffold(
        appBar: AppBar(backgroundColor: Colors.transparent),
        body: const Center(child: Text('Alert not found or expired.')),
      );
    }

    final isCritical = alert.severity == IncidentSeverity.critical || alert.severity == IncidentSeverity.high;
    final color = isCritical ? AppColors.error : AppColors.primary;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.space24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: color.withValues(alpha: 0.5)),
              ),
              child: Text(
                alert.source.toUpperCase(),
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.space16),
            Text(
              alert.title,
              style: const TextStyle(
                color: AppColors.onSurface,
                fontSize: 28,
                fontWeight: FontWeight.w900,
                height: 1.2,
              ),
            ),
            const SizedBox(height: AppDimensions.space8),
            Text(
              DateFormat('MMMM d, yyyy • h:mm a').format(alert.timestamp),
              style: const TextStyle(
                color: AppColors.onSurfaceVariant,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: AppDimensions.space32),
            Container(
              padding: const EdgeInsets.all(AppDimensions.space20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
                border: Border.all(color: AppColors.outline),
              ),
              child: Text(
                alert.message,
                style: const TextStyle(
                  color: AppColors.onSurface,
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.space32),
            
            // If the alert is linked to a specific map incident, we can navigate there.
            if (alert.relatedIncidentId != null) ...[
              PrimaryAuthButton(
                text: 'View on Map',
                onPressed: () {
                  // context.read<MapProvider>().selectIncident(alert.relatedIncidentId!);
                  // context.goNamed(RouteNames.mapName);
                },
              ),
            ] else ...[
              PrimaryAuthButton(
                text: 'Open Safe Route Map',
                onPressed: () => context.goNamed('map'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
