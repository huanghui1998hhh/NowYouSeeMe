import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../../async_container.dart';
import '../../resize_listener.dart';
import '../widget/standard_window_container.dart';
import 'window_model_box.dart';

part 'window_displayer.dart';
part 'window_scope.dart';

// This file is a modified version of flutter's [ModalRoute].

enum WindowMode {
  // windowed
  normal,
  // full screen
  maximized;

  WindowMode get toggle => switch (this) {
        WindowMode.normal => WindowMode.maximized,
        WindowMode.maximized => WindowMode.normal,
      };
}

mixin WindowManagementMixin<T> on Route<T> {
  // TODO: make there data inherited?
  final GlobalKey<_WindowDisplayerState> _windowKey =
      GlobalKey<_WindowDisplayerState>();

  Size get defaultSize;

  WindowMode _mode = WindowMode.normal;
  WindowMode get mode => _mode;
  set mode(WindowMode mode) {
    if (mode == _mode) return;
    _updateWindowState(() {
      _mode = mode;
    });
  }

  late Rect _rect =
      navigator?.context.renderSizer?.centerRectFor(defaultSize) ??
          Offset.zero & defaultSize;
  Rect get rect => _rect;
  set rect(Rect rect) {
    if (rect == _rect) return;
    _updateWindowState(() {
      _rect = rect;
    });
  }

  void _updateWindowState(VoidCallback fn) {
    if (_windowKey.currentState != null) {
      // ignore: invalid_use_of_protected_member
      _windowKey.currentState!.setState(fn);
    } else {
      fn();
    }
  }

  void toggleWindowMode() {
    mode = mode.toggle;
  }

  void shift(Offset delta) {
    rect = rect.shift(delta);
  }

  void toNormalMode({required Offset startPosition}) {
    assert(startPosition.dx >= 0 && startPosition.dy >= 0);
    if (mode == WindowMode.normal) return;
    final render = _windowKey.currentContext!.findRenderObject()! as RenderBox;
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

abstract class WindowRoute<T> extends TransitionRoute<T>
    with LocalHistoryRoute<T>, WindowManagementMixin<T> {
  WindowRoute({
    super.settings,
    this.defaultSize = const Size(280, 380),
    this.traversalEdgeBehavior,
  });

  @override
  final Size defaultSize;
  final TraversalEdgeBehavior? traversalEdgeBehavior;

  @optionalTypeArgs
  static WindowRoute<T> of<T extends Object?>(BuildContext context) {
    final windowRoute = _maybeOf<T>(context);
    if (windowRoute == null) {
      throw AssertionError(
        'WindowRoute operation requested with a context that does not include a WindowRoute.',
      );
    }
    return windowRoute;
  }

  @optionalTypeArgs
  static WindowRoute<T>? maybeOf<T extends Object?>(BuildContext context) {
    return _maybeOf<T>(context);
  }

  static WindowRoute<T>? _maybeOf<T extends Object?>(
    BuildContext context, [
    _WindowRouteAspect? aspect,
  ]) {
    return InheritedModel.inheritFrom<_WindowScopeStatus>(
      context,
      aspect: aspect,
    )?.route as WindowRoute<T>?;
  }

  static bool? isCurrentMaybeOf(BuildContext context) =>
      _maybeOf(context, _WindowRouteAspect.isCurrent)?.isCurrent;

  static bool? canPopMaybeOf(BuildContext context) =>
      _maybeOf(context, _WindowRouteAspect.canPop)?.canPop;

  static RouteSettings? settingsMaybeOf(BuildContext context) =>
      _maybeOf(context, _WindowRouteAspect.settings)?.settings;

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
    super.defaultSize,
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

class AsyncWindowRoute<T> extends StandardWindowRoute<T> {
  AsyncWindowRoute({
    required Future<dynamic> libFuture,
    required super.pageBuilder,
    super.transitionDuration = const Duration(milliseconds: 200),
    super.transitionBuilder,
    super.defaultSize,
    super.settings,
    super.traversalEdgeBehavior,
  }) : _libFuture = libFuture;

  final Future<dynamic> _libFuture;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      child: AsyncPageContainer(
        libFuture: _libFuture,
        builder: (context) =>
            _pageBuilder(context, animation, secondaryAnimation),
      ),
    );
  }
}

extension on BuildContext {
  /// The size of the render object.
  ///
  /// **Why not just use [Element.size]?**
  ///
  /// Usually we should not get size during build. And the [Element.size] did so.
  Size? get renderSizer => switch (findRenderObject()) {
        final RenderBox e => e.size,
        _ => null,
      };
}

extension on Size {
  Rect centerRectFor(Size size) => Rect.fromCenter(
        center: center(Offset.zero),
        width: size.width,
        height: size.height,
      );
}
