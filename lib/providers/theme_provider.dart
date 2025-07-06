import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode themeMode = ThemeMode.system;

  bool get isDarkMode {
    // Si el tema es el del sistema, revisa el brillo actual del sistema
    final brightness = WidgetsBinding.instance.window.platformBrightness;
    return themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && brightness == Brightness.dark);
  }

  void toggleTheme(bool isOn) {
    themeMode = isOn ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void setSystemTheme() {
    themeMode = ThemeMode.system;
    notifyListeners();
  }
}
