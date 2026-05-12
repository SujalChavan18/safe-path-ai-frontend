import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_dimensions.dart';
import '../../../../core/providers/auth_provider.dart';
import '../widgets/auth_background.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/glass_container.dart';
import '../widgets/primary_auth_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleReset() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.sendPasswordReset(
      _emailController.text.trim(),
    );

    if (success && mounted) {
      setState(() => _emailSent = true);
    } else if (mounted && authProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage!),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.onSurface),
          onPressed: () => context.pop(),
        ),
      ),
      body: AuthBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.space24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _emailSent ? Icons.mark_email_read_rounded : Icons.lock_reset_rounded,
                  size: 64,
                  color: AppColors.primary,
                ),
                const SizedBox(height: AppDimensions.space24),
                
                Text(
                  _emailSent ? 'Email Sent' : 'Reset Password',
                  style: const TextStyle(
                    color: AppColors.onSurface,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppDimensions.space8),
                Text(
                  _emailSent 
                    ? 'Check your inbox for instructions to reset your password.'
                    : 'Enter your email address and we\'ll send you a link to reset your password.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: AppDimensions.space32),

                if (!_emailSent)
                  GlassContainer(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          AuthTextField(
                            controller: _emailController,
                            hintText: 'Email address',
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _handleReset(),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!value.contains('@')) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppDimensions.space32),

                          PrimaryAuthButton(
                            text: 'Send Reset Link',
                            isLoading: isLoading,
                            onPressed: _handleReset,
                          ),
                        ],
                      ),
                    ),
                  ),

                if (_emailSent)
                  PrimaryAuthButton(
                    text: 'Return to Login',
                    onPressed: () => context.pop(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
