import 'package:flutter/material.dart';

import '../window_route/window_route.dart';

class StandardWindowContainer extends StatelessWidget {
  const StandardWindowContainer({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final windowMode = WindowRoute.of(context).mode;

    if (windowMode == WindowMode.maximized) {
      return Container(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
        ),
        child: child,
      );
    }

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        border: Border.all(
          color: colorScheme.outlineVariant,
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.windowShadowColor,
            blurRadius: 6,
          ),
        ],
      ),
      child: child,
    );
  }
}

extension on ColorScheme {
  Color get windowShadowColor => outlineVariant.withOpacity(
        switch (brightness) {
          Brightness.light => 0.8,
          Brightness.dark => 0.5,
        },
      );
}
