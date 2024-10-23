import 'package:flutter/material.dart';

import '../util/enum2json.dart';
import '../util/storage.dart';

final themeMode = () {
  final themeModeInt = Storage.getInt(StorageKeys.themeMode);
  return ValueNotifier<ThemeMode>(
    jsonToEnum(themeModeInt, ThemeMode.values) ?? ThemeMode.light,
  );
}();

class BrightnessSwitcher extends StatelessWidget {
  const BrightnessSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: Theme.of(context).brightness == Brightness.dark,
      inactiveThumbColor: Colors.transparent,
      inactiveTrackColor: Colors.amber,
      trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      activeThumbImage: const AssetImage('assets/png/moon.png'),
      inactiveThumbImage: const AssetImage('assets/png/sun.png'),
      splashRadius: 0,
      onChanged: (value) async {
        final target = value ? ThemeMode.dark : ThemeMode.light;
        themeMode.value = target;
        final storageSuccess = await Storage.setInt(
          StorageKeys.themeMode,
          enumToJson(target)!,
        );
        if (!storageSuccess) {
          themeMode.value = target.toogle;
        }
      },
    );
  }
}

extension on ThemeMode {
  ThemeMode get toogle => switch (this) {
        ThemeMode.system => throw Exception('Cannot toggle system theme'),
        ThemeMode.light => ThemeMode.dark,
        ThemeMode.dark => ThemeMode.light,
      };
}
