import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final soundEffectsServiceProvider = Provider<SoundEffectsService>(
  (ref) => const SoundEffectsService(),
);

class SoundEffectsService {
  const SoundEffectsService();

  static const MethodChannel _channel = MethodChannel(
    'com.tylerthompson.pocket_shift/sound_effects',
  );

  Future<void> playCoinLanding({Duration delay = Duration.zero}) async {
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }

    try {
      await _channel.invokeMethod<void>('playCoinLanding');
    } catch (_) {
      // Sound is decorative, so failure should stay silent.
    }
  }
}
