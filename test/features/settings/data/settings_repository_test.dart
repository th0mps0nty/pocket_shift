import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_shift/features/settings/data/settings_repository.dart';
import 'package:pocket_shift/features/settings/domain/app_settings.dart';
import 'package:pocket_shift/features/settings/domain/coin_style.dart';

import '../../../helpers/in_memory_key_value_store.dart';

void main() {
  group('AppSettings', () {
    test('serializes and deserializes cleanly', () {
      const settings = AppSettings(
        dailyCoinCount: 12,
        hapticsEnabled: false,
        soundEnabled: true,
        remindersEnabled: true,
        reminderHour: 19,
        reminderMinute: 45,
        coinStyle: CoinStyle.quarter,
      );

      final roundTrip = AppSettings.fromJson(settings.toJson());

      expect(roundTrip, settings);
    });
  });

  group('SettingsRepository', () {
    test('persists and loads app settings', () async {
      final repository = SettingsRepository(InMemoryKeyValueStore());
      const settings = AppSettings(
        dailyCoinCount: 7,
        hapticsEnabled: true,
        soundEnabled: false,
        remindersEnabled: true,
        reminderHour: 21,
        reminderMinute: 15,
        coinStyle: CoinStyle.dime,
      );

      await repository.save(settings);
      final loaded = await repository.load();

      expect(loaded, settings);
    });

    test('returns defaults when nothing has been saved yet', () async {
      final repository = SettingsRepository(InMemoryKeyValueStore());

      final loaded = await repository.load();

      expect(loaded, const AppSettings.defaults());
    });
  });
}
