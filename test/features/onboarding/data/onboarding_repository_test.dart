import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_shift/features/onboarding/data/onboarding_repository.dart';

import '../../../helpers/in_memory_key_value_store.dart';

void main() {
  group('OnboardingRepository', () {
    test('isComplete returns false when nothing has been saved', () async {
      final repository = OnboardingRepository(InMemoryKeyValueStore());

      expect(await repository.isComplete(), isFalse);
    });

    test('isComplete returns true after markComplete', () async {
      final repository = OnboardingRepository(InMemoryKeyValueStore());

      await repository.markComplete();

      expect(await repository.isComplete(), isTrue);
    });

    test('markComplete persists across separate repository instances sharing the same store', () async {
      final store = InMemoryKeyValueStore();
      await OnboardingRepository(store).markComplete();

      final secondInstance = OnboardingRepository(store);
      expect(await secondInstance.isComplete(), isTrue);
    });
  });
}
