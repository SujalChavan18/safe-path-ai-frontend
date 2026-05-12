import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'config/routes/app_router.dart';
import 'config/theme/app_theme.dart';
import 'core/providers/theme_provider.dart';

/// Root application widget for SafePath AI.
///
/// Configures Material 3 theming (dark/light via [ThemeProvider]),
/// GoRouter navigation, and global app settings.
class SafePathApp extends StatelessWidget {
  const SafePathApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp.router(
          // ── App Identity ──
          title: 'SafePath AI',
          debugShowCheckedModeBanner: false,

          // ── Theme ──
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,

          // ── Navigation ──
          routerConfig: AppRouter.router,
        );
      },
    );
  }
}
