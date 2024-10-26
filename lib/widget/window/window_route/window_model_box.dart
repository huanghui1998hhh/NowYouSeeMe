import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'window_route.dart';

class WindowModalBox extends SingleChildRenderObjectWidget {
  const WindowModalBox({
    super.key,
    required this.mode,
    required this.windowRect,
    required this.child,
  });

  final WindowMode mode;
  final Rect windowRect;
  @override
  final Widget child;

  @override
  RenderWindowModalBox createRenderObject(BuildContext context) =>
      RenderWindowModalBox(
        mode: mode,
        windowRect: windowRect,
      );

  @override
  void updateRenderObject(
    BuildContext context,
    RenderWindowModalBox renderObject,
  ) =>
      renderObject
        ..mode = mode
        ..rect = windowRect;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      DiagnosticsProperty<Rect>('windowRect', windowRect, showName: false),
    );
    properties.add(EnumProperty<WindowMode>('mode', mode));
  }
}

class RenderWindowModalBox extends RenderProxyBox {
  RenderWindowModalBox({
    RenderBox? child,
    required WindowMode mode,
    required Rect windowRect,
  })  : _mode = mode,
        _rect = windowRect,
        super(child);

  WindowMode get mode => _mode;
  WindowMode _mode;
  set mode(WindowMode value) {
    if (_mode == value) return;
    _mode = value;
    markNeedsLayout();
  }

  Rect get rect => _rect;
  Rect _rect;
  set rect(Rect value) {
    if (_rect == value) return;
    _rect = value;
    markNeedsLayout();
  }

  @override
  void performLayout() {
    assert(child != null);

    switch (mode) {
      case WindowMode.normal:
        child!.layout(
          BoxConstraints.tight(rect.size),
        );
      case WindowMode.maximized:
        child!.layout(constraints.loosen());
    }
    size = constraints.biggest;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    assert(child != null);

    switch (mode) {
      case WindowMode.normal:
        context.paintChild(child!, offset + rect.topLeft);
      case WindowMode.maximized:
        context.paintChild(child!, offset);
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    switch (mode) {
      case WindowMode.normal:
        return super.hitTestChildren(result, position: position - rect.topLeft);
      case WindowMode.maximized:
        return super.hitTestChildren(result, position: position);
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      DiagnosticsProperty<Rect>('rect', rect, showName: false),
    );
    properties.add(EnumProperty<WindowMode>('mode', mode));
  }
}
