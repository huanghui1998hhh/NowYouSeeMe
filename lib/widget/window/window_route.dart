import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import 'standard_window_container.dart';
import 'window.dart';

// This file is a modified version of flutter's [ModalRoute].

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
                      child: Window(
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

abstract class WindowRoute<T> extends TransitionRoute<T>
    with LocalHistoryRoute<T> {
  WindowRoute({
    super.settings,
    this.traversalEdgeBehavior,
  });

  final TraversalEdgeBehavior? traversalEdgeBehavior;

  @optionalTypeArgs
  static WindowRoute<T>? of<T extends Object?>(BuildContext context) {
    return _of<T>(context);
  }

  static WindowRoute<T>? _of<T extends Object?>(
    BuildContext context, [
    _WindowRouteAspect? aspect,
  ]) {
    return InheritedModel.inheritFrom<_WindowScopeStatus>(
      context,
      aspect: aspect,
    )?.route as WindowRoute<T>?;
  }

  static bool? isCurrentOf(BuildContext context) =>
      _of(context, _WindowRouteAspect.isCurrent)?.isCurrent;

  static bool? canPopOf(BuildContext context) =>
      _of(context, _WindowRouteAspect.canPop)?.canPop;

  static RouteSettings? settingsOf(BuildContext context) =>
      _of(context, _WindowRouteAspect.settings)?.settings;

  @protected
  void setState(VoidCallback fn) {
    if (_scopeKey.currentState != null) {
      _scopeKey.currentState!._routeSetState(fn);
    } else {
      fn();
    }
  }

  static RoutePredicate withName(String name) {
    return (Route<dynamic> route) {
      return !route.willHandlePopInternally &&
          route is WindowRoute &&
          route.settings.name == name;
    };
  }

  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  );

  Widget buildWindow(
    BuildContext context,
    Widget child,
  ) =>
      child;

  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }

  @override
  void install() {
    super.install();
    _animationProxy = ProxyAnimation(super.animation);
    _secondaryAnimationProxy = ProxyAnimation(super.secondaryAnimation);
  }

  @override
  TickerFuture didPush() {
    if (_scopeKey.currentState != null && navigator!.widget.requestFocus) {
      navigator!.focusNode.enclosingScope
          ?.setFirstFocus(_scopeKey.currentState!.focusScopeNode);
    }
    return super.didPush();
  }

  @override
  void didAdd() {
    if (_scopeKey.currentState != null && navigator!.widget.requestFocus) {
      navigator!.focusNode.enclosingScope
          ?.setFirstFocus(_scopeKey.currentState!.focusScopeNode);
    }
    super.didAdd();
  }

  @override
  bool get opaque => false;

  @override
  bool get allowSnapshotting => true;

  bool get semanticsDismissible => true;

  bool get maintainState => true;

  bool get popGestureInProgress => navigator!.userGestureInProgress;

  @override
  bool get popGestureEnabled {
    // If there's nothing to go back to, then obviously we don't support
    // the back gesture.
    if (isFirst) {
      return false;
    }
    // If the route wouldn't actually pop if we popped it, then the gesture
    // would be really confusing (or would skip internal routes), so disallow it.
    if (willHandlePopInternally) {
      return false;
    }
    // If attempts to dismiss this route might be vetoed such as in a page
    // with forms, then do not allow the user to dismiss the route with a swipe.
    if (popDisposition == RoutePopDisposition.doNotPop) {
      return false;
    }
    // If we're in an animation already, we cannot be manually swiped.
    if (!animation!.isCompleted) {
      return false;
    }
    // If we're being popped into, we also cannot be swiped until the pop above
    // it completes. This translates to our secondary animation being
    // dismissed.
    if (!secondaryAnimation!.isDismissed) {
      return false;
    }
    // If we're in a gesture already, we cannot start another.
    if (popGestureInProgress) {
      return false;
    }

    // Looks like a back gesture would be welcome!
    return true;
  }

  bool get offstage => _offstage;
  bool _offstage = false;
  set offstage(bool value) {
    if (_offstage == value) {
      return;
    }
    setState(() {
      _offstage = value;
    });
    _animationProxy!.parent =
        _offstage ? kAlwaysCompleteAnimation : super.animation;
    _secondaryAnimationProxy!.parent =
        _offstage ? kAlwaysDismissedAnimation : super.secondaryAnimation;
    changedInternalState();
  }

  BuildContext? get subtreeContext => _subtreeKey.currentContext;

  @override
  Animation<double>? get animation => _animationProxy;
  ProxyAnimation? _animationProxy;

  @override
  Animation<double>? get secondaryAnimation => _secondaryAnimationProxy;
  ProxyAnimation? _secondaryAnimationProxy;

  final Set<PopEntry<Object?>> _popEntries = <PopEntry<Object?>>{};

  @override
  RoutePopDisposition get popDisposition {
    for (final PopEntry<Object?> popEntry in _popEntries) {
      if (!popEntry.canPopNotifier.value) {
        return RoutePopDisposition.doNotPop;
      }
    }

    return super.popDisposition;
  }

  @override
  void onPopInvokedWithResult(bool didPop, T? result) {
    for (final PopEntry<Object?> popEntry in _popEntries) {
      popEntry.onPopInvokedWithResult(didPop, result);
    }
    super.onPopInvokedWithResult(didPop, result);
  }

  void registerPopEntry(PopEntry<Object?> popEntry) {
    _popEntries.add(popEntry);
    popEntry.canPopNotifier.addListener(_maybeDispatchNavigationNotification);
    _maybeDispatchNavigationNotification();
  }

  void unregisterPopEntry(PopEntry<Object?> popEntry) {
    _popEntries.remove(popEntry);
    popEntry.canPopNotifier
        .removeListener(_maybeDispatchNavigationNotification);
    _maybeDispatchNavigationNotification();
  }

  void _maybeDispatchNavigationNotification() {
    if (!isCurrent) {
      return;
    }
    final NavigationNotification notification = NavigationNotification(
      canHandlePop: popDisposition == RoutePopDisposition.doNotPop,
    );
    switch (SchedulerBinding.instance.schedulerPhase) {
      case SchedulerPhase.postFrameCallbacks:
        notification.dispatch(subtreeContext);
      case SchedulerPhase.idle:
      case SchedulerPhase.midFrameMicrotasks:
      case SchedulerPhase.persistentCallbacks:
      case SchedulerPhase.transientCallbacks:
        SchedulerBinding.instance.addPostFrameCallback(
          (Duration timeStamp) {
            if (!(subtreeContext?.mounted ?? false)) {
              return;
            }
            notification.dispatch(subtreeContext);
          },
          debugLabel: 'ModalRoute.dispatchNotification',
        );
    }
  }

  @override
  void didChangePrevious(Route<dynamic>? previousRoute) {
    super.didChangePrevious(previousRoute);
    changedInternalState();
  }

  @override
  void didChangeNext(Route<dynamic>? nextRoute) {
    super.didChangeNext(nextRoute);
    changedInternalState();
  }

  @override
  void didPopNext(Route<dynamic> nextRoute) {
    super.didPopNext(nextRoute);
    changedInternalState();
    _maybeDispatchNavigationNotification();
  }

  @override
  void changedInternalState() {
    super.changedInternalState();
    // No need to mark dirty if this method is called during build phase.
    if (SchedulerBinding.instance.schedulerPhase !=
        SchedulerPhase.persistentCallbacks) {
      setState(() {/* internal state already changed */});
    }
    _modalScope.maintainState = maintainState;
  }

  @override
  void changedExternalState() {
    super.changedExternalState();
    if (_scopeKey.currentState != null) {
      _scopeKey.currentState!._forceRebuildPage();
    }
  }

  bool get canPop => hasActiveRouteBelow || willHandlePopInternally;

  // Internals

  final GlobalKey<_WindowScopeState<T>> _scopeKey =
      GlobalKey<_WindowScopeState<T>>();
  final GlobalKey _subtreeKey = GlobalKey();
  final PageStorageBucket _storageBucket = PageStorageBucket();

  Widget? _modalScopeCache;

  Widget _buildModalScope(BuildContext context) {
    return _modalScopeCache ??= Semantics(
      sortKey: const OrdinalSortKey(0.0),
      child: _WindowScope<T>(
        key: _scopeKey,
        route: this,
      ),
    );
  }

  late OverlayEntry _modalScope;

  @override
  Iterable<OverlayEntry> createOverlayEntries() {
    return <OverlayEntry>[
      _modalScope = OverlayEntry(
        builder: _buildModalScope,
        maintainState: maintainState,
        canSizeOverlay: opaque,
      ),
    ];
  }

  @override
  String toString() =>
      '${objectRuntimeType(this, 'ModalRoute')}($settings, animation: $animation)';
}

