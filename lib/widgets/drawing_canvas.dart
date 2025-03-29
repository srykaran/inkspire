import 'dart:ui' as ui;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inkspi/providers/drawing_controller.dart';
import 'package:inkspi/providers/settings_provider.dart';

class DrawingCanvas extends ConsumerStatefulWidget {
  const DrawingCanvas({Key? key}) : super(key: key);

  @override
  ConsumerState<DrawingCanvas> createState() => _DrawingCanvasState();
}

class _DrawingCanvasState extends ConsumerState<DrawingCanvas> {
  List<Offset> _currentStrokePoints = [];
  Offset? _eraserPosition;
  
  @override
  Widget build(BuildContext context) {
    final layers = ref.watch(drawingControllerProvider);
    final drawingController = ref.read(drawingControllerProvider.notifier);
    final currentColor = drawingController.selectedColor;
    final currentBrushType = drawingController.selectedBrush;
    final currentStrokeSize = drawingController.strokeSize;
    final selectedLayerIndex = drawingController.selectedLayerIndex;
    final isDarkMode = ref.watch(settingsProvider).isDarkMode;

    return Container(
      decoration: BoxDecoration(
        // Fixed gradient background that doesn't change with theme
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFE8F5F9),
            const Color(0xFFF1F2F4),
            const Color(0xFFF8EDF2),
          ],
        ),
      ),
      child: GestureDetector(
        onPanStart: (details) {
          setState(() {
            _currentStrokePoints = [details.localPosition];
            if (currentBrushType == BrushType.eraser) {
              _eraserPosition = details.localPosition;
            }
          });
          
          // If eraser, handle erase immediately
          if (currentBrushType == BrushType.eraser) {
            _handleEraserAction(details.localPosition, currentStrokeSize);
          }
        },
        onPanUpdate: (details) {
          setState(() {
            if (currentBrushType == BrushType.eraser) {
              _eraserPosition = details.localPosition;
            }
            
            if (_currentStrokePoints.isNotEmpty && 
                _currentStrokePoints.last != details.localPosition) {
              _currentStrokePoints.add(details.localPosition);
            }
          });
          
          // If eraser, handle erase during drag
          if (currentBrushType == BrushType.eraser) {
            _handleEraserAction(details.localPosition, currentStrokeSize);
          }
        },
        onPanEnd: (_) {
          if (_currentStrokePoints.isNotEmpty) {
            // Only add stroke if not erasing
            if (currentBrushType != BrushType.eraser) {
              drawingController.addStroke(
                DrawingStroke(
                  points: _currentStrokePoints,
                  color: currentColor,
                  strokeWidth: currentStrokeSize,
                  brushType: currentBrushType,
                ),
              );
            }
            setState(() {
              _currentStrokePoints = [];
              _eraserPosition = null;
            });
          }
        },
        child: CustomPaint(
          painter: _DrawingPainter(
            layers: layers,
            currentStroke: currentBrushType != BrushType.eraser ? _currentStrokePoints : [],
            currentColor: currentColor,
            currentStrokeSize: currentStrokeSize,
            currentBrushType: currentBrushType,
            selectedLayerIndex: selectedLayerIndex,
            eraserPosition: _eraserPosition,
            eraserSize: currentBrushType == BrushType.eraser ? currentStrokeSize : 0,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
  
  // Handle eraser action by checking for intersections with existing strokes
  void _handleEraserAction(Offset position, double eraserSize) {
    final drawingController = ref.read(drawingControllerProvider.notifier);
    drawingController.eraseAt(position, eraserSize);
  }
}

class _DrawingPainter extends CustomPainter {
  final List<DrawingLayer> layers;
  final List<Offset> currentStroke;
  final Color currentColor;
  final double currentStrokeSize;
  final BrushType currentBrushType;
  final int selectedLayerIndex;
  final Offset? eraserPosition;
  final double eraserSize;

  _DrawingPainter({
    required this.layers,
    required this.currentStroke,
    required this.currentColor,
    required this.currentStrokeSize,
    required this.currentBrushType,
    required this.selectedLayerIndex,
    this.eraserPosition,
    this.eraserSize = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw each visible layer
    for (int i = 0; i < layers.length; i++) {
      final layer = layers[i];
      if (layer.isVisible) {
        for (final stroke in layer.strokes) {
          _applyBrushStyle(canvas, stroke);
        }
      }
    }
    
    // Draw the current stroke with the current settings
    if (currentStroke.isNotEmpty && selectedLayerIndex >= 0 && selectedLayerIndex < layers.length) {
      final paint = Paint()
        ..strokeCap = StrokeCap.round
        ..strokeWidth = currentStrokeSize
        ..isAntiAlias = true
        ..color = currentColor;
        
      if (currentBrushType == BrushType.brush) {
        paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);
      } else if (currentBrushType == BrushType.marker) {
        paint.strokeJoin = StrokeJoin.round;
      }
      
      _drawStroke(canvas, paint, currentStroke);
    }
    
    // Draw eraser indicator
    if (eraserPosition != null && eraserSize > 0) {
      // Outer ring
      final eraserOuterPaint = Paint()
        ..color = Colors.black.withOpacity(0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      
      // Draw eraser circle
      canvas.drawCircle(eraserPosition!, eraserSize, eraserOuterPaint);
      
      // Inner solid circle with low opacity to show the area
      final eraserInnerPaint = Paint()
        ..color = Colors.black.withOpacity(0.1)
        ..style = PaintingStyle.fill;
        
      canvas.drawCircle(eraserPosition!, eraserSize - 2, eraserInnerPaint);
      
      // Draw center dot for precision
      final centerDotPaint = Paint()
        ..color = Colors.red
        ..style = PaintingStyle.fill;
        
      canvas.drawCircle(eraserPosition!, 2, centerDotPaint);
    }
  }

  void _applyBrushStyle(Canvas canvas, DrawingStroke stroke) {
    final paint = Paint()
      ..color = stroke.color
      ..strokeWidth = stroke.strokeWidth
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    switch (stroke.brushType) {
      case BrushType.pen:
        // No special effects for pen
        break;
      case BrushType.brush:
        // Soft brush effect with blur
        paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);
        break;
      case BrushType.marker:
        // Marker effect
        paint.strokeJoin = StrokeJoin.round;
        break;
      case BrushType.eraser:
        // Eraser strokes are not drawn
        return;
    }

    _drawStroke(canvas, paint, stroke.points);
  }

  void _drawStroke(Canvas canvas, Paint paint, List<Offset> points) {
    if (points.length < 2) {
      if (points.isNotEmpty) {
        // Draw a single dot if there's only one point
        canvas.drawCircle(points.first, paint.strokeWidth / 2, paint);
      }
      return;
    }

    // For smoother lines, we'll use a path instead of drawing individual lines
    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);
    
    // Use quadratic bezier curves for smooth drawing
    for (int i = 0; i < points.length - 1; i++) {
      if (i + 1 < points.length - 1) {
        // Calculate control point
        final p1 = points[i];
        final p2 = points[i + 1];
        final controlPoint = Offset(
          (p1.dx + p2.dx) / 2,
          (p1.dy + p2.dy) / 2,
        );
        
        path.quadraticBezierTo(
          p1.dx, 
          p1.dy, 
          controlPoint.dx, 
          controlPoint.dy
        );
      } else {
        // For the last segment, just use a line
        path.lineTo(points[i + 1].dx, points[i + 1].dy);
      }
    }
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _DrawingPainter oldDelegate) {
    return oldDelegate.layers != layers ||
        oldDelegate.currentStroke != currentStroke ||
        oldDelegate.currentColor != currentColor ||
        oldDelegate.currentStrokeSize != currentStrokeSize ||
        oldDelegate.currentBrushType != currentBrushType ||
        oldDelegate.selectedLayerIndex != selectedLayerIndex ||
        oldDelegate.eraserPosition != eraserPosition ||
        oldDelegate.eraserSize != eraserSize;
  }
}
