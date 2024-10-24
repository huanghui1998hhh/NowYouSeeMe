import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

typedef ResizeStartEventListener = PointerDownEventListener;
typedef ResizeUpdateEventListener = void Function(
  ResizeDirection direction,
  DragUpdateDetails details,
);

/// A widget that controls the resize gesture.
class ResizeListener extends SingleChildRenderObjectWidget {
  const ResizeListener({
    super.key,
    this.threshold = 5.0,
    this.onEnter,
    this.onExit,
    this.onHover,
    this.onResizeStart,
    this.onResizeUpdate,
    this.gestureSettings,
    super.child,
  }) : assert(threshold > 0);

  /// Determines the sensitivity of the resize gesture detection.
  ///
  /// It is used to define a boundary around the edges of a widget
  /// where resize gestures are recognized.
  final double threshold;
  final PointerEnterEventListener? onEnter;
  final PointerHoverEventListener? onHover;
  final PointerExitEventListener? onExit;
  final ResizeStartEventListener? onResizeStart;
  final ResizeUpdateEventListener? onResizeUpdate;
  final DeviceGestureSettings? gestureSettings;

  @override
  RenderResizeListener createRenderObject(BuildContext context) {
    return RenderResizeListener(
      threshold: threshold,
      onEnter: onEnter,
      onHover: onHover,
      onExit: onExit,
      onResizeStart: onResizeStart,
      onResizeUpdate: onResizeUpdate,
      gestureSettings:
          gestureSettings ?? MediaQuery.maybeGestureSettingsOf(context),
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderResizeListener renderObject,
  ) {
    renderObject
      ..threshold = threshold
      ..onEnter = onEnter
      ..onHover = onHover
      ..onExit = onExit
      ..onResizeStart = onResizeStart
      ..onResizeUpdate = onResizeUpdate
      ..gestureSettings =
          gestureSettings ?? MediaQuery.maybeGestureSettingsOf(context);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    final List<String> listeners = <String>[
      if (onEnter != null) 'enter',
      if (onExit != null) 'exit',
      if (onHover != null) 'hover',
      if (onResizeStart != null) 'resizeStart',
      if (onResizeUpdate != null) 'resizeUpdate',
    ];
    properties.add(
      IterableProperty<String>('listeners', listeners, ifEmpty: '<none>'),
    );
    properties.add(
      DiagnosticsProperty<double>('threshold', threshold, defaultValue: 5.0),
    );
  }
}

class RenderResizeListener extends RenderMouseRegion {
  RenderResizeListener({
    required this.threshold,
    super.onEnter,
    super.onHover,
    super.onExit,
    this.onResizeStart,
    this.onResizeUpdate,
    super.cursor,
    this.gestureSettings,
  }) : super(opaque: true);

  double threshold;

  ResizeStartEventListener? onResizeStart;
  ResizeUpdateEventListener? onResizeUpdate;
  DeviceGestureSettings? gestureSettings;

  GestureRecognizer? _recognizer;
  int? _recognizerPointer;
  Drag? _dragInfo;

  bool get isDragging => _dragInfo != null;

  @override
  void handleEvent(PointerEvent event, HitTestEntry entry) {
    super.handleEvent(event, entry);
    if (onResizeUpdate == null) return;
    if (isDragging) return;
    final resizeDirection = _getResizeDirection(event.localPosition);
    cursor = resizeDirection?.cursor ?? MouseCursor.defer;
    if (resizeDirection != null && event is PointerDownEvent) {
      startDrag(event, resizeDirection);
    }
  }

  void startDrag(PointerDownEvent event, ResizeDirection direction) {
    if (_recognizer != null && _recognizerPointer != event.pointer) {
      _recognizer!.dispose();
      _recognizer = null;
      _recognizerPointer = null;
    }

    onResizeStart?.call(event);
    _recognizer = ImmediateMultiDragGestureRecognizer(debugOwner: this)
      ..gestureSettings = gestureSettings
      ..onStart = ((e) => _onDragStart(event, direction))
      ..addPointer(event);
    _recognizerPointer = event.pointer;
  }

  Drag? _onDragStart(PointerDownEvent event, ResizeDirection direction) {
    assert(_dragInfo == null);

    _dragInfo = _ResizeDragInfo(
      direction: direction,
      onResizeUpdate: onResizeUpdate,
      onResizeCancel: dragDispose,
      onResizeEnd: dragDispose,
    );

    return _dragInfo;
  }

  void dragDispose() {
    _recognizer?.dispose();
    _recognizer = null;
    _dragInfo = null;
  }

  @override
  void dispose() {
    dragDispose();
    super.dispose();
  }

  ResizeDirection? _getResizeDirection(Offset position) {
    final width = size.width;
    final height = size.height;

    if (position.dy <= threshold) {
      if (position.dx <= threshold) {
        return ResizeDirection.upLeft;
      } else if (position.dx >= width - threshold) {
        return ResizeDirection.upRight;
      } else {
        return ResizeDirection.up;
      }
    }

    if (position.dy >= height - threshold) {
      if (position.dx <= threshold) {
        return ResizeDirection.downLeft;
      } else if (position.dx >= width - threshold) {
        return ResizeDirection.downRight;
      } else {
        return ResizeDirection.down;
      }
    }

    if (position.dx <= threshold) {
      return ResizeDirection.left;
    }

    if (position.dx >= width - threshold) {
      return ResizeDirection.right;
    }

    return null;
  }
}

class _ResizeDragInfo extends Drag {
  _ResizeDragInfo({
    required this.direction,
    this.onResizeUpdate,
    this.onResizeCancel,
    this.onResizeEnd,
  });

  final ResizeDirection direction;
  final ResizeUpdateEventListener? onResizeUpdate;
  final VoidCallback? onResizeCancel;
  final VoidCallback? onResizeEnd;

  @override
  void update(DragUpdateDetails details) {
    onResizeUpdate?.call(direction, details);
  }

  @override
  void cancel() {
    onResizeCancel?.call();
  }

  @override
  void end(DragEndDetails details) {
    onResizeEnd?.call();
  }
}

enum ResizeDirection {
  upLeft(SystemMouseCursors.resizeUpLeft),
  up(SystemMouseCursors.resizeUp),
  upRight(SystemMouseCursors.resizeUpRight),
  right(SystemMouseCursors.resizeRight),
  downRight(SystemMouseCursors.resizeDownRight),
  down(SystemMouseCursors.resizeDown),
  downLeft(SystemMouseCursors.resizeDownLeft),
  left(SystemMouseCursors.resizeLeft);

  const ResizeDirection(this.cursor);

  final SystemMouseCursor cursor;
}
