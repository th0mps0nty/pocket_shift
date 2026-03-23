import 'package:flutter/foundation.dart';

bool isCupertinoPlatform([TargetPlatform? platform]) {
  final value = platform ?? defaultTargetPlatform;
  return value == TargetPlatform.iOS || value == TargetPlatform.macOS;
}
