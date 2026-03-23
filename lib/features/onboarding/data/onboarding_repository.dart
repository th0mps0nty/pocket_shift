import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/key_value_store.dart';

final onboardingRepositoryProvider = Provider<OnboardingRepository>(
  (ref) => OnboardingRepository(ref.watch(keyValueStoreProvider)),
);

class OnboardingRepository {
  OnboardingRepository(this._store);

  final KeyValueStore _store;

  Future<bool> isComplete() async {
    return await _store.getBool(AppConstants.onboardingCompleteKey) ?? false;
  }

  Future<void> markComplete() {
    return _store.setBool(AppConstants.onboardingCompleteKey, true);
  }
}
