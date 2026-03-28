import 'package:intl/intl.dart';

import '../../../core/utils/date_utils.dart';
import '../../game/domain/daily_session.dart';
import '../../game/domain/trigger_tag.dart';

class WeeklyInsights {
  const WeeklyInsights({
    required this.days,
    required this.totalMoves,
    required this.daysCheckedIn,
    required this.currentStreak,
    required this.averageMoves,
    required this.topTriggers,
  });

  final List<WeeklyInsightDay> days;
  final int totalMoves;
  final int daysCheckedIn;
  final int currentStreak;
  final double averageMoves;
  final List<TriggerTally> topTriggers;

  bool get hasMeaningfulData => days.any((day) => day.hasCheckIn);

  factory WeeklyInsights.fromSessions({
    required DateTime now,
    required List<DailySession> sessions,
  }) {
    final end = PocketShiftDateUtils.startOfDay(now);
    final start = end.subtract(const Duration(days: 6));
    final byDate = <String, DailySession>{};
    for (final session in sessions) {
      byDate[session.date] = session;
    }

    final days = <WeeklyInsightDay>[];
    for (var offset = 0; offset < 7; offset += 1) {
      final date = start.add(Duration(days: offset));
      final key = PocketShiftDateUtils.dateKey(date);
      final session = byDate[key];
      days.add(
        WeeklyInsightDay(
          date: date,
          label: DateFormat('E').format(date),
          movedCoins: session?.movedCoins ?? 0,
          hasCheckIn: session?.hasCheckIn ?? false,
        ),
      );
    }

    final inRangeSessions = sessions.where((session) {
      final date = PocketShiftDateUtils.parseDateKey(session.date);
      return !date.isBefore(start) && !date.isAfter(end);
    }).toList();

    final totalMoves = inRangeSessions.fold<int>(0, (sum, session) => sum + session.movedCoins);
    final daysCheckedIn = inRangeSessions.where((session) => session.hasCheckIn).length;
    final averageMoves = totalMoves / 7;

    final triggerCounts = <TriggerTag, int>{};
    for (final session in inRangeSessions) {
      for (final entry in session.triggerCounts.entries) {
        triggerCounts.update(entry.key, (value) => value + entry.value, ifAbsent: () => entry.value);
      }
    }

    final topTriggers = triggerCounts.entries
        .map((entry) => TriggerTally(tag: entry.key, count: entry.value))
        .toList()
      ..sort((a, b) => b.count.compareTo(a.count));

    var currentStreak = 0;
    for (var index = days.length - 1; index >= 0; index -= 1) {
      if (!days[index].hasCheckIn) {
        break;
      }
      currentStreak += 1;
    }

    return WeeklyInsights(
      days: days,
      totalMoves: totalMoves,
      daysCheckedIn: daysCheckedIn,
      currentStreak: currentStreak,
      averageMoves: averageMoves,
      topTriggers: topTriggers.take(3).toList(),
    );
  }
}

class WeeklyInsightDay {
  const WeeklyInsightDay({
    required this.date,
    required this.label,
    required this.movedCoins,
    required this.hasCheckIn,
  });

  final DateTime date;
  final String label;
  final int movedCoins;
  final bool hasCheckIn;
}

class TriggerTally {
  const TriggerTally({required this.tag, required this.count});

  final TriggerTag tag;
  final int count;
}
