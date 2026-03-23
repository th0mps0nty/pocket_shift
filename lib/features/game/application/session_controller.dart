import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/clock.dart';
import '../../history/application/history_controller.dart';
import '../../settings/application/settings_controller.dart';
import '../data/session_repository.dart';
import '../domain/daily_session.dart';

final sessionControllerProvider =
    AsyncNotifierProvider<SessionController, DailySession>(
      SessionController.new,
    );

class SessionController extends AsyncNotifier<DailySession> {
  @override
  Future<DailySession> build() async {
    final repository = ref.read(sessionRepositoryProvider);
    final clock = ref.read(clockProvider);
    final settings = await ref.watch(settingsControllerProvider.future);
    return repository.ensureCurrentSession(
      now: clock(),
      dailyCoinCount: settings.dailyCoinCount,
    );
  }

  Future<void> refreshForToday() async {
    final repository = ref.read(sessionRepositoryProvider);
    final clock = ref.read(clockProvider);
    final settings = await ref.read(settingsControllerProvider.future);
    final session = await repository.ensureCurrentSession(
      now: clock(),
      dailyCoinCount: settings.dailyCoinCount,
    );

    state = AsyncData(session);
    ref.invalidate(historyTimelineProvider);
  }

  Future<bool> moveCoin({String? reason}) async {
    await refreshForToday();
    final repository = ref.read(sessionRepositoryProvider);
    final clock = ref.read(clockProvider);
    final current = state.valueOrNull ?? await future;
    if (!current.canMoveCoin) {
      return false;
    }

    final next = current.moveOne(now: clock(), reason: reason);
    state = AsyncData(next);
    await repository.saveCurrentSession(next);
    ref.invalidate(historyTimelineProvider);
    return true;
  }

  Future<bool> undoLastMove() async {
    await refreshForToday();
    final repository = ref.read(sessionRepositoryProvider);
    final clock = ref.read(clockProvider);
    final current = state.valueOrNull ?? await future;
    final next = current.undoLastMove(now: clock());
    if (next == null) {
      return false;
    }

    state = AsyncData(next);
    await repository.saveCurrentSession(next);
    ref.invalidate(historyTimelineProvider);
    return true;
  }
}
