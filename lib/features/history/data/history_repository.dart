import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../game/data/session_repository.dart';
import '../../game/domain/daily_session.dart';
import '../domain/history_timeline_item.dart';

final historyRepositoryProvider = Provider<HistoryRepository>(
  (ref) => HistoryRepository(ref.watch(sessionRepositoryProvider)),
);

class HistoryRepository {
  const HistoryRepository(this._sessionRepository);

  final SessionRepository _sessionRepository;

  Future<List<HistoryTimelineItem>> loadTimeline({
    required DailySession currentSession,
  }) async {
    final history = await _sessionRepository.loadHistory();
    return [
      HistoryTimelineItem(session: currentSession, isCurrent: true),
      ...history.map(
        (session) => HistoryTimelineItem(session: session, isCurrent: false),
      ),
    ];
  }
}
