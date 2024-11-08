import 'package:flutter/material.dart';

import 'widget/app/first_app.dart' deferred as first_app;
import 'widget/app/welcome/welcome.dart' deferred as welcome;
import 'widget/app_desktop_item.dart';
import 'widget/window/window_route/window_route.dart';

final firstApp = AppInfo(
  name: 'First App',
  primaryColor: Colors.white,
  route: () => AsyncWindowRoute(
    libFuture: first_app.loadLibrary(),
    pageBuilder: (context, _, __) => first_app.FirstApp(),
  ),
);

final welcomeApp = AppInfo(
  name: 'Welcome',
  icon: Image.network(
    'https://cdn.iconscout.com/icon/premium/png-512-thumb/welcome-4463836-3702459.png?f=webp&w=98',
  ),
  route: () => AsyncWindowRoute(
    libFuture: welcome.loadLibrary(),
    defaultSize: const Size(400, 220),
    pageBuilder: (context, _, __) => welcome.WelcomeApp(),
  ),
);
