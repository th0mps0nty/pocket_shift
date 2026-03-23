import 'package:flutter/material.dart';

enum CoinStyle {
  penny,
  nickel,
  dime,
  quarter,
}

extension CoinStyleX on CoinStyle {
  String get storageValue => name;

  String get label {
    switch (this) {
      case CoinStyle.penny:
        return 'Penny';
      case CoinStyle.nickel:
        return 'Nickel';
      case CoinStyle.dime:
        return 'Dime';
      case CoinStyle.quarter:
        return 'Quarter';
    }
  }

  String get shortLabel {
    switch (this) {
      case CoinStyle.penny:
        return '1c';
      case CoinStyle.nickel:
        return '5c';
      case CoinStyle.dime:
        return '10c';
      case CoinStyle.quarter:
        return '25c';
    }
  }

  String get description {
    switch (this) {
      case CoinStyle.penny:
        return 'Warm copper and classic pocket-change energy.';
      case CoinStyle.nickel:
        return 'Soft silver with a slightly weightier feel.';
      case CoinStyle.dime:
        return 'Bright silver and quick little flashes.';
      case CoinStyle.quarter:
        return 'Bold silver with a bigger landing feel.';
    }
  }

  List<Color> get gradientColors {
    switch (this) {
      case CoinStyle.penny:
        return const [Color(0xFFD98B63), Color(0xFFB7643A)];
      case CoinStyle.nickel:
        return const [Color(0xFFD2D7DD), Color(0xFF949CA6)];
      case CoinStyle.dime:
        return const [Color(0xFFE5EBF0), Color(0xFFA7B1BB)];
      case CoinStyle.quarter:
        return const [Color(0xFFF3F6F8), Color(0xFFB7C0C8)];
    }
  }

  Color get rimColor {
    switch (this) {
      case CoinStyle.penny:
        return const Color(0xFFF0C3A3);
      case CoinStyle.nickel:
        return const Color(0xFFF8FBFF);
      case CoinStyle.dime:
        return const Color(0xFFFFFFFF);
      case CoinStyle.quarter:
        return const Color(0xFFFFFFFF);
    }
  }

  static CoinStyle fromStorageValue(String? value) {
    return CoinStyle.values.firstWhere(
      (style) => style.storageValue == value,
      orElse: () => CoinStyle.penny,
    );
  }
}
