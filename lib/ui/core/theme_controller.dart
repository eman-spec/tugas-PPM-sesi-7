import 'package:flutter/material.dart';

/// Kontroler tema global via ValueNotifier — tidak perlu Provider, cukup ValueListenableBuilder.
class ThemeController {
  ThemeController._();

  static final ValueNotifier<ThemeMode> themeMode =
      ValueNotifier(ThemeMode.system);

  /// Putar tema: System → Light → Dark → System.
  static void toggle() {
    switch (themeMode.value) {
      case ThemeMode.system:
        themeMode.value = ThemeMode.light;
      case ThemeMode.light:
        themeMode.value = ThemeMode.dark;
      case ThemeMode.dark:
        themeMode.value = ThemeMode.system;
    }
  }

  static IconData iconForMode(ThemeMode mode) => switch (mode) {
        ThemeMode.light => Icons.light_mode_rounded,
        ThemeMode.dark => Icons.dark_mode_rounded,
        ThemeMode.system => Icons.brightness_auto_rounded,
      };

  static String tooltipForMode(ThemeMode mode) => switch (mode) {
        ThemeMode.light => 'Mode Terang',
        ThemeMode.dark => 'Mode Gelap',
        ThemeMode.system => 'Ikuti Sistem',
      };
}

/// Tombol toggle tema yang bisa dipasang di AppBar mana saja.
class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.themeMode,
      builder: (context, mode, _) {
        return IconButton(
          icon: Icon(ThemeController.iconForMode(mode)),
          tooltip: ThemeController.tooltipForMode(mode),
          onPressed: ThemeController.toggle,
        );
      },
    );
  }
}
