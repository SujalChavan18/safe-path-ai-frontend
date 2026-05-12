import 'package:flutter/material.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_dimensions.dart';
import '../../../map/data/models/incident_model.dart';

/// A styled dropdown for selecting an [IncidentType].
class CategoryDropdown extends StatelessWidget {
  const CategoryDropdown({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final IncidentType? value;
  final ValueChanged<IncidentType?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<IncidentType>(
      initialValue: value,
      onChanged: onChanged,
      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.onSurfaceVariant),
      dropdownColor: AppColors.surface,
      style: const TextStyle(color: AppColors.onSurface, fontSize: 16),
      decoration: InputDecoration(
        labelText: 'Incident Category',
        labelStyle: const TextStyle(color: AppColors.onSurfaceVariant),
        filled: true,
        fillColor: AppColors.surfaceVariant.withValues(alpha: 0.5),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.space16,
          vertical: AppDimensions.space16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          borderSide: BorderSide(color: AppColors.outline.withValues(alpha: 0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          borderSide: BorderSide(color: AppColors.outline.withValues(alpha: 0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          borderSide: const BorderSide(color: AppColors.error),
        ),
      ),
      validator: (val) => val == null ? 'Please select a category' : null,
      items: IncidentType.values.map((type) {
        return DropdownMenuItem(
          value: type,
          child: Row(
            children: [
              Icon(type.icon, color: AppColors.onSurfaceVariant, size: 20),
              const SizedBox(width: AppDimensions.space12),
              Text(type.label),
            ],
          ),
        );
      }).toList(),
    );
  }
}
