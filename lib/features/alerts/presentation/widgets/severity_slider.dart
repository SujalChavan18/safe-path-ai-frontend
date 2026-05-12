import 'package:flutter/material.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_dimensions.dart';
import '../../../map/data/models/incident_model.dart';

/// A custom slider that maps to [IncidentSeverity] levels and dynamically changes color.
class SeveritySlider extends StatelessWidget {
  const SeveritySlider({
    super.key,
    required this.severity,
    required this.onChanged,
  });

  final IncidentSeverity severity;
  final ValueChanged<IncidentSeverity> onChanged;

  @override
  Widget build(BuildContext context) {
    // Map severity to an index (0 to 3)
    final double value = IncidentSeverity.values.indexOf(severity).toDouble();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Severity Level',
              style: TextStyle(
                color: AppColors.onSurfaceVariant,
                fontSize: 14,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: severity.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
              ),
              child: Text(
                severity.label,
                style: TextStyle(
                  color: severity.color,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.space8),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: severity.color,
            inactiveTrackColor: AppColors.outline.withValues(alpha: 0.5),
            thumbColor: severity.color,
            overlayColor: severity.color.withValues(alpha: 0.2),
            trackHeight: 6,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
            tickMarkShape: const RoundSliderTickMarkShape(tickMarkRadius: 3),
            activeTickMarkColor: Colors.white.withValues(alpha: 0.5),
            inactiveTickMarkColor: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          child: Slider(
            value: value,
            min: 0,
            max: (IncidentSeverity.values.length - 1).toDouble(),
            divisions: IncidentSeverity.values.length - 1,
            onChanged: (val) {
              onChanged(IncidentSeverity.values[val.toInt()]);
            },
          ),
        ),
      ],
    );
  }
}
