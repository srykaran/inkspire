import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inkspi/widgets/top_navigation_bar.dart';
import 'package:inkspi/widgets/bottom_navigation_bar.dart';
import 'package:inkspi/widgets/drawing_canvas.dart';
import 'package:inkspi/providers/settings_provider.dart';

class DrawingScreen extends ConsumerWidget {
  const DrawingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(settingsProvider).isDarkMode;
    
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            RepaintBoundary(
              child: const TopNavigationBar(),
            ),
            Expanded(
              child: RepaintBoundary(
                child: Container(
                  margin: const EdgeInsets.all(0),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[900] : Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: isDarkMode 
                            ? Colors.black.withOpacity(0.3) 
                            : Colors.grey.withOpacity(0.2),
                        blurRadius: 3,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: ClipRect(
                    child: const DrawingCanvas(),
                  ),
                ),
              ),
            ),
            RepaintBoundary(
              child: const BottomNavigationBarWidget(),
            ),
          ],
        ),
      ),
    );
  }
}
