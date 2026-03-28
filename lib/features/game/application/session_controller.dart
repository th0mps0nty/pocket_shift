import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/clock.dart';
import '../../settings/application/settings_controller.dart';
import '../data/session_repository.dart';
import '../domain/daily_session.dart';
import '../domain/trigger_tag.dart';

final sessionControllerProvider = AsyncNotifierProvider<SessionController, DailySession>(SessionController.new);

class SessionController extends AsyncNotifier<DailySession> {
  @override
  Future<DailySession> build() async {
    final repository = ref.read(sessionRepositoryProvider);
    final clock = ref.read(clockProvider);
    final dailyCoinCount = await ref.watch(settingsControllerProvider.selectAsync((s) => s.dailyCoinCount));
    return repository.ensureCurrentSession(now: clock(), dailyCoinCount: dailyCoinCount);
  }

  Future<void> refreshForToday() async {
    final repository = ref.read(sessionRepositoryProvider);
    final clock = ref.read(clockProvider);
    final settings = await ref.read(settingsControllerProvider.future);
    final session = await repository.ensureCurrentSession(now: clock(), dailyCoinCount: settings.dailyCoinCount);

    state = AsyncData(session);
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
    return true;
  }

  Future<bool> annotateLastMove({
    TriggerTag? triggerTag,
    String? note,
  }) async {
    await refreshForToday();
    final repository = ref.read(sessionRepositoryProvider);
    final clock = ref.read(clockProvider);
    final current = state.valueOrNull ?? await future;
    if (current.moves.isEmpty) {
      return false;
    }

    final next = current.annotateLastMove(
      now: clock(),
      triggerTag: triggerTag,
      note: note,
    );
    state = AsyncData(next);
    await repository.saveCurrentSession(next);
    return true;
  }

  Future<void> saveReflection({
    String? whatShowedUp,
    String? whatHelped,
    String? forTomorrow,
  }) async {
    await refreshForToday();
    final repository = ref.read(sessionRepositoryProvider);
    final clock = ref.read(clockProvider);
    final current = state.valueOrNull ?? await future;
    final next = current.saveReflection(
      now: clock(),
      whatShowedUp: whatShowedUp,
      whatHelped: whatHelped,
      forTomorrow: forTomorrow,
    );

    state = AsyncData(next);
    await repository.saveCurrentSession(next);
  }
}
