import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_shift/core/services/key_value_store.dart';
import 'package:pocket_shift/features/onboarding/application/onboarding_controller.dart';

import '../../../helpers/in_memory_key_value_store.dart';

void main() {
  group('OnboardingController', () {
    ProviderContainer makeContainer() {
      return ProviderContainer(overrides: [keyValueStoreProvider.overrideWithValue(InMemoryKeyValueStore())]);
    }

    test('starts as false when onboarding has not been completed', () async {
      final container = makeContainer();
      addTearDown(container.dispose);

      final isComplete = await container.read(onboardingControllerProvider.future);

      expect(isComplete, isFalse);
    });

    test('complete() transitions state to true', () async {
      final container = makeContainer();
      addTearDown(container.dispose);

      await container.read(onboardingControllerProvider.future);
      await container.read(onboardingControllerProvider.notifier).complete();

      final isComplete = await container.read(onboardingControllerProvider.future);
      expect(isComplete, isTrue);
    });

    test('complete() persists so the controller rebuilds as true', () async {
      final container = makeContainer();
      addTearDown(container.dispose);

      await container.read(onboardingControllerProvider.future);
      await container.read(onboardingControllerProvider.notifier).complete();

      container.invalidate(onboardingControllerProvider);

      final isComplete = await container.read(onboardingControllerProvider.future);
      expect(isComplete, isTrue);
    });
  });
}
