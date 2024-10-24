import 'package:flutter/material.dart';

import 'resize_listener.dart';

class Window extends StatefulWidget {
  const Window({super.key});

  static WindowState of(BuildContext context) {
    final windowState = context.findAncestorStateOfType<WindowState>();

    assert(() {
      if (windowState == null) {
        throw AssertionError(
          'Window operation requested with a context that does not include a Window.',
        );
      }
      return true;
    }());

    return windowState!;
  }

  @override
  State<Window> createState() => WindowState();
}

class WindowState extends State<Window> {
  Rect _rect = const Offset(100, 100) & const Size(300, 300);
  Rect get rect => _rect;
  set rect(Rect rect) {
    if (!mounted) return;
    if (rect == _rect) return;
    setState(() {
      _rect = rect;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fromRect(
      rect: _rect,
      child: ResizeListener(
        onResizeUpdate: _onResizeUpdate,
        child: ColoredBox(
          color: Colors.yellow,
          child: Column(
            children: [
              GestureDetector(
                onPanUpdate: (details) {
                  rect = rect.shift(details.delta);
                },
                child: AppBar(
                  title: const Text('Now You See Me'),
                  backgroundColor: Colors.red,
                ),
              ),
              const Expanded(child: SizedBox.shrink()),
            ],
          ),
        ),
      ),
    );
  }

  void _onResizeUpdate(ResizeDirection direction, DragUpdateDetails details) {
    rect = rect.resizeTo(direction, delta: details.delta);
  }
}

extension on Rect {
  Rect resizeTo(ResizeDirection direction, {required Offset delta}) {
    switch (direction) {
      case ResizeDirection.top:
        return Rect.fromLTRB(left, top + delta.dy, right, bottom);
      case ResizeDirection.bottom:
        return Rect.fromLTRB(left, top, right, bottom + delta.dy);
      case ResizeDirection.left:
        return Rect.fromLTRB(left + delta.dx, top, right, bottom);
      case ResizeDirection.right:
        return Rect.fromLTRB(left, top, right + delta.dx, bottom);
      case ResizeDirection.topLeft:
        return Rect.fromLTRB(
          left + delta.dx,
          top + delta.dy,
          right,
          bottom,
        );
      case ResizeDirection.topRight:
        return Rect.fromLTRB(
          left,
          top + delta.dy,
          right + delta.dx,
          bottom,
        );
      case ResizeDirection.bottomRight:
        return Rect.fromLTRB(
          left,
          top,
          right + delta.dx,
          bottom + delta.dy,
        );
      case ResizeDirection.bottomLeft:
        return Rect.fromLTRB(
          left + delta.dx,
          top,
          right,
          bottom + delta.dy,
        );
    }
  }
}
