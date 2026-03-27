import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_shift/core/constants/app_constants.dart';
import 'package:pocket_shift/core/services/key_value_store.dart';
import 'package:pocket_shift/core/services/notification_service.dart';
import 'package:pocket_shift/features/settings/application/settings_controller.dart';
import 'package:pocket_shift/features/settings/domain/app_settings.dart';
import 'package:pocket_shift/features/settings/domain/coin_style.dart';

import '../../../helpers/in_memory_key_value_store.dart';

void main() {
  group('SettingsController', () {
    ProviderContainer makeContainer() {
      return ProviderContainer(
        overrides: [
          keyValueStoreProvider.overrideWithValue(InMemoryKeyValueStore()),
          notificationServiceProvider.overrideWithValue(_FakeNotificationService()),
        ],
      );
    }

    test('builds with defaults when no settings are stored', () async {
      final container = makeContainer();
      addTearDown(container.dispose);

      final settings = await container.read(settingsControllerProvider.future);

      expect(settings, const AppSettings.defaults());
    });

    test('updateDailyCoinCount updates the coin count', () async {
      final container = makeContainer();
      addTearDown(container.dispose);

      await container.read(settingsControllerProvider.future);
      await container.read(settingsControllerProvider.notifier).updateDailyCoinCount(7);

      final settings = await container.read(settingsControllerProvider.future);
      expect(settings.dailyCoinCount, 7);
    });

    test('updateDailyCoinCount clamps to minimum', () async {
      final container = makeContainer();
      addTearDown(container.dispose);

      await container.read(settingsControllerProvider.future);
      await container.read(settingsControllerProvider.notifier).updateDailyCoinCount(0);

      final settings = await container.read(settingsControllerProvider.future);
      expect(settings.dailyCoinCount, AppConstants.minDailyCoinCount);
    });

    test('updateDailyCoinCount clamps to maximum', () async {
      final container = makeContainer();
      addTearDown(container.dispose);

      await container.read(settingsControllerProvider.future);
      await container.read(settingsControllerProvider.notifier).updateDailyCoinCount(999);

      final settings = await container.read(settingsControllerProvider.future);
      expect(settings.dailyCoinCount, AppConstants.maxDailyCoinCount);
    });

    test('setHapticsEnabled disables haptics', () async {
      final container = makeContainer();
      addTearDown(container.dispose);

      await container.read(settingsControllerProvider.future);
      await container.read(settingsControllerProvider.notifier).setHapticsEnabled(false);

      final settings = await container.read(settingsControllerProvider.future);
      expect(settings.hapticsEnabled, isFalse);
    });

    test('setSoundEnabled disables sound', () async {
      final container = makeContainer();
      addTearDown(container.dispose);

      await container.read(settingsControllerProvider.future);
      await container.read(settingsControllerProvider.notifier).setSoundEnabled(false);

      final settings = await container.read(settingsControllerProvider.future);
      expect(settings.soundEnabled, isFalse);
    });

    test('setCoinStyle updates the coin style', () async {
      final container = makeContainer();
      addTearDown(container.dispose);

      await container.read(settingsControllerProvider.future);
      await container.read(settingsControllerProvider.notifier).setCoinStyle(CoinStyle.quarter);

      final settings = await container.read(settingsControllerProvider.future);
      expect(settings.coinStyle, CoinStyle.quarter);
    });

    test('setThemeMode updates the theme mode', () async {
      final container = makeContainer();
      addTearDown(container.dispose);

      await container.read(settingsControllerProvider.future);
      await container.read(settingsControllerProvider.notifier).setThemeMode(AppThemeMode.dark);

      final settings = await container.read(settingsControllerProvider.future);
      expect(settings.themeMode, AppThemeMode.dark);
    });

    test('setRemindersEnabled enables reminders', () async {
      final container = makeContainer();
      addTearDown(container.dispose);

      await container.read(settingsControllerProvider.future);
      await container.read(settingsControllerProvider.notifier).setRemindersEnabled(true);

      final settings = await container.read(settingsControllerProvider.future);
      expect(settings.remindersEnabled, isTrue);
    });

    test('updateReminderTime updates hour and minute', () async {
      final container = makeContainer();
      addTearDown(container.dispose);

      await container.read(settingsControllerProvider.future);
      await container.read(settingsControllerProvider.notifier).updateReminderTime(hour: 9, minute: 30);

      final settings = await container.read(settingsControllerProvider.future);
      expect(settings.reminderHour, 9);
      expect(settings.reminderMinute, 30);
    });

    test('updateReminderCopy updates title and body', () async {
      final container = makeContainer();
      addTearDown(container.dispose);

      await container.read(settingsControllerProvider.future);
      await container
          .read(settingsControllerProvider.notifier)
          .updateReminderCopy(title: 'New title', body: 'New body');

      final settings = await container.read(settingsControllerProvider.future);
      expect(settings.reminderTitle, 'New title');
      expect(settings.reminderBody, 'New body');
    });

    test('resetReminderCopy restores defaults', () async {
      final container = makeContainer();
      addTearDown(container.dispose);

      await container.read(settingsControllerProvider.future);
      await container.read(settingsControllerProvider.notifier).updateReminderCopy(title: 'Custom', body: 'Custom');
      await container.read(settingsControllerProvider.notifier).resetReminderCopy();

      final settings = await container.read(settingsControllerProvider.future);
      expect(settings.reminderTitle, AppConstants.defaultReminderTitle);
      expect(settings.reminderBody, AppConstants.defaultReminderBody);
    });

    test('updates persist across controller rebuild', () async {
      final container = makeContainer();
      addTearDown(container.dispose);

      await container.read(settingsControllerProvider.future);
      await container.read(settingsControllerProvider.notifier).setCoinStyle(CoinStyle.dime);

      container.invalidate(settingsControllerProvider);

      final settings = await container.read(settingsControllerProvider.future);
      expect(settings.coinStyle, CoinStyle.dime);
    });
  });
}

class _FakeNotificationService extends NotificationService {
  @override
  Future<void> syncDailyReminder(AppSettings settings) async {}
}
