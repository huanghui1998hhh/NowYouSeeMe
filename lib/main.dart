import 'package:flutter/material.dart';

import 'util/storage.dart';
import 'widget/app/first_app.dart';
import 'widget/app/nomodel_route.dart';
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
            splashFactory: InkSparkle.splashFactory,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: seedColor,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
            splashFactory: InkSparkle.splashFactory,
          ),
          builder: (context, child) => Scaffold(body: child),
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
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/jpg/desktop.jpg',
            fit: BoxFit.cover,
          ),
        ),
        const Positioned(
          top: 10,
          left: 10,
          child: ExampleButton(),
        ),
        const Align(
          child: ExampleButton(),
        ),
      ],
    );
  }
}

class ExampleButton extends StatelessWidget {
  const ExampleButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          RawWindowRoute(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const Window.standard(child: FirstApp()),
          ),
        );
      },
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Align(child: FlutterLogo(size: 44)),
      ),
    );
  }
}
