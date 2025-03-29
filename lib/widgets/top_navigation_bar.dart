import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inkspi/providers/drawing_controller.dart';
import 'package:inkspi/providers/settings_provider.dart';

class TopNavigationBar extends ConsumerWidget {
  const TopNavigationBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Access the drawing controller
    final drawingController = ref.watch(drawingControllerProvider.notifier);
    final settings = ref.watch(settingsProvider);

    return Container(
      height: kToolbarHeight,
      color: Theme.of(context).brightness == Brightness.dark 
          ? Colors.black.withOpacity(0.6)
          : Colors.white.withOpacity(0.8),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.arrow_back, 
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
            ),
            onPressed: () {
              // Clear the canvas first
              drawingController.clearCanvas();
              // Then navigate to home
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
          const Spacer(),
          IconButton(
            icon: Icon(
              Icons.undo, 
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
            ),
            onPressed: drawingController.undo,
          ),
          IconButton(
            icon: Icon(
              Icons.redo, 
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
            ),
            onPressed: drawingController.redo,
          ),
          IconButton(
            icon: Icon(
              Icons.delete,
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
            ),
            onPressed: drawingController.clearCanvas,
          ),
          IconButton(
            icon: Icon(
              Icons.settings, 
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
            ),
            onPressed: () => _showSettings(context, ref),
          ),
        ],
      ),
    );
  }

  void _showSettings(BuildContext context, WidgetRef ref) {
    final settingsController = ref.read(settingsProvider.notifier);
    final settings = ref.read(settingsProvider);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).brightness == Brightness.dark 
          ? Colors.black87
          : Colors.white,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Settings",
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              _buildSettingItem(
                context: context,
                icon: Icons.color_lens,
                title: "Theme",
                subtitle: settings.isDarkMode ? "Dark mode" : "Light mode",
                onTap: () => _showThemeOptions(context, ref),
              ),
              Divider(
                color: Theme.of(context).brightness == Brightness.dark ? Colors.grey : Colors.grey[300],
              ),
              _buildSettingItem(
                context: context,
                icon: Icons.save,
                title: "Auto-save",
                subtitle: settings.autoSaveFrequency,
                onTap: () => _showAutoSaveOptions(context, ref),
              ),
              Divider(
                color: Theme.of(context).brightness == Brightness.dark ? Colors.grey : Colors.grey[300],
              ),
              _buildSettingItem(
                context: context,
                icon: Icons.hd,
                title: "Quality",
                subtitle: settings.quality,
                onTap: () => _showQualityOptions(context, ref),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showThemeOptions(BuildContext context, WidgetRef ref) {
    final settingsController = ref.read(settingsProvider.notifier);
    
    // Close the settings sheet first 
    Navigator.pop(context);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Choose Theme"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Consumer(builder: (context, ref, _) {
              final isDarkMode = ref.watch(settingsProvider).isDarkMode;
              return Column(
                children: [
                  ListTile(
                    title: const Text("Light Theme"),
                    leading: const Icon(Icons.wb_sunny),
                    selected: !isDarkMode,
                    onTap: () {
                      if (isDarkMode) {
                        settingsController.toggleDarkMode();
                      }
                      Navigator.pop(context);
                      _showSettingChangedSnackbar(context, "Theme changed to Light");
                    },
                  ),
                  ListTile(
                    title: const Text("Dark Theme"),
                    leading: const Icon(Icons.nightlight_round),
                    selected: isDarkMode,
                    onTap: () {
                      if (!isDarkMode) {
                        settingsController.toggleDarkMode();
                      }
                      Navigator.pop(context);
                      _showSettingChangedSnackbar(context, "Theme changed to Dark");
                    },
                  ),
                ],
              );
            }),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
        ],
      ),
    );
  }

  void _showAutoSaveOptions(BuildContext context, WidgetRef ref) {
    final settingsController = ref.read(settingsProvider.notifier);
    
    // Close the settings sheet first
    Navigator.pop(context);
    
    final options = ["Off", "1 minute", "5 minutes", "10 minutes", "30 minutes"];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Auto-save Frequency"),
        content: Consumer(builder: (context, ref, _) {
          final currentSetting = ref.watch(settingsProvider).autoSaveFrequency;
          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: options.map((option) => 
                ListTile(
                  title: Text(option),
                  selected: currentSetting == option,
                  onTap: () {
                    settingsController.setAutoSaveFrequency(option);
                    Navigator.pop(context);
                    _showAutoSaveConfirmation(context, option);
                  },
                )
              ).toList(),
            ),
          );
        }),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
        ],
      ),
    );
  }

  void _showAutoSaveConfirmation(BuildContext context, String frequency) {
    if (frequency == "Off") {
      _showSettingChangedSnackbar(context, "Auto-save turned off");
      return;
    }
    
    _showSettingChangedSnackbar(context, "Auto-save set to $frequency");
  }

  void _showQualityOptions(BuildContext context, WidgetRef ref) {
    final settingsController = ref.read(settingsProvider.notifier);
    
    // Close the settings sheet first
    Navigator.pop(context);
    
    final options = ["Low", "Medium", "High", "Ultra"];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Quality Settings"),
        content: Consumer(builder: (context, ref, _) {
          final currentQuality = ref.watch(settingsProvider).quality;
          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: options.map((option) => 
                ListTile(
                  title: Text(option),
                  subtitle: _getQualityDescription(option),
                  selected: currentQuality == option,
                  onTap: () {
                    settingsController.setQuality(option);
                    Navigator.pop(context);
                    _showSettingChangedSnackbar(context, "Quality set to $option");
                  },
                )
              ).toList(),
            ),
          );
        }),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
        ],
      ),
    );
  }
  
  void _showSettingChangedSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(8),
        content: Text(message),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: "OK",
          onPressed: () {},
        ),
      ),
    );
  }

  Text _getQualityDescription(String quality) {
    switch (quality) {
      case "Low":
        return const Text("Faster performance, lower resolution");
      case "Medium":
        return const Text("Balanced performance and quality");
      case "High":
        return const Text("High resolution, may affect performance");
      case "Ultra":
        return const Text("Maximum quality");
      default:
        return const Text("");
    }
  }

  Widget _buildSettingItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon, 
        color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.blue,
      ),
      title: Text(
        title, 
        style: TextStyle(
          color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
        ),
      ),
      subtitle: Text(
        subtitle, 
        style: TextStyle(
          color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[400] : Colors.grey[600],
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios, 
        color: Theme.of(context).brightness == Brightness.dark ? Colors.grey : Colors.grey[600], 
        size: 16,
      ),
      onTap: onTap,
    );
  }
}
