import 'package:flutter/material.dart';
import '../theme/app_theme_data.dart';

class ThemeViewModel extends ChangeNotifier {
  AppThemeData _currentTheme;

  ThemeViewModel({AppThemeData? initialTheme})
    : _currentTheme = initialTheme ?? AppThemeData.moYu; // 默认为墨玉（深色）

  AppThemeData get currentTheme => _currentTheme;
  List<AppThemeData> get availableThemes => AppThemeData.presets;

  void setTheme(AppThemeData theme) {
    if (_currentTheme != theme) {
      _currentTheme = theme;
      notifyListeners();
    }
  }

  /// Convenience method to set theme by index
  void setThemeByIndex(int index) {
    if (index >= 0 && index < availableThemes.length) {
      setTheme(availableThemes[index]);
    }
  }

  /// Get ThemeData for Material App
  ThemeData get materialThemeData {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: _currentTheme.primaryColor,
      scaffoldBackgroundColor: _currentTheme.backgroundColor,
      colorScheme: ColorScheme.dark(
        primary: _currentTheme.primaryColor,
        secondary: _currentTheme.secondaryColor,
        surface: _currentTheme.surfaceColor,
        // Using surfaceContainer for new Material 3 roles if needed,
        // but mapping basic surface here
        surfaceContainerHighest: _currentTheme.surfaceColor.withOpacity(0.8),
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: _currentTheme.textColor,
      ),
      useMaterial3: true,
      cardTheme: CardThemeData(
        color: _currentTheme.surfaceColor,
        shadowColor: Colors.black.withOpacity(0.4),
      ),
      // Extend with more specific theme data as needed
    );
  }
}
