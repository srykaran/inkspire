import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inkspi/screens/drawing_screen.dart';
import 'package:inkspi/providers/settings_provider.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(settingsProvider).isDarkMode;
    
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      body: Stack(
        children: [
          // Custom gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDarkMode ? [
                  Colors.blue.shade900,
                  Colors.black,
                  Colors.purple.shade900,
                ] : [
                  Colors.blue.shade200,
                  Colors.white,
                  Colors.purple.shade200,
                ],
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // App name with animation
                    Text(
                      "INKSPIRE",
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black,
                        letterSpacing: 5,
                        shadows: [
                          BoxShadow(
                            color: (isDarkMode ? Colors.purpleAccent : Colors.purple).withOpacity(0.5),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                    )
                    .animate()
                    .fadeIn(duration: const Duration(milliseconds: 800))
                    .slideY(begin: -0.2, end: 0, curve: Curves.easeOut),
                    
                    const SizedBox(height: 40),
                    
                    // App illustration preview
                    Container(
                      height: 300,
                      width: 300,
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.black : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: (isDarkMode ? Colors.purpleAccent : Colors.purple).withOpacity(0.3),
                            blurRadius: 25,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Image.asset(
                          'assets/images/thelogo.png',
                          width: 250,
                          height: 250,
                          fit: BoxFit.contain,
                        ),
                      ),
                    )
                    .animate()
                    .fadeIn(delay: const Duration(milliseconds: 300), duration: const Duration(milliseconds: 800))
                    .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),
                    
                    const SizedBox(height: 50),
                    
                    // Get started button with animation
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const DrawingScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: isDarkMode ? Colors.white : Colors.white,
                        backgroundColor: isDarkMode ? Colors.purpleAccent : Colors.purple,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 8,
                        shadowColor: (isDarkMode ? Colors.purpleAccent : Colors.purple).withOpacity(0.5),
                      ),
                      child: const Text(
                        "Start Drawing",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    )
                    .animate()
                    .fadeIn(delay: const Duration(milliseconds: 600), duration: const Duration(milliseconds: 800))
                    .slideY(delay: const Duration(milliseconds: 600), begin: 0.2, end: 0),
                    
                    const SizedBox(height: 30),
                    
                    // Tagline
                    Text(
                      "Unleash your creativity",
                      style: TextStyle(
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                      ),
                    )
                    .animate()
                    .fadeIn(delay: const Duration(milliseconds: 800), duration: const Duration(milliseconds: 800)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom particle animation widget
class ParticleBackground extends StatefulWidget {
  const ParticleBackground({Key? key}) : super(key: key);

  @override
  State<ParticleBackground> createState() => _ParticleBackgroundState();
}

class _ParticleBackgroundState extends State<ParticleBackground> with TickerProviderStateMixin {
  late final AnimationController _controller;
  final List<Particle> particles = [];
  final Random random = Random();

  @override
  void initState() {
    super.initState();
    // Create animation controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    // Add listeners to rebuild the UI on animation ticks
    _controller.addListener(() {
      if (mounted) {
        setState(() {
          // Update particles on each frame
        });
      }
    });

    // Generate some random particles
    for (int i = 0; i < 50; i++) {
      particles.add(Particle(
        position: Offset(random.nextDouble() * 400, random.nextDouble() * 800),
        speed: Offset(random.nextDouble() * 2 - 1, random.nextDouble() * 2 - 1),
        radius: random.nextDouble() * 4 + 1,
        color: [
          Colors.blue.withOpacity(0.6),
          Colors.purple.withOpacity(0.6),
          Colors.pink.withOpacity(0.6),
          Colors.cyan.withOpacity(0.6),
        ][random.nextInt(4)],
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    
    // Update particle positions based on animation value
    for (var particle in particles) {
      particle.position += particle.speed;
      
      // Bounce off edges
      if (particle.position.dx < 0 || particle.position.dx > size.width) {
        particle.speed = Offset(-particle.speed.dx, particle.speed.dy);
      }
      if (particle.position.dy < 0 || particle.position.dy > size.height) {
        particle.speed = Offset(particle.speed.dx, -particle.speed.dy);
      }
    }
    
    return CustomPaint(
      size: Size.infinite,
      painter: ParticlePainter(particles: particles, value: _controller.value),
    );
  }
}

// Custom painter for the particles
class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double value;

  ParticlePainter({
    required this.particles,
    required this.value,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final paint = Paint()
        ..color = particle.color
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(particle.position, particle.radius, paint);
      
      // Draw connections between nearby particles
      for (var otherParticle in particles) {
        if (particle != otherParticle) {
          final distance = (particle.position - otherParticle.position).distance;
          if (distance < 100) {
            final linePaint = Paint()
              ..color = particle.color.withOpacity(0.2 * (1 - distance / 100))
              ..strokeWidth = 0.5;
            
            canvas.drawLine(particle.position, otherParticle.position, linePaint);
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant ParticlePainter oldDelegate) {
    return oldDelegate.value != value;
  }
}

// Particle class
class Particle {
  Offset position;
  Offset speed;
  double radius;
  Color color;

  Particle({
    required this.position,
    required this.speed,
    required this.radius,
    required this.color,
  });
}