class StandardWindowRoute<T> extends WindowRoute<T> {
  StandardWindowRoute({
    required RoutePageBuilder pageBuilder,
    Duration transitionDuration = const Duration(milliseconds: 200),
    RouteTransitionsBuilder? transitionBuilder,
    super.settings,
    super.traversalEdgeBehavior,
  })  : _pageBuilder = pageBuilder,
        _transitionDuration = transitionDuration,
        _transitionBuilder = transitionBuilder;

  final RoutePageBuilder _pageBuilder;

  @override
  Duration get transitionDuration => _transitionDuration;
  final Duration _transitionDuration;

  final RouteTransitionsBuilder? _transitionBuilder;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      child: _pageBuilder(context, animation, secondaryAnimation),
    );
  }

  /// The difference between this and [WindowRoute.buildPage] is that this
  /// build will wrap the [_subtreeKey] widget. So that you can manage your
  /// state for the window's position/size/etc. without losing child's state.
  @override
  Widget buildWindow(BuildContext context, Widget child) =>
      StandardWindowContainer(child: child);

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (_transitionBuilder == null) {
      return ScaleTransition(
        scale: animation.drive(Tween<double>(begin: 0.95, end: 1.0)),
        alignment: const Alignment(0, 0.1),
        child: FadeTransition(
          opacity: animation,
          child: child,
        ),
      );
    }
    return _transitionBuilder(context, animation, secondaryAnimation, child);
  }
}
