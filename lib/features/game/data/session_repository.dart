import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/key_value_store.dart';
import '../../../core/utils/date_utils.dart';
import '../domain/daily_session.dart';

final sessionRepositoryProvider = Provider<SessionRepository>(
  (ref) => SessionRepository(ref.watch(keyValueStoreProvider)),
);

class SessionRepository {
  SessionRepository(this._store);

  final KeyValueStore _store;

  Future<DailySession> ensureCurrentSession({
    required DateTime now,
    required int dailyCoinCount,
  }) async {
    final todayKey = PocketShiftDateUtils.dateKey(now);
    final current = await loadCurrentSession();

    if (current == null) {
      final fresh = DailySession.fresh(now: now, startingCoins: dailyCoinCount);
      await saveCurrentSession(fresh);
      return fresh;
    }

    if (current.date != todayKey) {
      await archiveSession(current.close(now: now));
      final fresh = DailySession.fresh(now: now, startingCoins: dailyCoinCount);
      await saveCurrentSession(fresh);
      return fresh;
    }

    return current;
  }

  Future<DailySession?> loadCurrentSession() async {
    final raw = await _store.getString(AppConstants.currentSessionKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }

    try {
      return DailySession.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveCurrentSession(DailySession session) {
    return _store.setString(
      AppConstants.currentSessionKey,
      jsonEncode(session.toJson()),
    );
  }

  Future<List<DailySession>> loadHistory() async {
    final raw = await _store.getString(AppConstants.historyKey);
    if (raw == null || raw.isEmpty) {
      return const [];
    }

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      final sessions = decoded
          .map((entry) => DailySession.fromJson(entry as Map<String, dynamic>))
          .toList();
      sessions.sort((a, b) => b.date.compareTo(a.date));
      return sessions;
    } catch (_) {
      return const [];
    }
  }

  Future<void> archiveSession(DailySession session) async {
    final history = await loadHistory();
    final updated = [
      session,
      ...history.where((item) => item.id != session.id),
    ];

    await _store.setString(
      AppConstants.historyKey,
      jsonEncode(updated.map((item) => item.toJson()).toList()),
    );
  }
}
