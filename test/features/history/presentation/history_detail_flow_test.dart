import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pocket_shift/app/theme.dart';
import 'package:pocket_shift/core/services/key_value_store.dart';
import 'package:pocket_shift/core/services/notification_service.dart';
import 'package:pocket_shift/core/utils/clock.dart';
import 'package:pocket_shift/core/utils/date_utils.dart';
import 'package:pocket_shift/features/game/data/session_repository.dart';
import 'package:pocket_shift/features/game/domain/trigger_tag.dart';
import 'package:pocket_shift/features/history/presentation/history_screen.dart';
import 'package:pocket_shift/features/history/presentation/session_detail_screen.dart';
import 'package:pocket_shift/features/settings/domain/app_settings.dart';

import '../../../helpers/in_memory_key_value_store.dart';

void main() {
  testWidgets('history card opens session detail and allows editing reflection', (tester) async {
    tester.view.physicalSize = const Size(1280, 2200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final store = InMemoryKeyValueStore();
    final repository = SessionRepository(store);
    final firstDay = DateTime(2026, 3, 22, 20);
    final secondDay = DateTime(2026, 3, 23, 7);

    final firstSession = await repository.ensureCurrentSession(
      now: firstDay,
      dailyCoinCount: 10,
    );
    await repository.saveCurrentSession(
      firstSession
          .moveOne(
            now: firstDay.add(const Duration(minutes: 1)),
            triggerTag: TriggerTag.complaining,
            note: 'Snapped over something small.',
          )
          .saveReflection(
            now: firstDay.add(const Duration(hours: 1)),
            whatShowedUp: 'I was short with people.',
            whatHelped: 'A pause outside.',
          ),
    );
    await repository.ensureCurrentSession(
      now: secondDay,
      dailyCoinCount: 10,
    );

    final container = ProviderContainer(
      overrides: [
        keyValueStoreProvider.overrideWithValue(store),
        clockProvider.overrideWithValue(() => secondDay),
        notificationServiceProvider.overrideWithValue(_FakeNotificationService()),
      ],
    );
    addTearDown(container.dispose);

    final router = GoRouter(
      initialLocation: '/history',
      routes: [
        GoRoute(
          path: '/history',
          builder: (context, state) => const HistoryScreen(),
          routes: [
            GoRoute(
              path: ':sessionId',
              builder: (context, state) =>
                  SessionDetailScreen(sessionId: state.pathParameters['sessionId']!),
            ),
          ],
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          theme: buildAppTheme(),
          darkTheme: buildDarkAppTheme(),
          routerConfig: router,
        ),
      ),
    );

    await tester.pumpAndSettle();

    final archivedLabel = PocketShiftDateUtils.formatSessionDate('2026-03-22');
    await tester.tap(find.text(archivedLabel));
    await tester.pumpAndSettle();

    expect(find.text('Session detail'), findsOneWidget);
    expect(find.text('Move timeline'), findsOneWidget);
    expect(find.text('Complaining'), findsOneWidget);
    expect(find.text('I was short with people.'), findsOneWidget);

    await tester.tap(find.widgetWithText(OutlinedButton, 'Edit reflection'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextField, 'What showed up most today?'),
      'I caught the tone earlier the second time.',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Save reflection'));
    await tester.pumpAndSettle();

    expect(find.text('I caught the tone earlier the second time.'), findsOneWidget);
  });
}

class _FakeNotificationService extends NotificationService {
  @override
  Future<void> syncDailyReminder(AppSettings settings) async {}
}
