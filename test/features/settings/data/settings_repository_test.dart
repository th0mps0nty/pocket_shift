import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_shift/core/constants/app_constants.dart';
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
        reminderTitle: 'Pause and notice',
        reminderBody: 'Take a breath and check which pocket the day is in.',
        coinStyle: CoinStyle.quarter,
        themeMode: AppThemeMode.system,
      );

      final roundTrip = AppSettings.fromJson(settings.toJson());

      expect(roundTrip, settings);
    });

    test('falls back to default reminder copy when blank values are provided', () {
      final settings = AppSettings.fromJson(const {
        'dailyCoinCount': 10,
        'hapticsEnabled': true,
        'soundEnabled': true,
        'remindersEnabled': true,
        'reminderHour': 8,
        'reminderMinute': 0,
        'reminderTitle': '   ',
        'reminderBody': '',
        'coinStyle': 'penny',
      });

      expect(settings.reminderTitle, AppConstants.defaultReminderTitle);
      expect(settings.reminderBody, AppConstants.defaultReminderBody);
    });

    test('serializes and deserializes AppThemeMode.dark', () {
      const settings = AppSettings.defaults();
      final dark = settings.copyWith(themeMode: AppThemeMode.dark);

      expect(AppSettings.fromJson(dark.toJson()).themeMode, AppThemeMode.dark);
    });

    test('serializes and deserializes AppThemeMode.light', () {
      const settings = AppSettings.defaults();
      final light = settings.copyWith(themeMode: AppThemeMode.light);

      expect(AppSettings.fromJson(light.toJson()).themeMode, AppThemeMode.light);
    });

    test('AppThemeMode.fromStorageValue falls back to system for unknown values', () {
      expect(AppThemeMode.fromStorageValue('bogus'), AppThemeMode.system);
      expect(AppThemeMode.fromStorageValue(null), AppThemeMode.system);
    });

    test('serializes and deserializes all CoinStyle values', () {
      for (final style in CoinStyle.values) {
        final settings = AppSettings.defaults().copyWith(coinStyle: style);
        final roundTrip = AppSettings.fromJson(settings.toJson());
        expect(roundTrip.coinStyle, style, reason: 'failed for $style');
      }
    });

    test('CoinStyleX.fromStorageValue falls back to penny for unknown values', () {
      expect(CoinStyleX.fromStorageValue('bogus'), CoinStyle.penny);
      expect(CoinStyleX.fromStorageValue(null), CoinStyle.penny);
    });

    test('copyWith clamps dailyCoinCount to minimum', () {
      final clamped = AppSettings.defaults().copyWith(dailyCoinCount: 0);
      expect(clamped.dailyCoinCount, AppConstants.minDailyCoinCount);
    });

    test('copyWith clamps dailyCoinCount to maximum', () {
      final clamped = AppSettings.defaults().copyWith(dailyCoinCount: 999);
      expect(clamped.dailyCoinCount, AppConstants.maxDailyCoinCount);
    });

    test('copyWith preserves fields not specified', () {
      const base = AppSettings(
        dailyCoinCount: 7,
        hapticsEnabled: false,
        soundEnabled: false,
        remindersEnabled: true,
        reminderHour: 8,
        reminderMinute: 15,
        reminderTitle: 'Check in',
        reminderBody: 'Notice.',
        coinStyle: CoinStyle.dime,
        themeMode: AppThemeMode.dark,
      );

      final copy = base.copyWith(soundEnabled: true);

      expect(copy.dailyCoinCount, 7);
      expect(copy.hapticsEnabled, false);
      expect(copy.soundEnabled, true);
      expect(copy.coinStyle, CoinStyle.dime);
      expect(copy.themeMode, AppThemeMode.dark);
    });

    test('equality holds for identical values', () {
      const a = AppSettings.defaults();
      const b = AppSettings.defaults();

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('equality fails when any field differs', () {
      const a = AppSettings.defaults();
      final b = a.copyWith(dailyCoinCount: 5);

      expect(a, isNot(equals(b)));
    });

    test('fromJson handles missing optional fields with defaults', () {
      final settings = AppSettings.fromJson(const {'dailyCoinCount': 10});

      expect(settings.hapticsEnabled, isTrue);
      expect(settings.soundEnabled, isTrue);
      expect(settings.coinStyle, CoinStyle.penny);
      expect(settings.themeMode, AppThemeMode.system);
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
        reminderTitle: 'Pocket check',
        reminderBody: 'Pause for one breath and notice the day.',
        coinStyle: CoinStyle.dime,
        themeMode: AppThemeMode.system,
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

    test('returns defaults when stored JSON is corrupted', () async {
      final store = InMemoryKeyValueStore();
      await store.setString('app_settings', 'this is not valid json {{{');

      final loaded = await SettingsRepository(store).load();

      expect(loaded, const AppSettings.defaults());
    });
  });
}
