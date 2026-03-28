import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/clock.dart';
import '../../game/application/session_controller.dart';
import '../../game/data/session_repository.dart';
import '../domain/weekly_insights.dart';

final weeklyInsightsProvider = FutureProvider<WeeklyInsights>((ref) async {
  final currentSession = await ref.watch(sessionControllerProvider.future);
  final repository = ref.watch(sessionRepositoryProvider);
  final allSessions = await repository.loadAllSessions(currentSession: currentSession);
  final clock = ref.watch(clockProvider);

  return WeeklyInsights.fromSessions(now: clock(), sessions: allSessions);
});
