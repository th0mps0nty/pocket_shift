import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_shift/app/theme.dart';
import 'package:pocket_shift/core/services/key_value_store.dart';
import 'package:pocket_shift/core/services/notification_service.dart';
import 'package:pocket_shift/core/utils/clock.dart';
import 'package:pocket_shift/features/game/data/session_repository.dart';
import 'package:pocket_shift/features/game/domain/trigger_tag.dart';
import 'package:pocket_shift/features/insights/presentation/insights_screen.dart';
import 'package:pocket_shift/features/settings/domain/app_settings.dart';

import '../../../helpers/in_memory_key_value_store.dart';

void main() {
  testWidgets('insights screen renders weekly summary from local sessions', (tester) async {
    tester.view.physicalSize = const Size(1280, 2200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final store = InMemoryKeyValueStore();
    final repository = SessionRepository(store);
    final firstDay = DateTime(2026, 3, 25, 20);
    final secondDay = DateTime(2026, 3, 26, 20);
    final thirdDay = DateTime(2026, 3, 27, 8);

    final firstSession = await repository.ensureCurrentSession(
      now: firstDay,
      dailyCoinCount: 10,
    );
    await repository.saveCurrentSession(
      firstSession.moveOne(
        now: firstDay.add(const Duration(minutes: 1)),
        triggerTag: TriggerTag.complaining,
      ),
    );
    await repository.ensureCurrentSession(now: secondDay, dailyCoinCount: 10);

    final secondSession = await repository.loadCurrentSession();
    await repository.saveCurrentSession(
      secondSession!
          .moveOne(
            now: secondDay.add(const Duration(minutes: 1)),
            triggerTag: TriggerTag.workStress,
          )
          .moveOne(
            now: secondDay.add(const Duration(minutes: 2)),
            triggerTag: TriggerTag.complaining,
          ),
    );
    await repository.ensureCurrentSession(now: thirdDay, dailyCoinCount: 10);

    final container = ProviderContainer(
      overrides: [
        keyValueStoreProvider.overrideWithValue(store),
        clockProvider.overrideWithValue(() => thirdDay),
        notificationServiceProvider.overrideWithValue(_FakeNotificationService()),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: buildAppTheme(),
          darkTheme: buildDarkAppTheme(),
          home: const InsightsScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Insights'), findsOneWidget);
    expect(find.text('Moves this week'), findsOneWidget);
    expect(find.text('Top triggers'), findsOneWidget);
    expect(find.text('Complaining'), findsOneWidget);
    expect(find.text('3'), findsWidgets);
  });
}

class _FakeNotificationService extends NotificationService {
  @override
  Future<void> syncDailyReminder(AppSettings settings) async {}
}
