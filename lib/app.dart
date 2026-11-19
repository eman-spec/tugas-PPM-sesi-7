import 'package:flutter/material.dart';
import 'ui/core/app_theme.dart';
import 'ui/core/theme_controller.dart';
import 'ui/shell/app_shell.dart';

/// Root widget Pawtime — mendukung ganti tema realtime via ThemeController.
class PawtimeApp extends StatelessWidget {
  const PawtimeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.themeMode,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'Pawtime',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: mode,
          home: const AppShell(),
        );
      },
    );
  }
}
