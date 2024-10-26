part of 'window_route.dart';

class WindowDisplayer extends StatefulWidget {
  const WindowDisplayer({
    super.key,
    required this.route,
    required this.child,
  });

  final WindowRoute route;
  final Widget child;

  @override
  State<WindowDisplayer> createState() => _WindowDisplayerState();
}

class _WindowDisplayerState extends State<WindowDisplayer> {
  @override
  Widget build(BuildContext context) {
    final mode = widget.route.mode;
    final rect = widget.route.rect;

    Widget current = widget.child;

    if (mode == WindowMode.normal) {
      current = ResizeListener(
        onResizeUpdate: _onResizeUpdate,
        child: current,
      );
    }

    current = switch (mode) {
      WindowMode.normal => Padding(
          padding: EdgeInsets.only(
            top: rect.top,
            left: rect.left,
          ),
          child: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: rect.width,
              height: rect.height,
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
    widget.route.rect = widget.route.rect.gestureResizeTo(
      direction,
      delta: details.delta,
    );
  }
}

extension on Rect {
  // Move in a certain direction with a certain delta
  Rect gestureResizeTo(ResizeDirection direction, {required Offset delta}) {
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
