import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_shift/core/services/key_value_store.dart';
import 'package:pocket_shift/core/services/notification_service.dart';
import 'package:pocket_shift/core/utils/clock.dart';
import 'package:pocket_shift/features/game/application/session_controller.dart';
import 'package:pocket_shift/features/settings/application/settings_controller.dart';
import 'package:pocket_shift/features/settings/domain/app_settings.dart';

import '../../../helpers/in_memory_key_value_store.dart';

ProviderContainer _makeContainer({DateTime Function()? clock}) {
  return ProviderContainer(
    overrides: [
      keyValueStoreProvider.overrideWithValue(InMemoryKeyValueStore()),
      clockProvider.overrideWithValue(clock ?? () => DateTime(2026, 3, 23, 9)),
      notificationServiceProvider.overrideWithValue(_FakeNotificationService()),
    ],
  );
}

void main() {
  test('session controller can be invalidated and rebuilt without throwing', () async {
    final container = _makeContainer();
    addTearDown(container.dispose);

    final firstSession = await container.read(sessionControllerProvider.future);

    container.invalidate(settingsControllerProvider);
    container.invalidate(sessionControllerProvider);

    final secondSession = await container.read(sessionControllerProvider.future);

    expect(firstSession.date, '2026-03-23');
    expect(secondSession.date, '2026-03-23');
    expect(secondSession.startingCoins, firstSession.startingCoins);
  });

  test('moveCoin returns true and increments movedCoins', () async {
    final container = _makeContainer();
    addTearDown(container.dispose);

    await container.read(sessionControllerProvider.future);
    final result = await container.read(sessionControllerProvider.notifier).moveCoin();
    final session = await container.read(sessionControllerProvider.future);

    expect(result, isTrue);
    expect(session.movedCoins, 1);
    expect(session.remainingCoins, session.startingCoins - 1);
  });

  test('moveCoin returns false when no coins remain', () async {
    final container = _makeContainer();
    addTearDown(container.dispose);

    // Use 1 coin so we can exhaust it quickly
    await container.read(settingsControllerProvider.future);
    await container.read(settingsControllerProvider.notifier).updateDailyCoinCount(1);
    await container.read(sessionControllerProvider.future);

    final first = await container.read(sessionControllerProvider.notifier).moveCoin();
    expect(first, isTrue);

    final second = await container.read(sessionControllerProvider.notifier).moveCoin();
    expect(second, isFalse);

    final session = await container.read(sessionControllerProvider.future);
    expect(session.movedCoins, 1);
  });

  test('undoLastMove returns true and decrements movedCoins', () async {
    final container = _makeContainer();
    addTearDown(container.dispose);

    await container.read(sessionControllerProvider.future);
    await container.read(sessionControllerProvider.notifier).moveCoin();
    await container.read(sessionControllerProvider.notifier).moveCoin();

    final result = await container.read(sessionControllerProvider.notifier).undoLastMove();
    final session = await container.read(sessionControllerProvider.future);

    expect(result, isTrue);
    expect(session.movedCoins, 1);
  });

  test('undoLastMove returns false when there are no moves', () async {
    final container = _makeContainer();
    addTearDown(container.dispose);

    await container.read(sessionControllerProvider.future);

    final result = await container.read(sessionControllerProvider.notifier).undoLastMove();
    expect(result, isFalse);
  });

  test('refreshForToday preserves state when the date has not changed', () async {
    final container = _makeContainer();
    addTearDown(container.dispose);

    await container.read(sessionControllerProvider.future);
    await container.read(sessionControllerProvider.notifier).moveCoin();

    await container.read(sessionControllerProvider.notifier).refreshForToday();

    final session = await container.read(sessionControllerProvider.future);
    expect(session.movedCoins, 1);
  });
}

class _FakeNotificationService extends NotificationService {
  @override
  Future<void> syncDailyReminder(AppSettings settings) async {}
}
