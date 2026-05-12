import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../../config/routes/route_names.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_dimensions.dart';
import '../../../../core/presentation/widgets/skeleton_loader.dart';
import '../../../map/data/models/incident_model.dart';
import '../../domain/models/alert_model.dart';
import '../providers/alert_provider.dart';

/// Screen displaying the history of push notifications and emergency alerts.
class AlertHistoryScreen extends StatelessWidget {
  const AlertHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final alertProvider = context.watch<AlertProvider>();
    final alerts = alertProvider.alerts;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Emergency Alerts', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: alertProvider.isLoading && alerts.isEmpty
          ? _buildLoading()
          : alerts.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: () => alertProvider.loadAlerts(),
                  color: AppColors.primary,
                  backgroundColor: AppColors.surface,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(AppDimensions.space16),
                    itemCount: alerts.length,
                    separatorBuilder: (context, index) => const SizedBox(height: AppDimensions.space12),
                    itemBuilder: (context, index) {
                      final alert = alerts[index];
                      return _AlertListTile(
                        alert: alert,
                        onTap: () {
                          if (!alert.isRead) {
                            alertProvider.markAsRead(alert.id);
                          }
                          // Navigate to alert detail screen. We'll pass the ID.
                          context.pushNamed(
                            RouteNames.alertDetailName,
                            pathParameters: {'id': alert.id},
                          );
                        },
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildLoading() {
    return ListView.separated(
      padding: const EdgeInsets.all(AppDimensions.space16),
      itemCount: 6,
      separatorBuilder: (context, index) => const SizedBox(height: AppDimensions.space12),
      itemBuilder: (context, index) => const SkeletonLoader(width: double.infinity, height: 100, borderRadius: 12),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined, size: 64, color: AppColors.onSurfaceVariant.withValues(alpha: 0.5)),
          const SizedBox(height: AppDimensions.space16),
          const Text('No recent alerts', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 16)),
        ],
      ),
    );
  }
}

class _AlertListTile extends StatelessWidget {
  const _AlertListTile({required this.alert, required this.onTap});

  final AlertModel alert;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isCritical = alert.severity == IncidentSeverity.critical || alert.severity == IncidentSeverity.high;
    final color = isCritical ? AppColors.error : AppColors.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.space16),
        decoration: BoxDecoration(
          color: alert.isRead ? AppColors.surface : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          border: Border.all(
            color: alert.isRead ? AppColors.outline : color.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCritical ? Icons.warning_amber_rounded : Icons.info_outline_rounded,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: AppDimensions.space16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          alert.title,
                          style: TextStyle(
                            color: AppColors.onSurface,
                            fontWeight: alert.isRead ? FontWeight.w500 : FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        timeago.format(alert.timestamp),
                        style: TextStyle(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 12,
                          fontWeight: alert.isRead ? FontWeight.normal : FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    alert.message,
                    style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (!alert.isRead) ...[
              const SizedBox(width: 8),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
