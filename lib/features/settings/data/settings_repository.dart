import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/key_value_store.dart';
import '../domain/app_settings.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepository(ref.watch(keyValueStoreProvider)),
);

class SettingsRepository {
  SettingsRepository(this._store);

  final KeyValueStore _store;

  Future<AppSettings> load() async {
    final raw = await _store.getString(AppConstants.settingsKey);
    if (raw == null || raw.isEmpty) {
      return const AppSettings.defaults();
    }

    try {
      return AppSettings.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return const AppSettings.defaults();
    }
  }

  Future<void> save(AppSettings settings) {
    return _store.setString(
      AppConstants.settingsKey,
      jsonEncode(settings.toJson()),
    );
  }
}
