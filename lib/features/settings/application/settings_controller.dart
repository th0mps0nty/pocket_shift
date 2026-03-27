import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/notification_service.dart';
import '../data/settings_repository.dart';
import '../domain/app_settings.dart';
import '../domain/coin_style.dart';

final settingsControllerProvider = AsyncNotifierProvider<SettingsController, AppSettings>(SettingsController.new);

class SettingsController extends AsyncNotifier<AppSettings> {
  @override
  Future<AppSettings> build() async {
    final repository = ref.read(settingsRepositoryProvider);
    final notificationService = ref.read(notificationServiceProvider);

    final settings = await repository.load();
    await notificationService.syncDailyReminder(settings);
    return settings;
  }

  Future<void> updateDailyCoinCount(int value) async {
    await _persist((current) => current.copyWith(dailyCoinCount: value));
  }

  Future<void> setHapticsEnabled(bool enabled) async {
    await _persist((current) => current.copyWith(hapticsEnabled: enabled));
  }

  Future<void> setSoundEnabled(bool enabled) async {
    await _persist((current) => current.copyWith(soundEnabled: enabled));
  }

  Future<void> setCoinStyle(CoinStyle style) async {
    await _persist((current) => current.copyWith(coinStyle: style));
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    await _persist((current) => current.copyWith(themeMode: mode));
  }

  Future<void> setRemindersEnabled(bool enabled) async {
    await _persist((current) => current.copyWith(remindersEnabled: enabled));
  }

  Future<void> updateReminderTime({required int hour, required int minute}) async {
    await _persist((current) => current.copyWith(reminderHour: hour, reminderMinute: minute));
  }

  Future<void> updateReminderCopy({required String title, required String body}) async {
    await _persist((current) => current.copyWith(reminderTitle: title, reminderBody: body));
  }

  Future<void> resetReminderCopy() async {
    await _persist(
      (current) => current.copyWith(
        reminderTitle: AppConstants.defaultReminderTitle,
        reminderBody: AppConstants.defaultReminderBody,
      ),
    );
  }

  Future<void> _persist(AppSettings Function(AppSettings current) update) async {
    final repository = ref.read(settingsRepositoryProvider);
    final notificationService = ref.read(notificationServiceProvider);
    final current = state.valueOrNull ?? await future;
    final next = update(current);

    state = AsyncData(next);
    await repository.save(next);
    await notificationService.syncDailyReminder(next);
  }
}
