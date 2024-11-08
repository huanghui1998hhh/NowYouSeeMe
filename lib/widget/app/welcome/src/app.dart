import 'package:flutter/material.dart';

import '../../../title_bar.dart';

class WelcomeApp extends StatelessWidget {
  const WelcomeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const TitleBar(),
        const SizedBox(height: 44),
        Text(
          'Welcome!!!',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 22),
        Text(
          'Wanna see something interesting?',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }
}
