import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../game/application/session_controller.dart';
import '../../game/data/session_repository.dart';
import '../../game/domain/daily_session.dart';
import '../data/history_repository.dart';
import '../domain/history_timeline_item.dart';

final historyTimelineProvider = FutureProvider<List<HistoryTimelineItem>>((
  ref,
) async {
  final currentSession = await ref.watch(sessionControllerProvider.future);
  final repository = ref.watch(historyRepositoryProvider);
  return repository.loadTimeline(currentSession: currentSession);
});

final sessionDetailProvider = FutureProvider.family<DailySession?, String>((
  ref,
  sessionId,
) async {
  final currentSession = await ref.watch(sessionControllerProvider.future);
  if (currentSession.id == sessionId) {
    return currentSession;
  }

  final repository = ref.watch(sessionRepositoryProvider);
  return repository.loadSessionById(sessionId);
});
