import 'package:flutter/material.dart';
import '../viewmodels/theme_view_model.dart';
import '../theme/app_theme_data.dart';
import 'package:provider/provider.dart';

/// App Colors - Dynamic Theme Proxy
///
/// This class now acts as a bridge to the active ThemeViewModel.
/// Usage: AppColors.of(context).primary
class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  // Helper to get current theme data from context
  static AppThemeData of(BuildContext context) {
    return Provider.of<ThemeViewModel>(context, listen: true).currentTheme;
  }

  // Legacy static accessors are deprecated but kept for compatibility where context is hard to get.
  // Ideally, migrate widgets to use AppColors.of(context).primary
  // For now, we return a default (Mo Yu) to avoid breaking static analysis in non-context areas.
  static const Color _defaultPrimary = Color(0xFF4B5C5E);
  static const Color _defaultSecondary = Color(0xFFA6A6A6);
  static const Color _defaultSurface = Color(0xFF1C1C1C);
  static const Color _defaultBackground = Color(0xFF0A0A0A);

  static const Color primary = _defaultPrimary;
  static const Color primaryDark = _defaultPrimary; // Simplified for now
  static const Color primaryLight = _defaultPrimary; // Simplified for now

  static const Color secondary = _defaultSecondary;
  static const Color secondaryDark = _defaultSecondary;
  static const Color secondaryLight = _defaultSecondary;

  static const Color background = _defaultBackground;
  static const Color surface = _defaultSurface;
  static const Color surfaceHighlight = Color(0xFF25213E); // Keep as is for now

  static const Color textPrimary = Color(0xFFEDEDED);
  static const Color textSecondary = Color(0xFFB0B0C0);
  static const Color textHint = Color(0xFF6E6E80);

  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);

  // Gradients - These should also be dynamic
  static LinearGradient primaryGradient(BuildContext context) =>
      of(context).primaryGradient;
  static LinearGradient mysticGradient(BuildContext context) =>
      of(context).cardGradient;
}
