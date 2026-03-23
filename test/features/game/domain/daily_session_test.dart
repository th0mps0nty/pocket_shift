import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_shift/features/game/domain/daily_session.dart';

void main() {
  group('DailySession', () {
    test('moveOne increments moved coins and appends a move', () {
      final now = DateTime(2026, 3, 22, 9);
      final session = DailySession.fresh(now: now, startingCoins: 10);

      final updated = session.moveOne(now: now.add(const Duration(minutes: 1)));

      expect(updated.movedCoins, 1);
      expect(updated.remainingCoins, 9);
      expect(updated.moves, hasLength(1));
    });

    test('undoLastMove removes only the most recent move', () {
      final now = DateTime(2026, 3, 22, 9);
      final session = DailySession.fresh(now: now, startingCoins: 10)
          .moveOne(now: now.add(const Duration(minutes: 1)))
          .moveOne(now: now.add(const Duration(minutes: 2)));

      final updated = session.undoLastMove(
        now: now.add(const Duration(minutes: 3)),
      );

      expect(updated, isNotNull);
      expect(updated!.movedCoins, 1);
      expect(updated.remainingCoins, 9);
      expect(updated.moves, hasLength(1));
    });

    test('remainingCoins never goes below zero', () {
      final now = DateTime(2026, 3, 22, 9);
      var session = DailySession.fresh(now: now, startingCoins: 2);

      session = session.moveOne(now: now.add(const Duration(minutes: 1)));
      session = session.moveOne(now: now.add(const Duration(minutes: 2)));
      session = session.moveOne(now: now.add(const Duration(minutes: 3)));

      expect(session.movedCoins, 2);
      expect(session.remainingCoins, 0);
      expect(session.canMoveCoin, isFalse);
    });
  });
}
