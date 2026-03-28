class DailyReflection {
  const DailyReflection({
    this.whatShowedUp,
    this.whatHelped,
    this.forTomorrow,
    required this.completedAt,
  });

  final String? whatShowedUp;
  final String? whatHelped;
  final String? forTomorrow;
  final DateTime completedAt;

  bool get hasContent =>
      _normalized(whatShowedUp) != null ||
      _normalized(whatHelped) != null ||
      _normalized(forTomorrow) != null;

  DailyReflection copyWith({
    String? whatShowedUp,
    String? whatHelped,
    String? forTomorrow,
    DateTime? completedAt,
  }) {
    return DailyReflection(
      whatShowedUp: _normalized(whatShowedUp),
      whatHelped: _normalized(whatHelped),
      forTomorrow: _normalized(forTomorrow),
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'whatShowedUp': whatShowedUp,
      'whatHelped': whatHelped,
      'forTomorrow': forTomorrow,
      'completedAt': completedAt.toIso8601String(),
    };
  }

  factory DailyReflection.fromJson(Map<String, dynamic> json) {
    return DailyReflection(
      whatShowedUp: _normalized(json['whatShowedUp'] as String?),
      whatHelped: _normalized(json['whatHelped'] as String?),
      forTomorrow: _normalized(json['forTomorrow'] as String?),
      completedAt: DateTime.parse(json['completedAt'] as String),
    );
  }
}

String? _normalized(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return null;
  }
  return trimmed;
}
