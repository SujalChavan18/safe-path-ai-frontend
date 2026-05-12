import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_dimensions.dart';
import '../providers/alert_provider.dart';

/// Modal bottom sheet for triggering SOS to prevent accidental presses.
class SosModal extends StatelessWidget {
  const SosModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const SosModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final alertProvider = context.watch<AlertProvider>();
    final isTriggering = alertProvider.isSosTriggering;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + AppDimensions.space24,
        top: AppDimensions.space24,
        left: AppDimensions.space24,
        right: AppDimensions.space24,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusLarge),
        ),
        border: Border(
          top: BorderSide(color: AppColors.error, width: 2),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.warning_rounded,
              color: AppColors.error,
              size: 48,
            ),
            const SizedBox(height: AppDimensions.space16),
            const Text(
              'EMERGENCY SOS',
              style: TextStyle(
                color: AppColors.onSurface,
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: AppDimensions.space8),
            const Text(
              'This will share your live location with emergency services and emergency contacts.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.onSurfaceVariant,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: AppDimensions.space32),

            if (alertProvider.sosError != null) ...[
              Text(
                alertProvider.sosError!,
                style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.space16),
            ],

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: isTriggering
                    ? null
                    : () async {
                        final success = await alertProvider.triggerSOS();
                        if (success && context.mounted) {
                          context.pop(); // Close modal
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('SOS Signal Transmitted! Help is on the way.'),
                              backgroundColor: AppColors.error,
                              duration: Duration(seconds: 4),
                            ),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                  ),
                ),
                child: isTriggering
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                      )
                    : const Text(
                        'HOLD TO CONFIRM SOS',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                      ),
              ),
            ),
            const SizedBox(height: AppDimensions.space16),
            
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton(
                onPressed: isTriggering ? null : () => context.pop(),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.outline),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                  ),
                ),
                child: const Text(
                  'CANCEL',
                  style: TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
