class AppConstants {
  const AppConstants._();

  static const String iosPriceLabel = 'Website stays free';
  static const String iosStoreAvailabilityLabel =
      'Now on the App Store, coming soon to Android';
  static const String iosAppStoreUrl =
      'https://apps.apple.com/us/app/pocketshift/id6761237770';
  static const String supportUrl = 'https://pocketshift.app/support/';
  static const String privacyUrl = 'https://pocketshift.app/privacy/';

  static const int defaultDailyCoinCount = 10;
  static const int minDailyCoinCount = 1;
  static const int maxDailyCoinCount = 20;

  static const String onboardingCompleteKey = 'onboarding_complete';
  static const String settingsKey = 'app_settings';
  static const String currentSessionKey = 'current_session';
  static const String historyKey = 'session_history';

  static const String defaultReminderTitle = 'Pocket Shift';
  static const String defaultReminderBody =
      'Pause for a breath and notice what pocket today is in.';

  static const int reminderNotificationId = 410;
  static const String reminderChannelId = 'pocket_shift_daily';
  static const String reminderChannelName = 'Daily Pocket Shift reminders';
  static const String reminderChannelDescription =
      'Gentle reminders to notice a small shift.';
}
