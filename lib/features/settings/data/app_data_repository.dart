import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/key_value_store.dart';
import '../../../core/utils/clock.dart';
import '../../game/data/session_repository.dart';
import '../../onboarding/data/onboarding_repository.dart';
import 'settings_repository.dart';
import '../domain/app_export_bundle.dart';

final appDataRepositoryProvider = Provider<AppDataRepository>(
  (ref) => AppDataRepository(
    store: ref.watch(keyValueStoreProvider),
    settingsRepository: ref.watch(settingsRepositoryProvider),
    sessionRepository: ref.watch(sessionRepositoryProvider),
    onboardingRepository: ref.watch(onboardingRepositoryProvider),
    clock: ref.watch(clockProvider),
  ),
);

class AppDataRepository {
  AppDataRepository({
    required KeyValueStore store,
    required SettingsRepository settingsRepository,
    required SessionRepository sessionRepository,
    required OnboardingRepository onboardingRepository,
    required DateTime Function() clock,
  }) : _store = store,
       _settingsRepository = settingsRepository,
       _sessionRepository = sessionRepository,
       _onboardingRepository = onboardingRepository,
       _clock = clock;

  final KeyValueStore _store;
  final SettingsRepository _settingsRepository;
  final SessionRepository _sessionRepository;
  final OnboardingRepository _onboardingRepository;
  final DateTime Function() _clock;

  Future<AppExportBundle> buildExportBundle() async {
    final settings = await _settingsRepository.load();
    final currentSession = await _sessionRepository.loadCurrentSession();
    final history = await _sessionRepository.loadHistory();
    final onboardingComplete = await _onboardingRepository.isComplete();

    return AppExportBundle(
      exportedAt: _clock().toUtc(),
      settings: settings,
      currentSession: currentSession,
      history: history,
      onboardingComplete: onboardingComplete,
    );
  }

  Future<void> resetProgressOnly() async {
    await _store.remove(AppConstants.currentSessionKey);
    await _store.remove(AppConstants.historyKey);
  }

  Future<void> resetEverything() async {
    await _store.remove(AppConstants.currentSessionKey);
    await _store.remove(AppConstants.historyKey);
    await _store.remove(AppConstants.settingsKey);
    await _store.remove(AppConstants.onboardingCompleteKey);
  }
}
