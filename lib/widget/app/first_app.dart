import 'package:flutter/material.dart';

import '../brightness_switcher.dart';
import '../window/window.dart';
import 'nomodel_route.dart';

class FirstApp extends StatelessWidget {
  const FirstApp({super.key});

  @override
  Widget build(BuildContext context) {
    final windowState = Window.of(context);

    return Column(
      children: [
        SizedBox(
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
                  onTap: () {
                    windowState.mode = windowState.mode.toggle;
                  },
                  child: const SizedBox(
                    width: 46,
                    child: Align(
                      child: Icon(Icons.remove),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    windowState.mode = windowState.mode.toggle;
                  },
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
        ),
        TextButton(
          onPressed: () {
            windowState.mode = WindowMode.maximized;
          },
          child: const Text('Maximize'),
        ),
        TextButton(
          onPressed: () {
            windowState.mode = WindowMode.normal;
          },
          child: const Text('Normal'),
        ),
        const BrightnessSwitcher(),
        TextButton(
          onPressed: () {
            Navigator.of(context).push(
              RawWindowRoute(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    Builder(
                  builder: (context) => Align(
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('pop'),
                    ),
                  ),
                ),
              ),
            );
          },
          child: const Text('About'),
        ),
      ],
    );
  }
}
