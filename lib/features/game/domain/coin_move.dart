import 'trigger_tag.dart';

class CoinMove {
  const CoinMove({
    required this.id,
    required this.timestamp,
    required this.direction,
    this.triggerTag,
    String? note,
    @Deprecated('Use note instead.') String? reason,
  }) : note = note ?? reason;

  final String id;
  final DateTime timestamp;
  final CoinDirection direction;
  final TriggerTag? triggerTag;
  final String? note;

  @Deprecated('Use note instead.')
  String? get reason => note;

  CoinMove copyWith({
    String? id,
    DateTime? timestamp,
    CoinDirection? direction,
    Object? triggerTag = _sentinel,
    Object? note = _sentinel,
  }) {
    return CoinMove(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      direction: direction ?? this.direction,
      triggerTag: triggerTag == _sentinel ? this.triggerTag : triggerTag as TriggerTag?,
      note: note == _sentinel ? this.note : note as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'direction': direction.name,
      'triggerTag': triggerTag?.storageValue,
      'note': note,
      'reason': note,
    };
  }

  factory CoinMove.fromJson(Map<String, dynamic> json) {
    final directionName =
        json['direction'] as String? ?? CoinDirection.leftToRight.name;

    return CoinMove(
      id: json['id'] as String? ?? 'move-${DateTime.parse(json['timestamp'] as String).microsecondsSinceEpoch}',
      timestamp: DateTime.parse(json['timestamp'] as String),
      direction: CoinDirection.values.firstWhere(
        (value) => value.name == directionName,
        orElse: () => CoinDirection.leftToRight,
      ),
      triggerTag: TriggerTagX.fromStorageValue(json['triggerTag'] as String?),
      note: json['note'] as String? ?? json['reason'] as String?,
    );
  }
}

enum CoinDirection { leftToRight, rightToLeft }

const Object _sentinel = Object();
