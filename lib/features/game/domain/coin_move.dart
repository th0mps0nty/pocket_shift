class CoinMove {
  const CoinMove({
    required this.timestamp,
    required this.direction,
    this.reason,
  });

  final DateTime timestamp;
  final CoinDirection direction;
  final String? reason;

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'direction': direction.name,
      'reason': reason,
    };
  }

  factory CoinMove.fromJson(Map<String, dynamic> json) {
    final directionName = json['direction'] as String? ?? CoinDirection.leftToRight.name;

    return CoinMove(
      timestamp: DateTime.parse(json['timestamp'] as String),
      direction: CoinDirection.values.firstWhere(
        (value) => value.name == directionName,
        orElse: () => CoinDirection.leftToRight,
      ),
      reason: json['reason'] as String?,
    );
  }
}

enum CoinDirection {
  leftToRight,
  rightToLeft,
}
