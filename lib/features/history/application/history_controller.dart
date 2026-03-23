import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../game/application/session_controller.dart';
import '../data/history_repository.dart';
import '../domain/history_timeline_item.dart';

final historyTimelineProvider = FutureProvider<List<HistoryTimelineItem>>(
  (ref) async {
    final currentSession = await ref.watch(sessionControllerProvider.future);
    final repository = ref.watch(historyRepositoryProvider);
    return repository.loadTimeline(currentSession: currentSession);
  },
);
