import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_shift/features/game/domain/coin_move.dart';

void main() {
  group('CoinMove', () {
    test('serializes and deserializes cleanly with a reason', () {
      final now = DateTime(2026, 3, 22, 9, 30);
      final move = CoinMove(
        id: 'move-1',
        timestamp: now,
        direction: CoinDirection.leftToRight,
        reason: 'morning habit',
      );

      final roundTrip = CoinMove.fromJson(move.toJson());

      expect(roundTrip.timestamp, move.timestamp);
      expect(roundTrip.direction, CoinDirection.leftToRight);
      expect(roundTrip.reason, 'morning habit');
    });

    test('serializes and deserializes cleanly without a reason', () {
      final now = DateTime(2026, 3, 22, 9, 30);
      final move = CoinMove(id: 'move-1', timestamp: now, direction: CoinDirection.leftToRight);

      final roundTrip = CoinMove.fromJson(move.toJson());

      expect(roundTrip.reason, isNull);
    });

    test('fromJson falls back to leftToRight for unknown direction', () {
      final move = CoinMove.fromJson({
        'timestamp': DateTime(2026, 3, 22, 9, 30).toIso8601String(),
        'direction': 'unknown_value',
      });

      expect(move.direction, CoinDirection.leftToRight);
    });

    test('fromJson falls back to leftToRight when direction key is missing', () {
      final move = CoinMove.fromJson({'timestamp': DateTime(2026, 3, 22, 9, 30).toIso8601String()});

      expect(move.direction, CoinDirection.leftToRight);
    });

    test('toJson includes all fields', () {
      final now = DateTime(2026, 3, 22, 9, 30);
      final move = CoinMove(id: 'move-1', timestamp: now, direction: CoinDirection.leftToRight, reason: 'a reason');

      final json = move.toJson();

      expect(json['id'], 'move-1');
      expect(json['timestamp'], isA<String>());
      expect(json['direction'], 'leftToRight');
      expect(json['reason'], 'a reason');
    });
  });
}
