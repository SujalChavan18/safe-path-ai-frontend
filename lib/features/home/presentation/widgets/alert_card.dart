import 'package:flutter/material.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_dimensions.dart';
import '../../../../core/presentation/widgets/bouncing_card.dart';
import '../../../map/data/models/incident_model.dart';

/// Individual alert card for the horizontal scrolling list.
class AlertCard extends StatelessWidget {
  const AlertCard({
    super.key,
    required this.incident,
    required this.onTap,
  });

  final IncidentModel incident;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return BouncingCard(
      onTap: onTap,
      child: Container(
        width: 260,
        margin: const EdgeInsets.only(right: AppDimensions.space16),
        padding: const EdgeInsets.all(AppDimensions.space16),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          border: Border.all(
            color: incident.severity.color.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: incident.severity.color.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Hero(
                  tag: 'alert_card_icon_${incident.id}',
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: incident.severity.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                    ),
                    child: Icon(
                      incident.type.icon,
                      color: incident.severity.color,
                      size: 16,
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.space8),
                Expanded(
                  child: Text(
                    incident.title,
                    style: const TextStyle(
                      color: AppColors.onSurface,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.space12),
            Text(
              incident.description,
              style: const TextStyle(
                color: AppColors.onSurfaceVariant,
                fontSize: 12,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Row(
              children: [
                Icon(
                  Icons.access_time_rounded,
                  color: AppColors.onSurfaceVariant,
                  size: 12,
                ),
                const SizedBox(width: 4),
                Text(
                  incident.timeAgo,
                  style: const TextStyle(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
                const Spacer(),
                if (incident.isVerified) ...[
                  const Icon(
                    Icons.verified_rounded,
                    color: AppColors.safeZone,
                    size: 12,
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Verified',
                    style: TextStyle(
                      color: AppColors.safeZone,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
