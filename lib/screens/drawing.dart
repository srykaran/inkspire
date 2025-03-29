import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inkspi/providers/settings_provider.dart';
import 'package:inkspi/providers/drawing_controller.dart';

class DrawingSavedScreen extends ConsumerWidget {
  const DrawingSavedScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(settingsProvider).isDarkMode;
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 380;
    
    return Scaffold(
      // Stack allows the full-screen confetti animation to serve as a background
      body: Stack(
        children: [
          // Gradient background for modern appeal
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDarkMode 
                    ? [Colors.black, const Color(0xFF1A237E), Colors.deepPurple.shade900]
                    : [Colors.deepPurple.shade300, Colors.blueAccent, Colors.purple.shade300],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          
          // Centered content overlay with card for better visibility
          Center(
            child: SimpleFadeInCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Success icon
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 5, // Reduced blur
                          spreadRadius: 1, // Reduced spread
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: isSmallScreen ? 60 : 80,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Success message
                  Text(
                    "Drawing Saved Successfully!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 20 : 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Subtitle message
                  Text(
                    "Your masterpiece has been saved to the gallery",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 14 : 16,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Buttons - simplified to reduce animations
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      // Back to drawing button
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.deepPurple,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 3, // Reduced elevation
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.brush, size: 18),
                        label: const Text(
                          "Continue",
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                      // Home button
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.deepPurple,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          side: const BorderSide(color: Colors.deepPurple, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: () {
                          // Clear the drawing controller
                          ref.read(drawingControllerProvider.notifier).clearCanvas();
                          // Navigate to home
                          Navigator.pushReplacementNamed(context, '/');
                        },
                        icon: const Icon(Icons.home, size: 18),
                        label: const Text(
                          "Home",
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // Confetti animation moved on top to be visible but ignoring pointer events
          IgnorePointer(
            child: Stack(
              children: [
                // Main confetti from top
                Positioned(
                  top: -100,
                  left: 0,
                  right: 0,
                  height: screenSize.height * 0.7,
                  child: Lottie.asset(
                    'assets/lottie/confetti.json',
                    fit: BoxFit.cover,
                    animate: true,
                    frameRate: FrameRate.max,
                    repeat: true,
                  ),
                ),
                // Left side confetti
                Positioned(
                  left: -50,
                  top: screenSize.height * 0.3,
                  height: screenSize.height * 0.7,
                  width: screenSize.width * 0.6,
                  child: Transform.scale(
                    scale: 1.3,
                    child: Lottie.asset(
                      'assets/lottie/confetti.json',
                      fit: BoxFit.cover,
                      animate: true,
                      frameRate: FrameRate.max,
                      repeat: true,
                    ),
                  ),
                ),
                // Right side confetti
                Positioned(
                  right: -50,
                  top: screenSize.height * 0.2,
                  height: screenSize.height * 0.7,
                  width: screenSize.width * 0.6,
                  child: Transform.scale(
                    scale: 1.3,
                    child: Lottie.asset(
                      'assets/lottie/confetti.json',
                      fit: BoxFit.cover,
                      animate: true,
                      frameRate: FrameRate.max,
                      repeat: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Simplified card that fades in with fewer animations
class SimpleFadeInCard extends StatelessWidget {
  final Widget child;
  const SimpleFadeInCard({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 380;
    
    return Card(
      margin: EdgeInsets.all(isSmallScreen ? 16 : 32),
      elevation: 5, // Reduced elevation
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
        child: child,
      ),
    );
  }
}
