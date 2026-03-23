import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_shift/core/services/key_value_store.dart';
import 'package:pocket_shift/core/services/notification_service.dart';
import 'package:pocket_shift/core/utils/clock.dart';
import 'package:pocket_shift/features/game/application/session_controller.dart';
import 'package:pocket_shift/features/settings/application/settings_controller.dart';
import 'package:pocket_shift/features/settings/domain/app_settings.dart';

import '../../../helpers/in_memory_key_value_store.dart';

void main() {
  test(
    'session controller can be invalidated and rebuilt without throwing',
    () async {
      final store = InMemoryKeyValueStore();
      final container = ProviderContainer(
        overrides: [
          keyValueStoreProvider.overrideWithValue(store),
          clockProvider.overrideWithValue(() => DateTime(2026, 3, 23, 9)),
          notificationServiceProvider.overrideWithValue(
            _FakeNotificationService(),
          ),
        ],
      );
      addTearDown(container.dispose);

      final firstSession = await container.read(
        sessionControllerProvider.future,
      );

      container.invalidate(settingsControllerProvider);
      container.invalidate(sessionControllerProvider);

      final secondSession = await container.read(
        sessionControllerProvider.future,
      );

      expect(firstSession.date, '2026-03-23');
      expect(secondSession.date, '2026-03-23');
      expect(secondSession.startingCoins, firstSession.startingCoins);
    },
  );
}

class _FakeNotificationService extends NotificationService {
  @override
  Future<void> syncDailyReminder(AppSettings settings) async {}
}
