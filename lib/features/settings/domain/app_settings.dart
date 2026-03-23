import '../../../core/constants/app_constants.dart';
import 'coin_style.dart';

class AppSettings {
  const AppSettings({
    required this.dailyCoinCount,
    required this.hapticsEnabled,
    required this.soundEnabled,
    required this.remindersEnabled,
    required this.reminderHour,
    required this.reminderMinute,
    required this.coinStyle,
  });

  const AppSettings.defaults()
      : dailyCoinCount = AppConstants.defaultDailyCoinCount,
        hapticsEnabled = true,
        soundEnabled = true,
        remindersEnabled = false,
        reminderHour = 20,
        reminderMinute = 0,
        coinStyle = CoinStyle.penny;

  final int dailyCoinCount;
  final bool hapticsEnabled;
  final bool soundEnabled;
  final bool remindersEnabled;
  final int reminderHour;
  final int reminderMinute;
  final CoinStyle coinStyle;

  AppSettings copyWith({
    int? dailyCoinCount,
    bool? hapticsEnabled,
    bool? soundEnabled,
    bool? remindersEnabled,
    int? reminderHour,
    int? reminderMinute,
    CoinStyle? coinStyle,
  }) {
    return AppSettings(
      dailyCoinCount: (dailyCoinCount ?? this.dailyCoinCount)
          .clamp(AppConstants.minDailyCoinCount, AppConstants.maxDailyCoinCount),
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      remindersEnabled: remindersEnabled ?? this.remindersEnabled,
      reminderHour: reminderHour ?? this.reminderHour,
      reminderMinute: reminderMinute ?? this.reminderMinute,
      coinStyle: coinStyle ?? this.coinStyle,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dailyCoinCount': dailyCoinCount,
      'hapticsEnabled': hapticsEnabled,
      'soundEnabled': soundEnabled,
      'remindersEnabled': remindersEnabled,
      'reminderHour': reminderHour,
      'reminderMinute': reminderMinute,
      'coinStyle': coinStyle.storageValue,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      dailyCoinCount: (json['dailyCoinCount'] as num?)
              ?.toInt()
              .clamp(AppConstants.minDailyCoinCount, AppConstants.maxDailyCoinCount) ??
          AppConstants.defaultDailyCoinCount,
      hapticsEnabled: json['hapticsEnabled'] as bool? ?? true,
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      remindersEnabled: json['remindersEnabled'] as bool? ?? false,
      reminderHour: (json['reminderHour'] as num?)?.toInt() ?? 20,
      reminderMinute: (json['reminderMinute'] as num?)?.toInt() ?? 0,
      coinStyle: CoinStyleX.fromStorageValue(json['coinStyle'] as String?),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is AppSettings &&
        other.dailyCoinCount == dailyCoinCount &&
        other.hapticsEnabled == hapticsEnabled &&
        other.soundEnabled == soundEnabled &&
        other.remindersEnabled == remindersEnabled &&
        other.reminderHour == reminderHour &&
        other.reminderMinute == reminderMinute &&
        other.coinStyle == coinStyle;
  }

  @override
  int get hashCode => Object.hash(
        dailyCoinCount,
        hapticsEnabled,
        soundEnabled,
        remindersEnabled,
        reminderHour,
        reminderMinute,
        coinStyle,
      );
}
