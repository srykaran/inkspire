import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inkspi/screens/welcome_screen.dart';
import 'package:inkspi/screens/drawing.dart';
import 'package:inkspi/providers/settings_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const ProviderScope(child: DrawingApp()));
}

class DrawingApp extends ConsumerWidget {
  const DrawingApp({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Inkspire',
      theme: theme,
      home: const WelcomeScreen(),
      routes: {
        '/DrawingSavedScreen': (context) => const DrawingSavedScreen(),
      },
    );
  }
}
