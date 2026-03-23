import 'dart:convert';

import '../../game/domain/daily_session.dart';
import 'app_settings.dart';

class AppExportBundle {
  const AppExportBundle({
    required this.exportedAt,
    required this.settings,
    required this.currentSession,
    required this.history,
    required this.onboardingComplete,
  });

  final DateTime exportedAt;
  final AppSettings settings;
  final DailySession? currentSession;
  final List<DailySession> history;
  final bool onboardingComplete;

  int get totalMoves => [
    if (currentSession != null) currentSession!.movedCoins,
    ...history.map((session) => session.movedCoins),
  ].fold<int>(0, (sum, value) => sum + value);

  int get sessionCount => history.length + (currentSession == null ? 0 : 1);

  Map<String, dynamic> toJson() {
    return {
      'schemaVersion': 1,
      'exportedAt': exportedAt.toIso8601String(),
      'onboardingComplete': onboardingComplete,
      'settings': settings.toJson(),
      'currentSession': currentSession?.toJson(),
      'history': history.map((session) => session.toJson()).toList(),
    };
  }

  String toPrettyJson() => const JsonEncoder.withIndent('  ').convert(toJson());
}
