import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_shift/features/game/domain/daily_session.dart';
import 'package:pocket_shift/features/game/domain/trigger_tag.dart';
import 'package:pocket_shift/features/insights/domain/weekly_insights.dart';

void main() {
  group('WeeklyInsights', () {
    test('summarizes the most recent seven days of sessions', () {
      final now = DateTime(2026, 3, 27, 9);
      final sessions = [
        DailySession.fresh(now: DateTime(2026, 3, 27, 8), startingCoins: 10)
            .moveOne(now: DateTime(2026, 3, 27, 8, 10), triggerTag: TriggerTag.complaining)
            .moveOne(now: DateTime(2026, 3, 27, 8, 20), triggerTag: TriggerTag.workStress),
        DailySession.fresh(now: DateTime(2026, 3, 26, 8), startingCoins: 10)
            .moveOne(now: DateTime(2026, 3, 26, 8, 10), triggerTag: TriggerTag.complaining),
        DailySession.fresh(now: DateTime(2026, 3, 25, 8), startingCoins: 10).saveReflection(
          now: DateTime(2026, 3, 25, 20),
          whatShowedUp: 'I noticed the tone earlier.',
        ),
      ];

      final insights = WeeklyInsights.fromSessions(now: now, sessions: sessions);

      expect(insights.days, hasLength(7));
      expect(insights.totalMoves, 3);
      expect(insights.daysCheckedIn, 3);
      expect(insights.currentStreak, 3);
      expect(insights.topTriggers.first.tag, TriggerTag.complaining);
      expect(insights.topTriggers.first.count, 2);
    });

    test('handles an empty week gracefully', () {
      final now = DateTime(2026, 3, 27, 9);

      final insights = WeeklyInsights.fromSessions(now: now, sessions: const []);

      expect(insights.days, hasLength(7));
      expect(insights.totalMoves, 0);
      expect(insights.daysCheckedIn, 0);
      expect(insights.currentStreak, 0);
      expect(insights.topTriggers, isEmpty);
      expect(insights.hasMeaningfulData, isFalse);
    });
  });
}
