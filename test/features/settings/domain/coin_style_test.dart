import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_shift/features/settings/domain/coin_style.dart';

void main() {
  group('CoinStyleX', () {
    group('label', () {
      test('every style returns a non-empty label', () {
        expect(CoinStyle.penny.label, 'Penny');
        expect(CoinStyle.nickel.label, 'Nickel');
        expect(CoinStyle.dime.label, 'Dime');
        expect(CoinStyle.quarter.label, 'Quarter');
      });
    });

    group('shortLabel', () {
      test('every style returns its denomination shorthand', () {
        expect(CoinStyle.penny.shortLabel, '1c');
        expect(CoinStyle.nickel.shortLabel, '5c');
        expect(CoinStyle.dime.shortLabel, '10c');
        expect(CoinStyle.quarter.shortLabel, '25c');
      });
    });

    group('description', () {
      test('every style returns a non-empty description', () {
        for (final style in CoinStyle.values) {
          expect(style.description, isNotEmpty, reason: 'empty description for $style');
        }
      });

      test('all descriptions are distinct', () {
        final descriptions = CoinStyle.values.map((s) => s.description).toList();
        expect(descriptions.toSet().length, CoinStyle.values.length);
      });
    });

    group('gradientColors', () {
      test('every style returns exactly two gradient colors', () {
        for (final style in CoinStyle.values) {
          expect(style.gradientColors, hasLength(2), reason: 'wrong length for $style');
        }
      });

      test('all gradient pairs are distinct', () {
        final pairs = CoinStyle.values.map((s) => s.gradientColors).toList();
        final unique = {for (final p in pairs) '${p[0].toARGB32()}-${p[1].toARGB32()}'};
        expect(unique.length, CoinStyle.values.length);
      });
    });

    group('rimColor', () {
      test('every style returns a non-null rim color', () {
        for (final style in CoinStyle.values) {
          expect(style.rimColor, isNotNull, reason: 'null rimColor for $style');
        }
      });

      test('penny rim color matches expected value', () {
        expect(CoinStyle.penny.rimColor.toARGB32(), 0xFFF0C3A3);
      });
    });

    group('storageValue', () {
      test('each storage value is the enum name', () {
        for (final style in CoinStyle.values) {
          expect(style.storageValue, style.name);
        }
      });
    });

    group('fromStorageValue', () {
      test('resolves all valid storage values', () {
        for (final style in CoinStyle.values) {
          expect(CoinStyleX.fromStorageValue(style.storageValue), style);
        }
      });

      test('falls back to penny for unknown values', () {
        expect(CoinStyleX.fromStorageValue('unknown'), CoinStyle.penny);
        expect(CoinStyleX.fromStorageValue(null), CoinStyle.penny);
      });
    });
  });
}
