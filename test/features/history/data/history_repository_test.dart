import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_shift/features/game/data/session_repository.dart';
import 'package:pocket_shift/features/game/domain/daily_session.dart';
import 'package:pocket_shift/features/history/data/history_repository.dart';

import '../../../helpers/in_memory_key_value_store.dart';

void main() {
  group('HistoryRepository', () {
    test('loadTimeline marks the current session as isCurrent', () async {
      final store = InMemoryKeyValueStore();
      final sessionRepository = SessionRepository(store);
      final repository = HistoryRepository(sessionRepository);

      final currentSession = await sessionRepository.ensureCurrentSession(
        now: DateTime(2026, 3, 22, 9),
        dailyCoinCount: 10,
      );

      final timeline = await repository.loadTimeline(currentSession: currentSession);

      expect(timeline, hasLength(1));
      expect(timeline.first.isCurrent, isTrue);
      expect(timeline.first.session.date, '2026-03-22');
    });

    test('loadTimeline prepends current session before archived sessions', () async {
      final store = InMemoryKeyValueStore();
      final sessionRepository = SessionRepository(store);
      final repository = HistoryRepository(sessionRepository);

      await sessionRepository.archiveSession(
        DailySession.fresh(now: DateTime(2026, 3, 21, 9), startingCoins: 10).close(now: DateTime(2026, 3, 21, 22)),
      );

      final currentSession = await sessionRepository.ensureCurrentSession(
        now: DateTime(2026, 3, 22, 9),
        dailyCoinCount: 10,
      );

      final timeline = await repository.loadTimeline(currentSession: currentSession);

      expect(timeline, hasLength(2));
      expect(timeline[0].isCurrent, isTrue);
      expect(timeline[0].session.date, '2026-03-22');
      expect(timeline[1].isCurrent, isFalse);
      expect(timeline[1].session.date, '2026-03-21');
    });

    test('archived sessions are marked as not current', () async {
      final store = InMemoryKeyValueStore();
      final sessionRepository = SessionRepository(store);
      final repository = HistoryRepository(sessionRepository);

      await sessionRepository.archiveSession(
        DailySession.fresh(now: DateTime(2026, 3, 20, 9), startingCoins: 8).close(now: DateTime(2026, 3, 20, 22)),
      );
      await sessionRepository.archiveSession(
        DailySession.fresh(now: DateTime(2026, 3, 21, 9), startingCoins: 10).close(now: DateTime(2026, 3, 21, 22)),
      );

      final currentSession = await sessionRepository.ensureCurrentSession(
        now: DateTime(2026, 3, 22, 9),
        dailyCoinCount: 10,
      );

      final timeline = await repository.loadTimeline(currentSession: currentSession);

      expect(timeline, hasLength(3));
      for (final item in timeline.skip(1)) {
        expect(item.isCurrent, isFalse);
      }
    });

    test('loadTimeline contains only current when history is empty', () async {
      final store = InMemoryKeyValueStore();
      final sessionRepository = SessionRepository(store);
      final repository = HistoryRepository(sessionRepository);

      final currentSession = DailySession.fresh(now: DateTime(2026, 3, 22, 9), startingCoins: 10);

      final timeline = await repository.loadTimeline(currentSession: currentSession);

      expect(timeline, hasLength(1));
      expect(timeline.first.isCurrent, isTrue);
    });
  });
}
