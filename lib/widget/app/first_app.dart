import 'package:flutter/material.dart';

import '../brightness_switcher.dart';
import '../title_bar.dart';
import '../window/window_route/window_route.dart';

class FirstApp extends StatelessWidget {
  const FirstApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const TitleBar(),
        const SizedBox(height: 44),
        const BrightnessSwitcher(),
        const SizedBox(height: 22),
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
