import 'package:flutter/material.dart';

import 'resize_listener.dart';
import 'standard_window_container.dart';

typedef WindowBuilder = Widget Function(BuildContext context, Widget child);

class Window extends StatefulWidget {
  const Window({super.key, this.builder, required this.child});

  const Window.standard({super.key, required this.child})
      : builder = standardBuilder;

  final WindowBuilder? builder;
  final Widget child;

  static Widget standardBuilder(BuildContext context, Widget child) =>
      StandardWindowContainer(child: child);

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
  WindowMode _mode = WindowMode.normal;
  WindowMode get mode => _mode;
  set mode(WindowMode mode) {
    if (mode == _mode) return;
    if (!mounted) return;
    setState(() {
      _mode = mode;
    });
  }

  Rect _rect = const Offset(100, 100) & const Size(300, 300);
  Rect get rect => _rect;
  set rect(Rect rect) {
    if (rect == _rect) return;
    if (!mounted) return;
    setState(() {
      _rect = rect;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget current = widget.child;

    if (widget.builder != null) {
      current = widget.builder!(context, current);
    }

    if (mode == WindowMode.normal) {
      current = ResizeListener(
        onResizeUpdate: _onResizeUpdate,
        child: current,
      );
    }

    current = switch (mode) {
      WindowMode.normal => Padding(
          padding: EdgeInsets.only(
            top: _rect.top,
            left: _rect.left,
          ),
          child: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: _rect.width,
              height: _rect.height,
              child: current,
            ),
          ),
        ),
      WindowMode.maximized => ConstrainedBox(
          constraints: const BoxConstraints.expand(),
          child: current,
        ),
    };

    return current;
  }

  void _onResizeUpdate(ResizeDirection direction, DragUpdateDetails details) {
    rect = rect.resizeTo(direction, delta: details.delta);
  }

  void shift(Offset delta) {
    rect = rect.shift(delta);
  }

  void toNormalMode({required Offset startPosition}) {
    assert(startPosition.dx >= 0 && startPosition.dy >= 0);
    if (mode == WindowMode.normal) return;
    final render = context.findRenderObject()! as RenderBox;
    final localStartPosition = render.globalToLocal(startPosition);
    final xRatio = localStartPosition.dx / render.size.width;
    final yRatio = localStartPosition.dy / render.size.height;
    mode = WindowMode.normal;
    rect = (localStartPosition -
            Offset(
              rect.size.width * xRatio,
              rect.size.height * yRatio,
            )) &
        rect.size;
  }
}

class WindowDraggableArea extends StatelessWidget {
  const WindowDraggableArea({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final windowState = Window.of(context);

    return GestureDetector(
      onDoubleTap: () {
        windowState.mode = windowState.mode.toggle;
      },
      onPanStart: (details) {
        if (windowState.mode == WindowMode.maximized) {
          windowState.toNormalMode(startPosition: details.globalPosition);
        }
      },
      onPanUpdate: (details) {
        assert(windowState.mode == WindowMode.normal);
        windowState.shift(details.delta);
      },
      behavior: HitTestBehavior.opaque,
      child: child,
    );
  }
}

enum WindowMode {
  normal,
  maximized;

  WindowMode get toggle => switch (this) {
        WindowMode.normal => WindowMode.maximized,
        WindowMode.maximized => WindowMode.normal,
      };
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
