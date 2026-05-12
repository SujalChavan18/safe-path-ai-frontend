import 'package:flutter/material.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_dimensions.dart';
import '../../../../core/presentation/widgets/bouncing_card.dart';
import '../../../map/data/models/incident_model.dart';

/// Vertical list displaying the most recent nearby incidents.
class LiveIncidentFeed extends StatelessWidget {
  const LiveIncidentFeed({
    super.key,
    required this.incidents,
    required this.onIncidentTap,
  });

  final List<IncidentModel> incidents;
  final ValueChanged<String> onIncidentTap;

  @override
  Widget build(BuildContext context) {
    if (incidents.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppDimensions.space32),
          child: Text(
            'No recent incidents reported nearby.',
            style: TextStyle(color: AppColors.onSurfaceVariant),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(), // Scroll handled by parent
      shrinkWrap: true,
      itemCount: incidents.length > 5 ? 5 : incidents.length, // Show max 5
      separatorBuilder: (context, index) => Divider(
        color: AppColors.outline.withValues(alpha: 0.5),
        height: 1,
      ),
      itemBuilder: (context, index) {
        final incident = incidents[index];
        return _FeedItem(
          incident: incident,
          onTap: () => onIncidentTap(incident.id),
        );
      },
    );
  }
}

class _FeedItem extends StatelessWidget {
  const _FeedItem({
    required this.incident,
    required this.onTap,
  });

  final IncidentModel incident;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return BouncingCard(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.space20,
          vertical: AppDimensions.space16,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Time & Severity ──
            SizedBox(
              width: 50,
              child: Column(
                children: [
                  Text(
                    incident.timeAgo.replaceAll(' ago', ''),
                    style: const TextStyle(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Hero(
                    tag: 'incident_icon_${incident.id}',
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: incident.severity.color,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: incident.severity.color.withValues(alpha: 0.5),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // ── Content ──
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
                  ),
                  const SizedBox(height: 4),
                  Text(
                    incident.description,
                    style: const TextStyle(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 13,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        incident.type.icon,
                        color: AppColors.onSurfaceVariant,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        incident.type.label,
                        style: const TextStyle(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.thumb_up_alt_rounded,
                        color: AppColors.primary,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${incident.upvotes}',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
