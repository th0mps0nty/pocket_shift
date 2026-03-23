import 'dart:math';

import '../../../core/utils/date_utils.dart';
import 'coin_move.dart';

class DailySession {
  DailySession({
    required this.id,
    required this.date,
    required this.startingCoins,
    required this.movedCoins,
    required this.createdAt,
    required this.updatedAt,
    this.endedAt,
    List<CoinMove>? moves,
  }) : moves = List.unmodifiable(moves ?? const []);

  final String id;
  final String date;
  final int startingCoins;
  final int movedCoins;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? endedAt;
  final List<CoinMove> moves;

  int get remainingCoins => max(0, startingCoins - movedCoins);
  bool get canMoveCoin => remainingCoins > 0;
  bool get canUndo => moves.isNotEmpty;

  factory DailySession.fresh({
    required DateTime now,
    required int startingCoins,
  }) {
    final date = PocketShiftDateUtils.dateKey(now);
    return DailySession(
      id: 'session-$date-${now.microsecondsSinceEpoch}',
      date: date,
      startingCoins: startingCoins,
      movedCoins: 0,
      createdAt: now,
      updatedAt: now,
    );
  }

  DailySession copyWith({
    String? id,
    String? date,
    int? startingCoins,
    int? movedCoins,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? endedAt = _sentinel,
    List<CoinMove>? moves,
  }) {
    return DailySession(
      id: id ?? this.id,
      date: date ?? this.date,
      startingCoins: startingCoins ?? this.startingCoins,
      movedCoins: movedCoins ?? this.movedCoins,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      endedAt: endedAt == _sentinel ? this.endedAt : endedAt as DateTime?,
      moves: moves ?? this.moves,
    );
  }

  DailySession moveOne({required DateTime now, String? reason}) {
    if (!canMoveCoin) {
      return this;
    }

    final nextMoves = [
      ...moves,
      CoinMove(
        timestamp: now,
        direction: CoinDirection.leftToRight,
        reason: reason,
      ),
    ];

    return copyWith(
      movedCoins: movedCoins + 1,
      updatedAt: now,
      moves: nextMoves,
    );
  }

  DailySession? undoLastMove({required DateTime now}) {
    if (!canUndo || movedCoins <= 0) {
      return null;
    }

    return copyWith(
      movedCoins: movedCoins - 1,
      updatedAt: now,
      moves: moves.sublist(0, moves.length - 1),
    );
  }

  DailySession close({required DateTime now}) {
    return copyWith(updatedAt: now, endedAt: endedAt ?? now);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'startingCoins': startingCoins,
      'movedCoins': movedCoins,
      'remainingCoins': remainingCoins,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'endedAt': endedAt?.toIso8601String(),
      'moves': moves.map((move) => move.toJson()).toList(),
    };
  }

  factory DailySession.fromJson(Map<String, dynamic> json) {
    final rawMoves = json['moves'] as List<dynamic>? ?? const [];
    return DailySession(
      id: json['id'] as String,
      date: json['date'] as String,
      startingCoins: (json['startingCoins'] as num).toInt(),
      movedCoins: (json['movedCoins'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      endedAt: json['endedAt'] == null
          ? null
          : DateTime.parse(json['endedAt'] as String),
      moves: rawMoves
          .map((move) => CoinMove.fromJson(move as Map<String, dynamic>))
          .toList(),
    );
  }
}

const Object _sentinel = Object();
