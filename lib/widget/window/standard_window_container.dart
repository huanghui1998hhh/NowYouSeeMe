import 'package:flutter/material.dart';

import 'window.dart';

class StandardWindowContainer extends StatelessWidget {
  const StandardWindowContainer({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final windowState = Window.of(context);
    final windowMode = windowState.mode;

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
            color: colorScheme.outlineVariant.withOpacity(0.8),
            blurRadius: 6,
          ),
        ],
      ),
      child: child,
    );
  }
}
