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
        child: const ColoredBox(color: Colors.yellow, child: Center()),
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
      case ResizeDirection.up:
        return Rect.fromLTRB(left, top + delta.dy, right, bottom);
      case ResizeDirection.down:
        return Rect.fromLTRB(left, top, right, bottom + delta.dy);
      case ResizeDirection.left:
        return Rect.fromLTRB(left + delta.dx, top, right, bottom);
      case ResizeDirection.right:
        return Rect.fromLTRB(left, top, right + delta.dx, bottom);
      case ResizeDirection.upLeft:
        return Rect.fromLTRB(
          left + delta.dx,
          top + delta.dy,
          right,
          bottom,
        );
      case ResizeDirection.upRight:
        return Rect.fromLTRB(
          left,
          top + delta.dy,
          right + delta.dx,
          bottom,
        );
      case ResizeDirection.downRight:
        return Rect.fromLTRB(
          left,
          top,
          right + delta.dx,
          bottom + delta.dy,
        );
      case ResizeDirection.downLeft:
        return Rect.fromLTRB(
          left + delta.dx,
          top,
          right,
          bottom + delta.dy,
        );
    }
  }
}
