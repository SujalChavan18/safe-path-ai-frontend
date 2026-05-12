import 'package:flutter/material.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_dimensions.dart';
import '../../../auth/presentation/widgets/glass_container.dart';
import '../../data/models/incident_model.dart';

/// Bottom sheet displaying incident details when a marker is tapped.
class IncidentMarkerSheet extends StatelessWidget {
  const IncidentMarkerSheet({
    super.key,
    required this.incident,
    required this.onClose,
  });

  final IncidentModel incident;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.space12),
      child: GlassContainer(
        padding: const EdgeInsets.all(AppDimensions.space16),
        child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Hero(
                tag: 'incident_icon_${incident.id}',
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: incident.severity.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                  ),
                  child: Icon(
                    incident.type.icon,
                    color: incident.severity.color,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      incident.title,
                      style: const TextStyle(
                        color: AppColors.onSurface,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        _SeverityBadge(severity: incident.severity),
                        const SizedBox(width: 8),
                        Text(
                          incident.type.label,
                          style: const TextStyle(
                            color: AppColors.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          incident.timeAgo,
                          style: const TextStyle(
                            color: AppColors.onSurfaceVariant,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onClose,
                icon: const Icon(Icons.close_rounded, size: 20),
                color: AppColors.onSurfaceVariant,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.space12),

          // Description
          Text(
            incident.description,
            style: const TextStyle(
              color: AppColors.onSurfaceVariant,
              fontSize: 13,
              height: 1.4,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: AppDimensions.space12),

          // Footer
          Row(
            children: [
              if (incident.isVerified)
                _InfoChip(
                  icon: Icons.verified_rounded,
                  label: 'Verified',
                  color: AppColors.safeZone,
                ),
              if (incident.isVerified) const SizedBox(width: 8),
              _InfoChip(
                icon: Icons.thumb_up_alt_rounded,
                label: '${incident.upvotes}',
                color: AppColors.primary,
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () {
                  // TODO: Navigate to full incident detail
                },
                icon: const Icon(Icons.open_in_new_rounded, size: 16),
                label: const Text('Details'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  textStyle: const TextStyle(fontSize: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  minimumSize: const Size(0, 32),
                ),
              ),
            ],
          ),
        ],
      ),
      ),
    );
  }
}

class _SeverityBadge extends StatelessWidget {
  const _SeverityBadge({required this.severity});
  final IncidentSeverity severity;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: severity.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        severity.label,
        style: TextStyle(
          color: severity.color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
