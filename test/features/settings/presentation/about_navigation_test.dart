import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pocket_shift/core/services/key_value_store.dart';
import 'package:pocket_shift/core/services/notification_service.dart';
import 'package:pocket_shift/features/settings/domain/app_settings.dart';
import 'package:pocket_shift/features/settings/presentation/about_screen.dart';
import 'package:pocket_shift/features/settings/presentation/settings_screen.dart';

import '../../../helpers/in_memory_key_value_store.dart';

void main() {
  testWidgets('navigates from settings to about and back', (tester) async {
    tester.view.physicalSize = const Size(1280, 2200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final container = ProviderContainer(
      overrides: [
        keyValueStoreProvider.overrideWithValue(InMemoryKeyValueStore()),
        notificationServiceProvider.overrideWithValue(
          _FakeNotificationService(),
        ),
      ],
    );
    addTearDown(container.dispose);

    final router = GoRouter(
      initialLocation: '/settings',
      routes: [
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
          routes: [
            GoRoute(
              path: 'about',
              builder: (context, state) => const AboutScreen(),
            ),
          ],
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    final aboutButton = find.widgetWithText(OutlinedButton, 'Open About');

    await tester.scrollUntilVisible(
      aboutButton,
      300,
      scrollable: find.byType(Scrollable).first,
    );

    await tester.ensureVisible(aboutButton);
    await tester.tap(aboutButton);
    await tester.pumpAndSettle();

    expect(find.text('About Pocket Shift'), findsWidgets);
    expect(find.text('Why it exists'), findsOneWidget);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      aboutButton,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(aboutButton, findsOneWidget);
  });
}

class _FakeNotificationService extends NotificationService {
  @override
  Future<void> syncDailyReminder(AppSettings settings) async {}
}
