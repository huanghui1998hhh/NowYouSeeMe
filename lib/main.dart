import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'apps.dart';
import 'util/storage.dart';
import 'widget/app_desktop_item.dart';
import 'widget/brightness_switcher.dart';

void main() async {
  await Storage.init();
  runApp(ValueListenableProvider.value(value: themeMode, child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seedColor = Color(0xFF3a164c);

    return MaterialApp(
      title: 'Now You See Me',
      themeMode: context.watch<ThemeMode>(),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: seedColor),
        useMaterial3: true,
        splashFactory: InkSparkle.splashFactory,
        popupMenuTheme: const PopupMenuThemeData(
          menuPadding: EdgeInsets.symmetric(vertical: 4),
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        splashFactory: InkSparkle.splashFactory,
        popupMenuTheme: const PopupMenuThemeData(
          menuPadding: EdgeInsets.symmetric(vertical: 4),
        ),
      ),
      builder: (context, child) => Scaffold(body: child),
      home: const MyHomePage(),
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
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 1)).then((value) {
      if (mounted) {
        if (Storage.getBool('welcome_app_shown') != true) {
          Storage.setBool('welcome_app_shown', true);
          Navigator.of(context).push(welcomeApp.route());
        }
      }
    });
  }

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
        Positioned.fill(
          child: Material(
            type: MaterialType.transparency,
            child: Stack(
              children: [
                Positioned(
                  top: 10,
                  left: 10,
                  child: AppDesktopItem(appInfo: firstApp),
                ),
                Align(
                  child: AppDesktopItem(appInfo: welcomeApp),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
