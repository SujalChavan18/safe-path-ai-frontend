import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_dimensions.dart';
import '../../../auth/presentation/widgets/auth_background.dart';
import '../../../auth/presentation/widgets/auth_text_field.dart';
import '../../../auth/presentation/widgets/glass_container.dart';
import '../../../auth/presentation/widgets/primary_auth_button.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../map/data/models/incident_model.dart';
import '../providers/report_incident_provider.dart';
import '../widgets/category_dropdown.dart';
import '../widgets/image_picker_field.dart';
import '../widgets/location_display_card.dart';
import '../widgets/severity_slider.dart';

class ReportIncidentScreen extends StatefulWidget {
  const ReportIncidentScreen({super.key});

  @override
  State<ReportIncidentScreen> createState() => _ReportIncidentScreenState();
}

class _ReportIncidentScreenState extends State<ReportIncidentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  
  IncidentType? _selectedCategory;
  IncidentSeverity _severity = IncidentSeverity.medium;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) return;

    FocusScope.of(context).unfocus();

    final userId = context.read<AuthProvider>().userId;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to report.')),
      );
      return;
    }

    final provider = context.read<ReportIncidentProvider>();
    
    final success = await provider.submitReport(
      type: _selectedCategory!,
      severity: _severity,
      description: _descriptionController.text.trim(),
      userId: userId,
      // imagePath: null, // Image picking mock integrated later
    );

    if (success && mounted) {
      _showSuccessDialog();
    } else if (mounted && provider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage!),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
          side: const BorderSide(color: AppColors.outline),
        ),
        title: const Column(
          children: [
            Icon(
              Icons.check_circle_outline_rounded,
              color: AppColors.safeZone,
              size: 48,
            ),
            SizedBox(height: 16),
            Text(
              'Report Submitted',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.onSurface),
            ),
          ],
        ),
        content: const Text(
          'Thank you for helping keep the community safe. Your report is being processed.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.onSurfaceVariant),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          PrimaryAuthButton(
            text: 'Return to Map',
            onPressed: () {
              Navigator.pop(context); // close dialog
              context.pop(); // return to previous screen
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reportProvider = context.watch<ReportIncidentProvider>();
    final isLoading = reportProvider.isLoading;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Report Incident',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.onSurface),
          onPressed: () => context.pop(),
        ),
      ),
      body: AuthBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.space24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GlassContainer(
                    padding: const EdgeInsets.all(AppDimensions.space20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'What\'s happening?',
                          style: TextStyle(
                            color: AppColors.onSurface,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.space20),
                        
                        CategoryDropdown(
                          value: _selectedCategory,
                          onChanged: (val) => setState(() => _selectedCategory = val),
                        ),
                        const SizedBox(height: AppDimensions.space20),

                        AuthTextField(
                          controller: _descriptionController,
                          hintText: 'Add details (optional)',
                          icon: Icons.notes_rounded,
                          textInputAction: TextInputAction.done,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimensions.space24),

                  GlassContainer(
                    padding: const EdgeInsets.all(AppDimensions.space20),
                    child: SeveritySlider(
                      severity: _severity,
                      onChanged: (val) => setState(() => _severity = val),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.space24),

                  GlassContainer(
                    padding: const EdgeInsets.all(AppDimensions.space20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Media & Location',
                          style: TextStyle(
                            color: AppColors.onSurface,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.space20),
                        const ImagePickerField(),
                        const SizedBox(height: AppDimensions.space16),
                        const LocationDisplayCard(),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimensions.space40),

                  PrimaryAuthButton(
                    text: 'Submit Report',
                    isLoading: isLoading,
                    onPressed: _handleSubmit,
                  ),
                  const SizedBox(height: AppDimensions.space40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
