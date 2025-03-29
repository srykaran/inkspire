import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inkspi/providers/drawing_controller.dart';
import 'package:inkspi/screens/drawing.dart';
import 'package:inkspi/providers/settings_provider.dart';

class BottomNavigationBarWidget extends ConsumerWidget {
  const BottomNavigationBarWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final drawingController = ref.read(drawingControllerProvider.notifier);
    final isDarkMode = ref.watch(settingsProvider).isDarkMode;

    return Container(
      height: 60,
      color: isDarkMode ? Colors.black87 : Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildToolButton(
              context: context,
              icon: Icons.cleaning_services_outlined,
              label: "Eraser",
              onTap: () => drawingController.setEraser(),
              isDarkMode: isDarkMode,
            ),
            _buildToolButton(
              context: context,
              icon: Icons.brush,
              label: "Brush",
              onTap: () => _showBrushTypePicker(context, drawingController),
              isDarkMode: isDarkMode,
            ),
            _buildToolButton(
              context: context,
              icon: Icons.layers,
              label: "Layer",
              onTap: () => _showLayerOptions(context, drawingController),
              isDarkMode: isDarkMode,
            ),
            _buildToolButton(
              context: context,
              icon: Icons.color_lens,
              label: "Colors",
              onTap: () => _showColorPicker(context, drawingController),
              isDarkMode: isDarkMode,
            ),
            _buildToolButton(
              context: context,
              icon: Icons.image,
              label: "Save",
              onTap: () => _handleSave(context, drawingController),
              isDarkMode: isDarkMode,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isDarkMode,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isDarkMode ? Colors.white : Colors.black87,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black87,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSave(BuildContext context, DrawingController controller) async {
    await controller.saveDrawing(context);
  }

  void _showBrushTypePicker(BuildContext context, DrawingController controller) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: isDarkMode ? Colors.black87 : Colors.white,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.3,
        ),
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Select Brush Type",
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black87,
                  fontSize: 16
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildBrushOption("Pen", Icons.create, BrushType.pen, controller, context),
                  _buildBrushOption("Brush", Icons.brush, BrushType.brush, controller, context),
                  _buildBrushOption("Marker", Icons.edit, BrushType.marker, controller, context),
                ],
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _BrushSizeSlider(controller: controller),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showColorPicker(BuildContext context, DrawingController controller) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    final colors = [
      Colors.black,
      Colors.white,
      Colors.red,
      Colors.pink,
      Colors.purple,
      Colors.deepPurple,
      Colors.indigo,
      Colors.blue,
      Colors.lightBlue,
      Colors.cyan,
      Colors.teal,
      Colors.green,
      Colors.lightGreen,
      Colors.lime,
      Colors.yellow,
      Colors.amber,
      Colors.orange,
      Colors.deepOrange,
      Colors.brown,
      Colors.grey,
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: isDarkMode ? Colors.black87 : Colors.white,
      isScrollControlled: true,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.4,
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Select Color",
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Flexible(
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 15,
                  runSpacing: 15,
                  children: colors.map((color) {
                    return GestureDetector(
                      onTap: () {
                        controller.setSelectedColor(color);
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDarkMode ? Colors.white : Colors.black38,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 5,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrushOption(String label, IconData icon, BrushType type,
      DrawingController controller, BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return InkWell(
      onTap: () {
        controller.setBrushType(type);
        Navigator.pop(context);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon, 
              color: isDarkMode ? Colors.white : Colors.black87
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black87, 
              fontSize: 12
            ),
          ),
        ],
      ),
    );
  }

  void _showLayerOptions(BuildContext context, DrawingController controller) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: isDarkMode ? Colors.black87 : Colors.white,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          // Get fresh layers data each time the UI rebuilds
          final layers = controller.getLayers();
          
          return Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7,
            ),
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Layers",
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black87,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton.icon(
                      icon: Icon(
                        Icons.add, 
                        color: isDarkMode ? Colors.white : Colors.black87
                      ),
                      label: Text(
                        "Add New Layer",
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black87
                        ),
                      ),
                      onPressed: () {
                        controller.addLayer();
                        // Update UI
                        setState(() {});
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: layers.length,
                    itemBuilder: (context, index) {
                      final layer = layers[index];
                      final isSelected = controller.selectedLayerIndex == index;
                      
                      return Card(
                        color: isSelected 
                            ? (isDarkMode ? Colors.blueGrey[800] : Colors.blue[50])
                            : (isDarkMode ? Colors.grey[900] : Colors.grey[100]),
                        elevation: isSelected ? 3 : 1,
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(
                            "Layer ${index + 1}",
                            style: TextStyle(
                              color: isDarkMode ? Colors.white : Colors.black87,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          leading: Checkbox(
                            value: layer.isVisible,
                            activeColor: isDarkMode ? Colors.blue : Colors.blue[700],
                            checkColor: isDarkMode ? Colors.black : Colors.white,
                            onChanged: (value) {
                              controller.toggleLayerVisibility(index);
                              // Update UI
                              setState(() {});
                            },
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.delete,
                                  color: isDarkMode ? Colors.red[300] : Colors.red,
                                ),
                                onPressed: layers.length > 1 ? () {
                                  controller.removeLayer(index);
                                  // Update UI
                                  setState(() {});
                                } : null,
                              ),
                            ],
                          ),
                          onTap: () {
                            controller.selectLayer(index);
                            // Update UI
                            setState(() {});
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _BrushSizeSlider extends StatefulWidget {
  final DrawingController controller;

  const _BrushSizeSlider({Key? key, required this.controller}) : super(key: key);

  @override
  _BrushSizeSliderState createState() => _BrushSizeSliderState();
}

class _BrushSizeSliderState extends State<_BrushSizeSlider> {
  double _currentSize = 5.0;

  @override
  void initState() {
    super.initState();
    _currentSize = widget.controller.strokeSize;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "Brush Size: ${_currentSize.toStringAsFixed(1)}",
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black87, 
            fontSize: 14
          ),
        ),
        Slider(
          value: _currentSize,
          min: 1.0,
          max: 20.0,
          divisions: 19,
          activeColor: isDarkMode ? Colors.white : Colors.blue,
          inactiveColor: isDarkMode ? Colors.grey[700] : Colors.grey[300],
          onChanged: (double value) {
            setState(() {
              _currentSize = value;
              widget.controller.setStrokeSize(value);
            });
          },
        ),
      ],
    );
  }
}
