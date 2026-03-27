import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_shift/core/utils/date_utils.dart';

void main() {
  group('PocketShiftDateUtils', () {
    group('dateKey', () {
      test('formats date as yyyy-MM-dd', () {
        expect(PocketShiftDateUtils.dateKey(DateTime(2026, 3, 5)), '2026-03-05');
        expect(PocketShiftDateUtils.dateKey(DateTime(2026, 12, 31)), '2026-12-31');
        expect(PocketShiftDateUtils.dateKey(DateTime(2026, 1, 1)), '2026-01-01');
      });

      test('strips time component — same key regardless of hour', () {
        final morning = DateTime(2026, 3, 22, 8, 0, 0);
        final evening = DateTime(2026, 3, 22, 23, 59, 59);

        expect(PocketShiftDateUtils.dateKey(morning), PocketShiftDateUtils.dateKey(evening));
      });
    });

    group('startOfDay', () {
      test('zeroes out hours, minutes, and seconds', () {
        final dt = DateTime(2026, 3, 22, 15, 45, 30);
        final sod = PocketShiftDateUtils.startOfDay(dt);

        expect(sod.hour, 0);
        expect(sod.minute, 0);
        expect(sod.second, 0);
        expect(sod.year, 2026);
        expect(sod.month, 3);
        expect(sod.day, 22);
      });
    });

    group('parseDateKey', () {
      test('round-trips with dateKey', () {
        final dates = [DateTime(2026, 1, 1), DateTime(2026, 3, 22), DateTime(2026, 12, 31)];

        for (final date in dates) {
          final key = PocketShiftDateUtils.dateKey(date);
          final parsed = PocketShiftDateUtils.parseDateKey(key);
          expect(parsed, date, reason: 'round-trip failed for $key');
        }
      });

      test('throws on invalid date string', () {
        expect(() => PocketShiftDateUtils.parseDateKey('not-a-date'), throwsA(anything));
      });
    });

    group('isSameDate', () {
      test('returns true for same calendar date at different times', () {
        final a = DateTime(2026, 3, 22, 8, 0);
        final b = DateTime(2026, 3, 22, 23, 59);

        expect(PocketShiftDateUtils.isSameDate(a, b), isTrue);
      });

      test('returns false for different calendar dates', () {
        final a = DateTime(2026, 3, 22, 23, 59);
        final b = DateTime(2026, 3, 23, 0, 0);

        expect(PocketShiftDateUtils.isSameDate(a, b), isFalse);
      });

      test('returns false for different months', () {
        expect(PocketShiftDateUtils.isSameDate(DateTime(2026, 3, 22), DateTime(2026, 4, 22)), isFalse);
      });

      test('returns false for different years', () {
        expect(PocketShiftDateUtils.isSameDate(DateTime(2025, 3, 22), DateTime(2026, 3, 22)), isFalse);
      });
    });

    group('formatSessionDate', () {
      test('includes abbreviated month name and day', () {
        final result = PocketShiftDateUtils.formatSessionDate('2026-03-22');

        expect(result, contains('Mar'));
        expect(result, contains('22'));
      });

      test('produces different outputs for different dates', () {
        final march = PocketShiftDateUtils.formatSessionDate('2026-03-22');
        final april = PocketShiftDateUtils.formatSessionDate('2026-04-22');

        expect(march, isNot(equals(april)));
      });
    });

    group('formatCreatedAt', () {
      test('includes month, day, and time', () {
        final dt = DateTime(2026, 3, 22, 9, 5);
        final result = PocketShiftDateUtils.formatCreatedAt(dt);

        expect(result, contains('Mar'));
        expect(result, contains('22'));
        expect(result, contains('9:05'));
      });

      test('produces different outputs for different times', () {
        final morning = PocketShiftDateUtils.formatCreatedAt(DateTime(2026, 3, 22, 9, 0));
        final evening = PocketShiftDateUtils.formatCreatedAt(DateTime(2026, 3, 22, 21, 0));

        expect(morning, isNot(equals(evening)));
      });
    });
  });
}
