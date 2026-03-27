import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_shift/features/game/domain/coin_move.dart';
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

    test('moveOne records an optional reason on the move', () {
      final now = DateTime(2026, 3, 22, 9);
      final session = DailySession.fresh(now: now, startingCoins: 10);

      final updated = session.moveOne(now: now.add(const Duration(minutes: 1)), reason: 'noticed the shift');

      expect(updated.moves.first.reason, 'noticed the shift');
    });

    test('moveOne is a no-op when no coins remain', () {
      final now = DateTime(2026, 3, 22, 9);
      final full = DailySession.fresh(now: now, startingCoins: 1).moveOne(now: now.add(const Duration(minutes: 1)));

      final attempted = full.moveOne(now: now.add(const Duration(minutes: 2)));

      expect(attempted.movedCoins, 1);
      expect(attempted.moves, hasLength(1));
    });

    test('undoLastMove removes only the most recent move', () {
      final now = DateTime(2026, 3, 22, 9);
      final session = DailySession.fresh(
        now: now,
        startingCoins: 10,
      ).moveOne(now: now.add(const Duration(minutes: 1))).moveOne(now: now.add(const Duration(minutes: 2)));

      final updated = session.undoLastMove(now: now.add(const Duration(minutes: 3)));

      expect(updated, isNotNull);
      expect(updated!.movedCoins, 1);
      expect(updated.remainingCoins, 9);
      expect(updated.moves, hasLength(1));
    });

    test('undoLastMove returns null when there are no moves to undo', () {
      final now = DateTime(2026, 3, 22, 9);
      final fresh = DailySession.fresh(now: now, startingCoins: 10);

      expect(fresh.undoLastMove(now: now), isNull);
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

    test('canUndo is false on a fresh session and true after a move', () {
      final now = DateTime(2026, 3, 22, 9);
      final fresh = DailySession.fresh(now: now, startingCoins: 10);
      expect(fresh.canUndo, isFalse);

      final moved = fresh.moveOne(now: now.add(const Duration(minutes: 1)));
      expect(moved.canUndo, isTrue);
    });

    test('close sets endedAt', () {
      final now = DateTime(2026, 3, 22, 9);
      final session = DailySession.fresh(now: now, startingCoins: 10);
      final closeTime = DateTime(2026, 3, 22, 22);

      final closed = session.close(now: closeTime);

      expect(closed.endedAt, closeTime);
    });

    test('close does not overwrite an existing endedAt', () {
      final now = DateTime(2026, 3, 22, 9);
      final firstClose = DateTime(2026, 3, 22, 20);
      final secondClose = DateTime(2026, 3, 22, 22);

      final closed = DailySession.fresh(now: now, startingCoins: 10).close(now: firstClose).close(now: secondClose);

      expect(closed.endedAt, firstClose);
    });

    test('fresh creates a session dated to the provided date', () {
      final now = DateTime(2026, 3, 22, 14, 30);
      final session = DailySession.fresh(now: now, startingCoins: 5);

      expect(session.date, '2026-03-22');
      expect(session.startingCoins, 5);
      expect(session.movedCoins, 0);
      expect(session.endedAt, isNull);
      expect(session.moves, isEmpty);
    });

    test('toJson and fromJson round-trip with moves', () {
      final now = DateTime(2026, 3, 22, 9);
      final session = DailySession.fresh(now: now, startingCoins: 10)
          .moveOne(now: now.add(const Duration(minutes: 1)), reason: 'shift')
          .moveOne(now: now.add(const Duration(minutes: 2)));

      final roundTrip = DailySession.fromJson(session.toJson());

      expect(roundTrip.id, session.id);
      expect(roundTrip.date, session.date);
      expect(roundTrip.startingCoins, session.startingCoins);
      expect(roundTrip.movedCoins, session.movedCoins);
      expect(roundTrip.moves, hasLength(2));
      expect(roundTrip.moves.first.reason, 'shift');
      expect(roundTrip.moves.first.direction, CoinDirection.leftToRight);
    });

    test('toJson and fromJson round-trip with endedAt', () {
      final now = DateTime(2026, 3, 22, 9);
      final closed = DailySession.fresh(now: now, startingCoins: 10).close(now: DateTime(2026, 3, 22, 22));

      final roundTrip = DailySession.fromJson(closed.toJson());

      expect(roundTrip.endedAt, closed.endedAt);
    });
  });
}
