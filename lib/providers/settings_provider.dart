import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Model for app settings.
class AppSettings {
  final bool isDarkMode;
  final String autoSaveFrequency;
  final String quality;

  AppSettings({
    required this.isDarkMode,
    required this.autoSaveFrequency,
    required this.quality,
  });

  AppSettings copyWith({
    bool? isDarkMode,
    String? autoSaveFrequency,
    String? quality,
  }) {
    return AppSettings(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      autoSaveFrequency: autoSaveFrequency ?? this.autoSaveFrequency,
      quality: quality ?? this.quality,
    );
  }
}

/// A StateNotifier that manages app settings.
class SettingsController extends StateNotifier<AppSettings> {
  SettingsController()
      : super(AppSettings(
          isDarkMode: false,
          autoSaveFrequency: "5 minutes",
          quality: "High",
        ));

  /// Toggle dark mode.
  void toggleDarkMode() {
    state = state.copyWith(isDarkMode: !state.isDarkMode);
  }

  /// Set auto-save frequency.
  void setAutoSaveFrequency(String frequency) {
    state = state.copyWith(autoSaveFrequency: frequency);
  }

  /// Set quality level.
  void setQuality(String quality) {
    state = state.copyWith(quality: quality);
  }
}

/// Provider for SettingsController.
final settingsProvider = StateNotifierProvider<SettingsController, AppSettings>(
  (ref) => SettingsController(),
);

/// Provider for the app's theme.
final themeProvider = Provider<ThemeData>((ref) {
  final settings = ref.watch(settingsProvider);
  
  if (settings.isDarkMode) {
    return ThemeData.dark().copyWith(
      primaryColor: Colors.black,
      scaffoldBackgroundColor: Colors.black,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      colorScheme: const ColorScheme.dark(
        primary: Colors.blueAccent,
        secondary: Colors.purpleAccent,
      ),
      sliderTheme: SliderThemeData(
        thumbColor: Colors.white,
        activeTrackColor: Colors.white,
        inactiveTrackColor: Colors.grey[800],
      ),
    );
  } else {
    return ThemeData.light().copyWith(
      primaryColor: Colors.white,
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        titleTextStyle: TextStyle(color: Colors.black, fontSize: 20),
      ),
      colorScheme: const ColorScheme.light(
        primary: Colors.blue,
        secondary: Colors.purple,
      ),
      sliderTheme: SliderThemeData(
        thumbColor: Colors.blue,
        activeTrackColor: Colors.blue,
        inactiveTrackColor: Colors.grey[300],
      ),
    );
  }
}); 