import '../../../core/constants/app_constants.dart';
import 'coin_style.dart';

enum AppThemeMode {
  system,
  light,
  dark;

  String get storageValue => name;

  static AppThemeMode fromStorageValue(String? value) {
    return AppThemeMode.values.where((m) => m.name == value).firstOrNull ?? AppThemeMode.system;
  }
}

class AppSettings {
  const AppSettings({
    required this.dailyCoinCount,
    required this.hapticsEnabled,
    required this.soundEnabled,
    required this.remindersEnabled,
    required this.reminderHour,
    required this.reminderMinute,
    required this.reminderTitle,
    required this.reminderBody,
    required this.coinStyle,
    required this.themeMode,
  });

  const AppSettings.defaults()
    : dailyCoinCount = AppConstants.defaultDailyCoinCount,
      hapticsEnabled = true,
      soundEnabled = true,
      remindersEnabled = false,
      reminderHour = 20,
      reminderMinute = 0,
      reminderTitle = AppConstants.defaultReminderTitle,
      reminderBody = AppConstants.defaultReminderBody,
      coinStyle = CoinStyle.penny,
      themeMode = AppThemeMode.system;

  final int dailyCoinCount;
  final bool hapticsEnabled;
  final bool soundEnabled;
  final bool remindersEnabled;
  final int reminderHour;
  final int reminderMinute;
  final String reminderTitle;
  final String reminderBody;
  final CoinStyle coinStyle;
  final AppThemeMode themeMode;

  AppSettings copyWith({
    int? dailyCoinCount,
    bool? hapticsEnabled,
    bool? soundEnabled,
    bool? remindersEnabled,
    int? reminderHour,
    int? reminderMinute,
    String? reminderTitle,
    String? reminderBody,
    CoinStyle? coinStyle,
    AppThemeMode? themeMode,
  }) {
    return AppSettings(
      dailyCoinCount: (dailyCoinCount ?? this.dailyCoinCount).clamp(
        AppConstants.minDailyCoinCount,
        AppConstants.maxDailyCoinCount,
      ),
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      remindersEnabled: remindersEnabled ?? this.remindersEnabled,
      reminderHour: reminderHour ?? this.reminderHour,
      reminderMinute: reminderMinute ?? this.reminderMinute,
      reminderTitle: _normalizedCopy(
        reminderTitle,
        fallback: this.reminderTitle,
        defaultValue: AppConstants.defaultReminderTitle,
      ),
      reminderBody: _normalizedCopy(
        reminderBody,
        fallback: this.reminderBody,
        defaultValue: AppConstants.defaultReminderBody,
      ),
      coinStyle: coinStyle ?? this.coinStyle,
      themeMode: themeMode ?? this.themeMode,
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
      'reminderTitle': reminderTitle,
      'reminderBody': reminderBody,
      'coinStyle': coinStyle.storageValue,
      'themeMode': themeMode.storageValue,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      dailyCoinCount:
          (json['dailyCoinCount'] as num?)?.toInt().clamp(
            AppConstants.minDailyCoinCount,
            AppConstants.maxDailyCoinCount,
          ) ??
          AppConstants.defaultDailyCoinCount,
      hapticsEnabled: json['hapticsEnabled'] as bool? ?? true,
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      remindersEnabled: json['remindersEnabled'] as bool? ?? false,
      reminderHour: (json['reminderHour'] as num?)?.toInt() ?? 20,
      reminderMinute: (json['reminderMinute'] as num?)?.toInt() ?? 0,
      reminderTitle: _normalizedStored(json['reminderTitle'] as String?, AppConstants.defaultReminderTitle),
      reminderBody: _normalizedStored(json['reminderBody'] as String?, AppConstants.defaultReminderBody),
      coinStyle: CoinStyleX.fromStorageValue(json['coinStyle'] as String?),
      themeMode: AppThemeMode.fromStorageValue(json['themeMode'] as String?),
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
        other.reminderTitle == reminderTitle &&
        other.reminderBody == reminderBody &&
        other.coinStyle == coinStyle &&
        other.themeMode == themeMode;
  }

  @override
  int get hashCode => Object.hash(
    dailyCoinCount,
    hapticsEnabled,
    soundEnabled,
    remindersEnabled,
    reminderHour,
    reminderMinute,
    reminderTitle,
    reminderBody,
    coinStyle,
    themeMode,
  );
}

String _normalizedCopy(String? value, {required String fallback, required String defaultValue}) {
  if (value == null) {
    return fallback;
  }
  return _normalizedStored(value, defaultValue);
}

String _normalizedStored(String? value, String defaultValue) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return defaultValue;
  }
  return trimmed;
}
