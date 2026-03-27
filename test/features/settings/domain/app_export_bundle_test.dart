import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_shift/features/game/domain/daily_session.dart';
import 'package:pocket_shift/features/settings/domain/app_export_bundle.dart';
import 'package:pocket_shift/features/settings/domain/app_settings.dart';
import 'package:pocket_shift/features/settings/domain/coin_style.dart';

void main() {
  const baseSettings = AppSettings(
    dailyCoinCount: 10,
    hapticsEnabled: true,
    soundEnabled: true,
    remindersEnabled: false,
    reminderHour: 20,
    reminderMinute: 0,
    reminderTitle: 'Pocket Shift',
    reminderBody: 'Notice.',
    coinStyle: CoinStyle.penny,
    themeMode: AppThemeMode.system,
  );

  group('AppExportBundle', () {
    test('totalMoves sums moves from current session and history', () {
      final current = DailySession.fresh(
        now: DateTime(2026, 3, 22, 9),
        startingCoins: 10,
      ).moveOne(now: DateTime(2026, 3, 22, 10)).moveOne(now: DateTime(2026, 3, 22, 11));

      final historical = DailySession.fresh(
        now: DateTime(2026, 3, 21, 9),
        startingCoins: 10,
      ).moveOne(now: DateTime(2026, 3, 21, 10));

      final bundle = AppExportBundle(
        exportedAt: DateTime.utc(2026, 3, 22, 12),
        settings: baseSettings,
        currentSession: current,
        history: [historical],
        onboardingComplete: true,
      );

      expect(bundle.totalMoves, 3);
    });

    test('totalMoves is zero when no sessions', () {
      final bundle = AppExportBundle(
        exportedAt: DateTime.utc(2026, 3, 22, 12),
        settings: baseSettings,
        currentSession: null,
        history: const [],
        onboardingComplete: false,
      );

      expect(bundle.totalMoves, 0);
    });

    test('totalMoves counts history when currentSession is null', () {
      final historical = DailySession.fresh(now: DateTime(2026, 3, 21, 9), startingCoins: 5)
          .moveOne(now: DateTime(2026, 3, 21, 10))
          .moveOne(now: DateTime(2026, 3, 21, 11))
          .moveOne(now: DateTime(2026, 3, 21, 12));

      final bundle = AppExportBundle(
        exportedAt: DateTime.utc(2026, 3, 22, 12),
        settings: baseSettings,
        currentSession: null,
        history: [historical],
        onboardingComplete: true,
      );

      expect(bundle.totalMoves, 3);
    });

    test('sessionCount counts current session and history', () {
      final current = DailySession.fresh(now: DateTime(2026, 3, 22, 9), startingCoins: 10);
      final historical = DailySession.fresh(now: DateTime(2026, 3, 21, 9), startingCoins: 10);

      final bundle = AppExportBundle(
        exportedAt: DateTime.utc(2026, 3, 22, 12),
        settings: baseSettings,
        currentSession: current,
        history: [historical],
        onboardingComplete: true,
      );

      expect(bundle.sessionCount, 2);
    });

    test('sessionCount is 0 when there are no sessions at all', () {
      final bundle = AppExportBundle(
        exportedAt: DateTime.utc(2026, 3, 22, 12),
        settings: baseSettings,
        currentSession: null,
        history: const [],
        onboardingComplete: false,
      );

      expect(bundle.sessionCount, 0);
    });

    test('sessionCount excludes null currentSession', () {
      final historical = DailySession.fresh(now: DateTime(2026, 3, 21, 9), startingCoins: 10);

      final bundle = AppExportBundle(
        exportedAt: DateTime.utc(2026, 3, 22, 12),
        settings: baseSettings,
        currentSession: null,
        history: [historical],
        onboardingComplete: true,
      );

      expect(bundle.sessionCount, 1);
    });

    test('toJson includes schemaVersion, exportedAt, and onboardingComplete', () {
      final bundle = AppExportBundle(
        exportedAt: DateTime.utc(2026, 3, 22, 12),
        settings: baseSettings,
        currentSession: null,
        history: const [],
        onboardingComplete: false,
      );

      final json = bundle.toJson();

      expect(json['schemaVersion'], 1);
      expect(json['exportedAt'], isA<String>());
      expect(json['onboardingComplete'], isFalse);
      expect(json['settings'], isA<Map>());
      expect(json['history'], isA<List>());
    });

    test('toPrettyJson produces indented output containing key fields', () {
      final bundle = AppExportBundle(
        exportedAt: DateTime.utc(2026, 3, 22, 12),
        settings: baseSettings,
        currentSession: null,
        history: const [],
        onboardingComplete: true,
      );

      final pretty = bundle.toPrettyJson();

      expect(pretty, contains('  ')); // indented
      expect(pretty, contains('schemaVersion'));
      expect(pretty, contains('onboardingComplete'));
    });
  });
}
