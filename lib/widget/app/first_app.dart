import 'package:flutter/material.dart';

import '../app_desktop_item.dart';
import '../brightness_switcher.dart';
import '../window/widget/window_draggable_area.dart';
import '../window/window_route/window_route.dart';

final firstApp = AppInfo(
  name: 'First App',
  route: () => StandardWindowRoute(
    pageBuilder: (context, animation, secondaryAnimation) => const FirstApp(),
  ),
);

class FirstApp extends StatelessWidget {
  const FirstApp({super.key});

  @override
  Widget build(BuildContext context) {
    final window = WindowRoute.of(context);

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
        ),
        TextButton(
          onPressed: () {
            window.mode = WindowMode.maximized;
          },
          child: const Text('Maximize'),
        ),
        TextButton(
          onPressed: () {
            window.mode = WindowMode.normal;
          },
          child: const Text('Normal'),
        ),
        const BrightnessSwitcher(),
        TextButton(
          onPressed: () {
            Navigator.of(context).push(
              StandardWindowRoute(
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
