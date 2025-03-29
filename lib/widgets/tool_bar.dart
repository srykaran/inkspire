import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/drawing_controller.dart';

class ToolBar extends ConsumerWidget {
  const ToolBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: EdgeInsets.all(8),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: Icon(Icons.layers_clear, color: Colors.white),
            onPressed: () =>
                ref.read(drawingControllerProvider.notifier).clearCanvas(),
          ),
          IconButton(
            icon: Icon(Icons.save, color: Colors.white),
            onPressed: () {
              // Save function (to be implemented)
            },
          ),
        ],
      ),
    );
  }
}
