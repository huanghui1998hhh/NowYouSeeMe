import 'package:flutter/material.dart';

import 'window/widget/window_draggable_area.dart';
import 'window/window_route/window_route.dart';

class TitleBar extends StatelessWidget {
  const TitleBar({super.key});

  @override
  Widget build(BuildContext context) {
    final window = WindowRoute.of(context);

    return SizedBox(
      height: 40,
      child: Material(
        color: Theme.of(context).colorScheme.secondaryContainer,
        child: Row(
          children: [
            const Expanded(
              child: WindowDraggableArea(
                child: SizedBox.expand(),
              ),
            ),
            InkWell(
              onTap: window.toggleWindowMode,
              child: const SizedBox(
                width: 46,
                child: Align(
                  child: Icon(Icons.remove),
                ),
              ),
            ),
            InkWell(
              onTap: window.toggleWindowMode,
              child: const SizedBox(
                width: 46,
                child: Align(
                  child: Icon(Icons.unfold_more),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.of(context).pop();
              },
              hoverColor: const Color(0xFFe30d2c),
              child: const SizedBox(
                width: 46,
                child: Align(
                  child: Icon(Icons.close),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
