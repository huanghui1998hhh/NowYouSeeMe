import 'package:flutter/material.dart';

import 'util/storage.dart';
import 'widget/brightness_switcher.dart';
import 'widget/window/window.dart';

void main() async {
  await Storage.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seedColor = Color(0xFF3a164c);

    return ValueListenableBuilder(
      valueListenable: themeMode,
      builder: (context, themeMode, child) {
        return MaterialApp(
          title: 'Now You See Me',
          themeMode: themeMode,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: seedColor),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: seedColor,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
          ),
          home: const MyHomePage(),
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Window(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer,
                borderRadius: const BorderRadius.all(Radius.circular(12)),
              ),
              child: Builder(
                builder: (context) {
                  return Column(
                    children: [
                      WindowDraggableArea(
                        child: AppBar(
                          title: const Text('Now You See Me'),
                          backgroundColor: Colors.red,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Window.of(context).mode = WindowMode.maximized;
                        },
                        child: const Text('Maximize'),
                      ),
                      TextButton(
                        onPressed: () {
                          Window.of(context).mode = WindowMode.normal;
                        },
                        child: const Text('Normal'),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
