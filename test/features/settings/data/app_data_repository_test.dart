import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_shift/features/game/data/session_repository.dart';
import 'package:pocket_shift/features/game/domain/daily_session.dart';
import 'package:pocket_shift/features/onboarding/data/onboarding_repository.dart';
import 'package:pocket_shift/features/settings/data/app_data_repository.dart';
import 'package:pocket_shift/features/settings/data/settings_repository.dart';
import 'package:pocket_shift/features/settings/domain/app_settings.dart';
import 'package:pocket_shift/features/settings/domain/coin_style.dart';

import '../../../helpers/in_memory_key_value_store.dart';

void main() {
  group('AppDataRepository', () {
    test('builds an export bundle with settings, current session, and history', () async {
      final store = InMemoryKeyValueStore();
      final settingsRepository = SettingsRepository(store);
      final sessionRepository = SessionRepository(store);
      final onboardingRepository = OnboardingRepository(store);
      final repository = AppDataRepository(
        store: store,
        settingsRepository: settingsRepository,
        sessionRepository: sessionRepository,
        onboardingRepository: onboardingRepository,
        clock: () => DateTime.utc(2026, 3, 23, 12),
      );

      await settingsRepository.save(
        const AppSettings(
          dailyCoinCount: 12,
          hapticsEnabled: true,
          soundEnabled: true,
          remindersEnabled: true,
          reminderHour: 8,
          reminderMinute: 30,
          reminderTitle: 'Pocket check',
          reminderBody: 'Notice what pocket the day is in.',
          coinStyle: CoinStyle.nickel,
          themeMode: AppThemeMode.system,
        ),
      );
      await onboardingRepository.markComplete();

      final currentSession = DailySession.fresh(
        now: DateTime.utc(2026, 3, 23, 12),
        startingCoins: 12,
      ).moveOne(now: DateTime.utc(2026, 3, 23, 13));
      await sessionRepository.saveCurrentSession(currentSession);
      await sessionRepository.archiveSession(
        DailySession.fresh(
          now: DateTime.utc(2026, 3, 22, 12),
          startingCoins: 10,
        ).moveOne(now: DateTime.utc(2026, 3, 22, 13)).close(now: DateTime.utc(2026, 3, 22, 22)),
      );

      final bundle = await repository.buildExportBundle();

      expect(bundle.settings.dailyCoinCount, 12);
      expect(bundle.currentSession?.movedCoins, 1);
      expect(bundle.history.length, 1);
      expect(bundle.onboardingComplete, isTrue);
      expect(bundle.totalMoves, 2);
    });

    test('resetProgressOnly clears sessions and preserves settings', () async {
      final store = InMemoryKeyValueStore();
      final settingsRepository = SettingsRepository(store);
      final sessionRepository = SessionRepository(store);
      final onboardingRepository = OnboardingRepository(store);
      final repository = AppDataRepository(
        store: store,
        settingsRepository: settingsRepository,
        sessionRepository: sessionRepository,
        onboardingRepository: onboardingRepository,
        clock: DateTime.now,
      );

      await settingsRepository.save(const AppSettings.defaults());
      await sessionRepository.saveCurrentSession(
        DailySession.fresh(now: DateTime.utc(2026, 3, 23, 12), startingCoins: 10),
      );
      await sessionRepository.archiveSession(DailySession.fresh(now: DateTime.utc(2026, 3, 22, 12), startingCoins: 10));

      await repository.resetProgressOnly();

      expect(await sessionRepository.loadCurrentSession(), isNull);
      expect(await sessionRepository.loadHistory(), isEmpty);
      expect(await settingsRepository.load(), const AppSettings.defaults());
    });

    test('resetEverything clears onboarding, settings, and history', () async {
      final store = InMemoryKeyValueStore();
      final settingsRepository = SettingsRepository(store);
      final sessionRepository = SessionRepository(store);
      final onboardingRepository = OnboardingRepository(store);
      final repository = AppDataRepository(
        store: store,
        settingsRepository: settingsRepository,
        sessionRepository: sessionRepository,
        onboardingRepository: onboardingRepository,
        clock: DateTime.now,
      );

      await settingsRepository.save(
        const AppSettings(
          dailyCoinCount: 6,
          hapticsEnabled: false,
          soundEnabled: false,
          remindersEnabled: true,
          reminderHour: 19,
          reminderMinute: 15,
          reminderTitle: 'Check in',
          reminderBody: 'Take stock of the day.',
          coinStyle: CoinStyle.quarter,
          themeMode: AppThemeMode.system,
        ),
      );
      await onboardingRepository.markComplete();
      await sessionRepository.saveCurrentSession(
        DailySession.fresh(now: DateTime.utc(2026, 3, 23, 12), startingCoins: 6),
      );
      await sessionRepository.archiveSession(DailySession.fresh(now: DateTime.utc(2026, 3, 22, 12), startingCoins: 6));

      await repository.resetEverything();

      expect(await onboardingRepository.isComplete(), isFalse);
      expect(await settingsRepository.load(), const AppSettings.defaults());
      expect(await sessionRepository.loadCurrentSession(), isNull);
      expect(await sessionRepository.loadHistory(), isEmpty);
    });
  });
}
