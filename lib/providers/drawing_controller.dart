import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as Math;

/// Enum for different brush types.
enum BrushType { pen, brush, marker, eraser }

/// Model for a single drawing stroke.
class DrawingStroke {
  final List<Offset> points;
  final Color color;
  final double strokeWidth;
  final BrushType brushType;
  final double opacity;

  DrawingStroke({
    required this.points,
    required this.color,
    required this.strokeWidth,
    required this.brushType,
    this.opacity = 1.0, // Default is fully opaque
  });
}

/// Model for a drawing layer
class DrawingLayer {
  List<DrawingStroke> strokes;
  bool isVisible;

  DrawingLayer({
    List<DrawingStroke>? strokes,
    this.isVisible = true,
  }) : strokes = strokes ?? [];
}

/// A StateNotifier that manages the drawing state.
class DrawingController extends StateNotifier<List<DrawingLayer>> {
  DrawingController() : super([DrawingLayer()]); // Start with one layer

  Color _selectedColor = Colors.black;
  double _strokeSize = 5.0;
  BrushType _selectedBrush = BrushType.pen;
  int _selectedLayerIndex = 0;

  // Getters for the drawing settings
  Color get selectedColor => _selectedColor;
  double get strokeSize => _strokeSize;
  BrushType get selectedBrush => _selectedBrush;
  int get selectedLayerIndex => _selectedLayerIndex;

  // Redo stack for each layer
  Map<int, List<DrawingStroke>> _redoStackByLayer = {};

  /// Sets a new selected color.
  void setSelectedColor(Color color) {
    // Don't change color for eraser
    if (_selectedBrush == BrushType.eraser) {
      _selectedBrush = BrushType.pen;
    }
    _selectedColor = color;
    state = [...state]; // Notify listeners
  }

  /// Sets the stroke size.
  void setStrokeSize(double size) {
    _strokeSize = size;
  }

  /// Changes the brush type.
  void setBrushType(BrushType type) {
    _selectedBrush = type;
    // For eraser, we don't change the color
    state = [...state]; // Notify listeners
  }

  /// Activates the eraser mode.
  void setEraser() {
    _selectedBrush = BrushType.eraser;
    // Ensure a reasonable eraser size
    if (_strokeSize < 10.0) {
      _strokeSize = 10.0;
    }
    state = [...state]; // Notify listeners
  }

  /// Get all layers
  List<DrawingLayer> getLayers() {
    return state;
  }

  /// Select a layer
  void selectLayer(int index) {
    if (index >= 0 && index < state.length) {
      _selectedLayerIndex = index;
      state = [...state]; // Notify listeners
    }
  }

  /// Toggle layer visibility
  void toggleLayerVisibility(int index) {
    if (index >= 0 && index < state.length) {
      final layers = [...state];
      layers[index] = DrawingLayer(
        strokes: layers[index].strokes,
        isVisible: !layers[index].isVisible,
      );
      state = layers;
    }
  }

  /// Add a new layer
  void addLayer() {
    // Create new layer and add it to state
    final newLayer = DrawingLayer();
    state = [...state, newLayer];
    
    // Select the new layer immediately
    _selectedLayerIndex = state.length - 1;
    
    // Clear redo stack for the new layer
    _redoStackByLayer[_selectedLayerIndex] = [];
  }

  /// Remove a layer
  void removeLayer(int index) {
    if (state.length <= 1) {
      // Don't remove the last layer, just clear it
      clearCanvas();
      return;
    }
    
    if (index >= 0 && index < state.length) {
      final layers = [...state];
      // Remove the layer
      layers.removeAt(index);
      
      // Update selected layer index if needed
      if (_selectedLayerIndex >= layers.length) {
        _selectedLayerIndex = layers.length - 1;
      } else if (_selectedLayerIndex >= index) {
        // If we removed the selected layer or a layer before it, update the index
        _selectedLayerIndex = Math.max(0, _selectedLayerIndex - 1);
      }
      
      // Update layers state
      state = layers;
      
      // Remove the redo stack for the deleted layer
      if (_redoStackByLayer.containsKey(index)) {
        _redoStackByLayer.remove(index);
      }
      
      // Shift all redo stacks for layers after the deleted one
      final newRedoStacks = <int, List<DrawingStroke>>{};
      _redoStackByLayer.forEach((layerIndex, redoStack) {
        if (layerIndex > index) {
          newRedoStacks[layerIndex - 1] = redoStack;
        } else if (layerIndex < index) {
          newRedoStacks[layerIndex] = redoStack;
        }
      });
      _redoStackByLayer = newRedoStacks;
    }
  }

  /// Adds a new stroke with appropriate opacity.
  void addStroke(DrawingStroke stroke) {
    if (_selectedLayerIndex < 0 || _selectedLayerIndex >= state.length) {
      return;
    }

    // Clear redo stack for this layer when a new stroke is added
    _redoStackByLayer[_selectedLayerIndex] = [];

    double opacity;
    switch (_selectedBrush) {
      case BrushType.pen:
        opacity = 1.0; // Solid line
        break;
      case BrushType.brush:
        opacity = 0.5; // Softer effect
        break;
      case BrushType.marker:
        opacity = 0.7; // Layering effect
        break;
      case BrushType.eraser:
        opacity = 1.0; // Full opacity for eraser
        break;
    }

    final newStroke = DrawingStroke(
      points: stroke.points,
      color: _selectedBrush == BrushType.eraser ? Colors.transparent : stroke.color.withOpacity(opacity),
      strokeWidth: stroke.strokeWidth,
      brushType: stroke.brushType,
      opacity: opacity,
    );

    final layers = [...state];
    layers[_selectedLayerIndex] = DrawingLayer(
      strokes: [...layers[_selectedLayerIndex].strokes, newStroke],
      isVisible: layers[_selectedLayerIndex].isVisible,
    );
    state = layers;
  }

