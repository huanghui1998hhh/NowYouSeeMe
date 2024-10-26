import 'package:flutter/material.dart';

import '../window_route/window_route.dart';

class WindowDraggableArea extends StatelessWidget {
  const WindowDraggableArea({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final window = WindowRoute.of(context);

    return GestureDetector(
      onDoubleTap: window.toggleWindowMode,
      onPanStart: (details) {
        window.toNormalMode(startPosition: details.globalPosition);
      },
      onPanUpdate: (details) {
        assert(window.mode == WindowMode.normal);
        window.shift(details.delta);
      },
      behavior: HitTestBehavior.opaque,
      child: child,
    );
  }
}
