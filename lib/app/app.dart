import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/settings/application/settings_controller.dart';
import '../features/settings/domain/app_settings.dart';
import 'router.dart';
import 'theme.dart';

class PocketShiftApp extends ConsumerWidget {
  const PocketShiftApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final appThemeMode = ref.watch(
      settingsControllerProvider.select((s) => s.valueOrNull?.themeMode ?? AppThemeMode.system),
    );

    return MaterialApp.router(
      title: 'Pocket Shift',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      darkTheme: buildDarkAppTheme(),
      themeMode: switch (appThemeMode) {
        AppThemeMode.system => ThemeMode.system,
        AppThemeMode.light => ThemeMode.light,
        AppThemeMode.dark => ThemeMode.dark,
      },
      routerConfig: router,
    );
  }
}