  /// Undo functionality.
  void undo() {
    if (_selectedLayerIndex < 0 || _selectedLayerIndex >= state.length) {
      return;
    }

    final currentLayer = state[_selectedLayerIndex];
    if (currentLayer.strokes.isNotEmpty) {
      // Initialize redo stack for this layer if not exists
      if (!_redoStackByLayer.containsKey(_selectedLayerIndex)) {
        _redoStackByLayer[_selectedLayerIndex] = [];
      }

      // Save the last stroke to redo stack
      _redoStackByLayer[_selectedLayerIndex]!.add(currentLayer.strokes.last);

      // Create a new layer with the stroke removed
      final layers = [...state];
      layers[_selectedLayerIndex] = DrawingLayer(
        strokes: currentLayer.strokes.sublist(0, currentLayer.strokes.length - 1),
        isVisible: currentLayer.isVisible,
      );
      state = layers;
    }
  }

  /// Redo functionality.
  void redo() {
    if (_selectedLayerIndex < 0 || _selectedLayerIndex >= state.length) {
      return;
    }

    // Check if there are strokes to redo
    if (_redoStackByLayer.containsKey(_selectedLayerIndex) && 
        _redoStackByLayer[_selectedLayerIndex]!.isNotEmpty) {
      final strokeToRedo = _redoStackByLayer[_selectedLayerIndex]!.removeLast();
      
      // Add the stroke back to the layer
      final layers = [...state];
      layers[_selectedLayerIndex] = DrawingLayer(
        strokes: [...layers[_selectedLayerIndex].strokes, strokeToRedo],
        isVisible: layers[_selectedLayerIndex].isVisible,
      );
      state = layers;
    }
  }

  /// Clears the canvas.
  void clearCanvas() {
    if (_selectedLayerIndex < 0 || _selectedLayerIndex >= state.length) {
      return;
    }

    // Clear only the selected layer
    final layers = [...state];
    layers[_selectedLayerIndex] = DrawingLayer(
      strokes: [],
      isVisible: layers[_selectedLayerIndex].isVisible,
    );
    state = layers;

    // Clear the redo stack for this layer
    _redoStackByLayer[_selectedLayerIndex] = [];
  }

  /// Erases strokes at a specific position.
  void eraseAt(Offset position, double eraserSize) {
    if (_selectedLayerIndex < 0 || _selectedLayerIndex >= state.length) {
      return;
    }

    final currentLayer = state[_selectedLayerIndex];
    bool erasedSomething = false;
    
    // New list for updated strokes
    final updatedStrokes = <DrawingStroke>[];
    
    // Define the eraser area as a circle
    final eraserRect = Rect.fromCircle(center: position, radius: eraserSize);
    
    for (final stroke in currentLayer.strokes) {
      // Check if we need to split the stroke or remove it entirely
      List<List<Offset>> strokeSegments = [];
      List<Offset> currentSegment = [];
      bool segmentHit = false;

      // Process all points in this stroke
      for (int i = 0; i < stroke.points.length; i++) {
        final point = stroke.points[i];
        
        // If point is within eraser radius
        if ((point - position).distance <= eraserSize) {
          // End current segment if it's not empty
          if (currentSegment.isNotEmpty) {
            strokeSegments.add(List.from(currentSegment));
            currentSegment = [];
          }
          segmentHit = true;
          erasedSomething = true;
        } else {
          // If this point is safe, add it to current segment
          currentSegment.add(point);
          
          // If we're at last point or the next point would be erased
          if (i == stroke.points.length - 1 || 
              (i < stroke.points.length - 1 && 
               (stroke.points[i + 1] - position).distance <= eraserSize)) {
            if (currentSegment.length > 1) {
              strokeSegments.add(List.from(currentSegment));
            }
            currentSegment = [];
          }
        }
      }
      
      // Add the last segment if not empty
      if (currentSegment.length > 1) {
        strokeSegments.add(currentSegment);
      }
      
      // Only update if we hit this stroke
      if (segmentHit) {
        // Add each valid segment as a new stroke
        for (final segment in strokeSegments) {
          if (segment.length > 1) {
            updatedStrokes.add(DrawingStroke(
              points: segment,
              color: stroke.color,
              strokeWidth: stroke.strokeWidth,
              brushType: stroke.brushType,
              opacity: stroke.opacity,
            ));
          }
        }
      } else {
        // Keep the original stroke if we didn't hit it
        updatedStrokes.add(stroke);
      }
    }
    
    // Only update state if something was actually erased
    if (erasedSomething) {
      final layers = [...state];
      layers[_selectedLayerIndex] = DrawingLayer(
        strokes: updatedStrokes,
        isVisible: currentLayer.isVisible,
      );
      state = layers;
    }
  }

  /// Navigates to the success screen.
  Future<void> saveDrawing(BuildContext context) async {
    Navigator.pushNamed(context, '/DrawingSavedScreen');
  }
}

/// Provider for DrawingController.
final drawingControllerProvider = StateNotifierProvider<DrawingController, List<DrawingLayer>>(
      (ref) => DrawingController(),
);
