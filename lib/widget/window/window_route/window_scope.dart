part of 'window_route.dart';

enum _WindowRouteAspect {
  isCurrent,
  canPop,
  settings,
}

class _WindowScopeStatus extends InheritedModel<_WindowRouteAspect> {
  const _WindowScopeStatus({
    required this.isCurrent,
    required this.canPop,
    required this.route,
    required super.child,
  });

  final bool isCurrent;
  final bool canPop;
  final Route<dynamic> route;

  @override
  bool updateShouldNotify(_WindowScopeStatus old) {
    return isCurrent != old.isCurrent ||
        canPop != old.canPop ||
        route != old.route;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder description) {
    super.debugFillProperties(description);
    description.add(
      FlagProperty(
        'isCurrent',
        value: isCurrent,
        ifTrue: 'active',
        ifFalse: 'inactive',
      ),
    );
    description.add(FlagProperty('canPop', value: canPop, ifTrue: 'can pop'));
  }

  @override
  bool updateShouldNotifyDependent(
    covariant _WindowScopeStatus oldWidget,
    Set<_WindowRouteAspect> dependencies,
  ) {
    return dependencies.any(
      (_WindowRouteAspect dependency) => switch (dependency) {
        _WindowRouteAspect.isCurrent => isCurrent != oldWidget.isCurrent,
        _WindowRouteAspect.canPop => canPop != oldWidget.canPop,
        _WindowRouteAspect.settings =>
          route.settings != oldWidget.route.settings,
      },
    );
  }
}

class _WindowScope<T> extends StatefulWidget {
  const _WindowScope({
    super.key,
    required this.route,
  });

  final WindowRoute<T> route;

  @override
  _WindowScopeState<T> createState() => _WindowScopeState<T>();
}

class _WindowScopeState<T> extends State<_WindowScope<T>> {
  Widget? _page;

  late Listenable _listenable;

  final FocusScopeNode focusScopeNode = FocusScopeNode(
    debugLabel: '$_WindowScopeState Focus Scope',
  );
  final ScrollController primaryScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final List<Listenable> animations = <Listenable>[
      if (widget.route.animation != null) widget.route.animation!,
      if (widget.route.secondaryAnimation != null)
        widget.route.secondaryAnimation!,
    ];
    _listenable = Listenable.merge(animations);
  }

  @override
  void didUpdateWidget(_WindowScope<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    assert(widget.route == oldWidget.route);
    _updateFocusScopeNode();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _page = null;
    _updateFocusScopeNode();
  }

  void _updateFocusScopeNode() {
    final TraversalEdgeBehavior traversalEdgeBehavior;
    final WindowRoute<T> route = widget.route;
    if (route.traversalEdgeBehavior != null) {
      traversalEdgeBehavior = route.traversalEdgeBehavior!;
    } else {
      traversalEdgeBehavior =
          route.navigator!.widget.routeTraversalEdgeBehavior;
    }
    focusScopeNode.traversalEdgeBehavior = traversalEdgeBehavior;
    if (route.isCurrent && _shouldRequestFocus) {
      route.navigator!.focusNode.enclosingScope?.setFirstFocus(focusScopeNode);
    }
  }

  void _forceRebuildPage() {
    setState(() {
      _page = null;
    });
  }

  @override
  void dispose() {
    focusScopeNode.dispose();
    primaryScrollController.dispose();
    super.dispose();
  }

  bool get _shouldIgnoreFocusRequest {
    return widget.route.animation?.status == AnimationStatus.reverse ||
        (widget.route.navigator?.userGestureInProgress ?? false);
  }

  bool get _shouldRequestFocus {
    return widget.route.navigator!.widget.requestFocus;
  }

  // This should be called to wrap any changes to route.isCurrent, route.canPop,
  // and route.offstage.
  void _routeSetState(VoidCallback fn) {
    if (widget.route.isCurrent &&
        !_shouldIgnoreFocusRequest &&
        _shouldRequestFocus) {
      widget.route.navigator!.focusNode.enclosingScope
          ?.setFirstFocus(focusScopeNode);
    }
    setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    // Only top most route can participate in focus traversal.
    focusScopeNode.skipTraversal = !widget.route.isCurrent;
    return AnimatedBuilder(
      animation: widget.route.restorationScopeId,
      builder: (BuildContext context, Widget? child) {
        assert(child != null);
        return RestorationScope(
          restorationId: widget.route.restorationScopeId.value,
          child: child!,
        );
      },
      child: _WindowScopeStatus(
        route: widget.route,
        isCurrent:
            widget.route.isCurrent, // _routeSetState is called if this updates
        canPop: widget.route.canPop, // _routeSetState is called if this updates
        child: Offstage(
          offstage:
              widget.route.offstage, // _routeSetState is called if this updates
          child: PageStorage(
            bucket: widget.route._storageBucket, // immutable
            child: Builder(
              builder: (BuildContext context) {
                return PrimaryScrollController(
                  controller: primaryScrollController,
                  child: FocusScope.withExternalFocusNode(
                    focusScopeNode: focusScopeNode, // immutable
                    child: RepaintBoundary(
                      child: WindowDisplayer(
                        key: widget.route._windowKey,
                        route: widget.route,
                        child: ListenableBuilder(
                          listenable: _listenable, // immutable
                          builder: (BuildContext context, Widget? child) {
                            return widget.route.buildTransitions(
                              context,
                              widget.route.animation!,
                              widget.route.secondaryAnimation!,
                              ListenableBuilder(
                                listenable: widget.route.navigator
                                        ?.userGestureInProgressNotifier ??
                                    ValueNotifier<bool>(false),
                                builder: (BuildContext context, Widget? child) {
                                  final bool ignoreEvents =
                                      _shouldIgnoreFocusRequest;
                                  focusScopeNode.canRequestFocus =
                                      !ignoreEvents;
                                  return IgnorePointer(
                                    ignoring: ignoreEvents,
                                    child: child,
                                  );
                                },
                                child: child,
                              ),
                            );
                          },
                          child: widget.route.buildWindow(
                            context,
                            _page ??= RepaintBoundary(
                              key: widget.route._subtreeKey, // immutable
                              child: Builder(
                                builder: (BuildContext context) {
                                  return widget.route.buildPage(
                                    context,
                                    widget.route.animation!,
                                    widget.route.secondaryAnimation!,
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
