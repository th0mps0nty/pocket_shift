import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/onboarding_repository.dart';

final onboardingControllerProvider =
    AsyncNotifierProvider<OnboardingController, bool>(
  OnboardingController.new,
);

class OnboardingController extends AsyncNotifier<bool> {
  late final OnboardingRepository _repository;

  @override
  Future<bool> build() async {
    _repository = ref.read(onboardingRepositoryProvider);
    return _repository.isComplete();
  }

  Future<void> complete() async {
    state = const AsyncData(true);
    await _repository.markComplete();
  }
}
