import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_shift/features/game/data/session_repository.dart';

import '../../../helpers/in_memory_key_value_store.dart';

void main() {
  group('SessionRepository', () {
    test('creates a fresh session when none exists', () async {
      final repository = SessionRepository(InMemoryKeyValueStore());
      final now = DateTime(2026, 3, 22, 8, 30);

      final session = await repository.ensureCurrentSession(
        now: now,
        dailyCoinCount: 10,
      );

      expect(session.startingCoins, 10);
      expect(session.remainingCoins, 10);
      expect(session.date, '2026-03-22');
    });

    test('archives yesterday and rolls over into a new session', () async {
      final store = InMemoryKeyValueStore();
      final repository = SessionRepository(store);
      final firstDay = DateTime(2026, 3, 22, 20);
      final secondDay = DateTime(2026, 3, 23, 7);

      final firstSession = await repository.ensureCurrentSession(
        now: firstDay,
        dailyCoinCount: 10,
      );
      await repository.saveCurrentSession(
        firstSession
            .moveOne(now: firstDay.add(const Duration(minutes: 1)))
            .moveOne(now: firstDay.add(const Duration(minutes: 2))),
      );

      final secondSession = await repository.ensureCurrentSession(
        now: secondDay,
        dailyCoinCount: 12,
      );
      final history = await repository.loadHistory();

      expect(secondSession.date, '2026-03-23');
      expect(secondSession.startingCoins, 12);
      expect(secondSession.movedCoins, 0);
      expect(history, hasLength(1));
      expect(history.first.date, '2026-03-22');
      expect(history.first.movedCoins, 2);
      expect(history.first.endedAt, isNotNull);
    });

    test('loadSessionById returns the current session when it matches', () async {
      final repository = SessionRepository(InMemoryKeyValueStore());
      final now = DateTime(2026, 3, 22, 8, 30);

      final session = await repository.ensureCurrentSession(
        now: now,
        dailyCoinCount: 10,
      );

      final loaded = await repository.loadSessionById(session.id);

      expect(loaded?.id, session.id);
    });

    test('updateHistorySession replaces a stored historical session', () async {
      final store = InMemoryKeyValueStore();
      final repository = SessionRepository(store);
      final firstDay = DateTime(2026, 3, 22, 20);
      final secondDay = DateTime(2026, 3, 23, 7);

      final firstSession = await repository.ensureCurrentSession(
        now: firstDay,
        dailyCoinCount: 10,
      );
      await repository.saveCurrentSession(
        firstSession.moveOne(now: firstDay.add(const Duration(minutes: 1))),
      );
      await repository.ensureCurrentSession(
        now: secondDay,
        dailyCoinCount: 10,
      );

      final history = await repository.loadHistory();
      final archived = history.first;
      final updated = archived.saveReflection(
        now: secondDay,
        whatShowedUp: 'I caught myself earlier.',
      );

      await repository.updateHistorySession(updated);
      final roundTrip = await repository.loadSessionById(archived.id);

      expect(roundTrip?.reflection?.whatShowedUp, 'I caught myself earlier.');
    });
  });
}
