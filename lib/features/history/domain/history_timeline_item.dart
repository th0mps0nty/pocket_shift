import '../../game/domain/daily_session.dart';

class HistoryTimelineItem {
  const HistoryTimelineItem({
    required this.session,
    required this.isCurrent,
  });

  final DailySession session;
  final bool isCurrent;
}
