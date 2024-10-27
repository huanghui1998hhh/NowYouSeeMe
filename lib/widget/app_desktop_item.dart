import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class AppDesktopItem extends StatefulWidget {
  const AppDesktopItem({super.key, required this.appInfo});

  final AppInfo appInfo;

  @override
  State<AppDesktopItem> createState() => _AppDesktopItemState();
}

class _AppDesktopItemState extends State<AppDesktopItem> {
  final WidgetStatesController _controller = WidgetStatesController();

  @override
  Widget build(BuildContext context) {
    return TapRegion(
      onTapOutside: (_) {
        _controller.update(WidgetState.selected, false);
      },
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: 74,
          maxWidth: 74,
          maxHeight: 90,
        ),
        child: Align(
          alignment: Alignment.topCenter,
          child: AppDesktopItemInk(
            statesController: _controller,
            onTapDown: (_) {
              _controller.update(WidgetState.selected, true);
            },
            onDoubleTap: runApp,
            onSecondaryTapDown: (e) {
              _controller.update(WidgetState.selected, true);
              showMenu(
                context: context,
                position: RelativeRect.fromLTRB(
                  e.globalPosition.dx,
                  e.globalPosition.dy,
                  e.globalPosition.dx,
                  e.globalPosition.dy,
                ),
                popUpAnimationStyle: AnimationStyle(
                  duration: const Duration(milliseconds: 166),
                  reverseDuration: const Duration(milliseconds: 166),
                ),
                items: [
                  PopupMenuItem(
                    height: 32,
                    onTap: runApp,
                    child: const Text('Open'),
                  ),
                ],
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    child: Container(
                      width: 49,
                      height: 49,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: widget.appInfo.primaryColor ?? Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: widget.appInfo.icon ?? const FlutterLogo(size: 36),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Flexible(
                    child: Text(
                      widget.appInfo.name,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        height: 1.3,
                        shadows: [
                          Shadow(blurRadius: 1),
                          Shadow(blurRadius: 1.5),
                        ],
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void runApp() {
    Navigator.of(context).push(widget.appInfo.route());
    _controller.update(WidgetState.selected, false);
  }
}

class AppInfo {
  const AppInfo({
    required this.name,
    this.icon,
    this.primaryColor,
    required this.route,
  });

  final String name;
  final Widget? icon;
  final Color? primaryColor;
  final Route<dynamic> Function() route;
}

class AppDesktopItemInk extends StatefulWidget {
  const AppDesktopItemInk({
    super.key,
    required this.child,
    this.isSelected = false,
    this.statesController,
    this.onTap,
    this.onTapDown,
    this.onTapUp,
    this.onTapCancel,
    this.onDoubleTap,
    this.onLongPress,
    this.onSecondaryTap,
    this.onSecondaryTapUp,
    this.onSecondaryTapDown,
    this.onSecondaryTapCancel,
  });

  final Widget child;
  final bool isSelected;
  final WidgetStatesController? statesController;
  final GestureTapCallback? onTap;
  final GestureTapDownCallback? onTapDown;
  final GestureTapUpCallback? onTapUp;
  final GestureTapCallback? onTapCancel;
  final GestureTapCallback? onDoubleTap;
  final GestureLongPressCallback? onLongPress;
  final GestureTapCallback? onSecondaryTap;
  final GestureTapUpCallback? onSecondaryTapUp;
  final GestureTapDownCallback? onSecondaryTapDown;
  final GestureTapCallback? onSecondaryTapCancel;

  @override
  State<AppDesktopItemInk> createState() => _AppDesktopItemInkState();
}

class _AppDesktopItemInkState extends State<AppDesktopItemInk>
    with AutomaticKeepAliveClientMixin<AppDesktopItemInk> {
  WidgetStatesController? internalStatesController;

  void handleStatesControllerChange() {
    setState(() {});
  }

  WidgetStatesController get statesController =>
      widget.statesController ?? internalStatesController!;

  void initStatesController() {
    if (widget.statesController == null) {
      internalStatesController = WidgetStatesController();
    }
    statesController.update(WidgetState.disabled, !enabled);
    statesController.update(WidgetState.selected, widget.isSelected);
    statesController.addListener(handleStatesControllerChange);
  }

  @override
  void initState() {
    super.initState();
    initStatesController();
  }

  @override
  void didUpdateWidget(AppDesktopItemInk oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.statesController != oldWidget.statesController) {
      oldWidget.statesController?.removeListener(handleStatesControllerChange);
      if (widget.statesController != null) {
        internalStatesController?.dispose();
        internalStatesController = null;
      }
      initStatesController();
    }
    if (widget.isSelected != oldWidget.isSelected) {
      statesController.update(WidgetState.selected, widget.isSelected);
    }
    if (enabled != isWidgetEnabled(oldWidget)) {
      statesController.update(WidgetState.disabled, !enabled);
      if (!enabled) {
        statesController.update(WidgetState.pressed, false);
      }
      statesController.update(WidgetState.hovered, _hovering);
    }
  }

  @override
  void dispose() {
    statesController.removeListener(handleStatesControllerChange);
    internalStatesController?.dispose();
    super.dispose();
  }

  bool get enabled => isWidgetEnabled(widget);

  bool _hovering = false;

  @override
  bool get wantKeepAlive => true;

  void handleMouseEnter(PointerEnterEvent event) {
    _hovering = true;
    statesController.update(WidgetState.hovered, true);
  }

  void handleMouseExit(PointerExitEvent event) {
    _hovering = false;
    statesController.update(WidgetState.hovered, false);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final ThemeData theme = Theme.of(context);

    Color? backgroundColor;

    if (statesController.value.contains(WidgetState.hovered)) {
      backgroundColor = theme.hoverColor;
    } else if (statesController.value.contains(WidgetState.selected)) {
      backgroundColor = theme.highlightColor;
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(4)),
        border: statesController.value.contains(WidgetState.selected)
            ? Border.all(
                color: theme.highlightColor,
              )
            : null,
        color: backgroundColor,
      ),
      child: MouseRegion(
        onEnter: handleMouseEnter,
        onExit: handleMouseExit,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          onDoubleTap: widget.onDoubleTap,
          onTapDown: widget.onTapDown,
          onTapUp: widget.onTapUp,
          onTapCancel: widget.onTapCancel,
          onLongPress: widget.onLongPress,
          onSecondaryTap: widget.onSecondaryTap,
          onSecondaryTapUp: widget.onSecondaryTapUp,
          onSecondaryTapDown: widget.onSecondaryTapDown,
          onSecondaryTapCancel: widget.onSecondaryTapCancel,
          child: widget.child,
        ),
      ),
    );
  }

  bool isWidgetEnabled(AppDesktopItemInk widget) {
    return _primaryButtonEnabled(widget) || _secondaryButtonEnabled(widget);
  }

  bool _primaryButtonEnabled(AppDesktopItemInk widget) {
    return widget.onTap != null ||
        widget.onDoubleTap != null ||
        widget.onLongPress != null ||
        widget.onTapUp != null ||
        widget.onTapDown != null;
  }

  bool _secondaryButtonEnabled(AppDesktopItemInk widget) {
    return widget.onSecondaryTap != null ||
        widget.onSecondaryTapUp != null ||
        widget.onSecondaryTapDown != null;
  }
}
