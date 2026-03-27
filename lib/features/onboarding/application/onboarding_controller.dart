import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/onboarding_repository.dart';

final onboardingControllerProvider = AsyncNotifierProvider<OnboardingController, bool>(OnboardingController.new);

class OnboardingController extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    return ref.read(onboardingRepositoryProvider).isComplete();
  }

  Future<void> complete() async {
    state = const AsyncData(true);
    await ref.read(onboardingRepositoryProvider).markComplete();
  }
}
