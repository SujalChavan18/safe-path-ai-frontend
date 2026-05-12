import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_dimensions.dart';
import '../../../../core/providers/auth_provider.dart';
import '../widgets/auth_background.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/glass_container.dart';
import '../widgets/primary_auth_button.dart';
import '../widgets/social_login_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.loginWithEmail(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (success && mounted) {
      context.goNamed(RouteNames.mapName);
    } else if (mounted && authProvider.errorMessage != null) {
      _showError(authProvider.errorMessage!);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    FocusScope.of(context).unfocus();

    final authProvider = context.read<AuthProvider>();
    try {
      final success = await authProvider.signInWithGoogle();
      if (success && mounted) {
        context.goNamed(RouteNames.mapName);
      } else if (mounted && authProvider.errorMessage != null) {
        _showError(authProvider.errorMessage!);
      }
    } catch (e) {
      // User cancelled or silent error
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isLoading = authProvider.isLoading;

    return Scaffold(
      body: AuthBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.space24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                const Icon(
                  Icons.shield_rounded,
                  size: 64,
                  color: AppColors.primary,
                ),
                const SizedBox(height: AppDimensions.space24),
                
                const Text(
                  'Welcome Back',
                  style: TextStyle(
                    color: AppColors.onSurface,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppDimensions.space8),
                const Text(
                  'Sign in to access your safe routes',
                  style: TextStyle(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: AppDimensions.space32),

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
                          textInputAction: TextInputAction.next,
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
                        const SizedBox(height: AppDimensions.space16),
                        
                        AuthTextField(
                          controller: _passwordController,
                          hintText: 'Password',
                          icon: Icons.lock_outline_rounded,
                          isPassword: true,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _handleLogin(),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                        ),
                        
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: isLoading
                                ? null
                                : () => context.pushNamed(RouteNames.forgotPasswordName),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              minimumSize: Size.zero,
                            ),
                            child: const Text('Forgot password?'),
                          ),
                        ),
                        const SizedBox(height: AppDimensions.space24),

                        PrimaryAuthButton(
                          text: 'Sign In',
                          isLoading: isLoading,
                          onPressed: _handleLogin,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppDimensions.space24),
                
                Row(
                  children: [
                    Expanded(child: Divider(color: AppColors.outline)),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'OR',
                        style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12),
                      ),
                    ),
                    Expanded(child: Divider(color: AppColors.outline)),
                  ],
                ),
                
                const SizedBox(height: AppDimensions.space24),

                SocialLoginButton(
                  isLoading: isLoading,
                  onPressed: _handleGoogleSignIn,
                ),

                const SizedBox(height: AppDimensions.space32),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Don\'t have an account?',
                      style: TextStyle(color: AppColors.onSurfaceVariant),
                    ),
                    TextButton(
                      onPressed: isLoading
                          ? null
                          : () => context.pushNamed(RouteNames.registerName),
                      style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                      child: const Text('Sign Up', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
