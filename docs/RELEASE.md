# Release Notes And Operational Checklist

This document captures the practical things to verify before shipping Pocket Shift beyond local development.

## Release-Mode Validation

Run all of the following from the project root:

```bash
flutter clean
flutter pub get
flutter analyze
flutter test
flutter build ios --release --no-codesign
flutter build apk --release
flutter build appbundle --release
flutter build macos --release
```

If you are validating a release candidate for TestFlight or internal Play testing, also run a real-device smoke pass after the release build completes.

## Manual QA Checklist

### Core behavior
- onboarding appears only on first launch
- app lands on game screen after onboarding
- first tap on coin move animates immediately
- coin count updates correctly
- user cannot move more coins than remain
- undo only removes the most recent move
- app restores current day correctly after restart
- changing device date or rolling to next day creates a fresh session and archives the prior day

### Settings and tools
- daily coin count persists
- sound toggle persists
- haptics toggle persists
- reminder toggle persists
- reminder time persists
- reminder title and body persist
- coin style persists
- data export copies valid JSON
- progress reset clears session and history but keeps settings
- full reset clears settings, reminders, onboarding, and history
- About screen opens and back navigation works

### Notifications
- enabling reminders requests permission where supported
- changing reminder time updates the next scheduled reminder
- changing reminder copy updates the next scheduled reminder
- disabling reminders cancels the reminder
- notification failure does not crash the app

### Accessibility and dynamic type
- game screen remains readable at larger text sizes
- pocket cards do not overlap at larger text sizes
- Settings cards remain tappable and readable at larger text sizes
- VoiceOver and TalkBack announce primary actions clearly
- button labels do not rely on color only
- reduced motion keeps the app usable without losing feedback

### Platform-specific UX
- iOS/macOS use Cupertino-style navigation, dialogs, and time picker flows
- Android uses Material equivalents
- app icon and splash screen look correct on each platform
- sound effect plays once per move without stacking oddly

## Store Metadata Automation

Pocket Shift includes a single metadata source file and a small generator script.

Source:
- [store_metadata/source.json](/Users/tylerthompson/Developer/_flutter-appz/pocket_shift/store_metadata/source.json)

Generator:
- [tool/generate_store_metadata.dart](/Users/tylerthompson/Developer/_flutter-appz/pocket_shift/tool/generate_store_metadata.dart)

Generated drafts:
- [store_metadata/generated/app_store_connect.md](/Users/tylerthompson/Developer/_flutter-appz/pocket_shift/store_metadata/generated/app_store_connect.md)
- [store_metadata/generated/play_store.md](/Users/tylerthompson/Developer/_flutter-appz/pocket_shift/store_metadata/generated/play_store.md)

Regenerate drafts with:

```bash
cd /Users/tylerthompson/Developer/_flutter-appz/pocket_shift
dart run tool/generate_store_metadata.dart
```

## App Store Readiness Checklist

### iOS / App Store Connect
- confirm bundle identifier, version, and build number
- configure signing and provisioning in Xcode
- verify notification permission copy and behavior on real device
- provide support URL and privacy policy URL if required by your distribution plan
- confirm attribution to Brett Froggatt remains approved for public release
- review screenshots for all required device classes
- upload release notes from the generated metadata draft
- verify app category, subtitle, promotional text, and keywords

### Android / Google Play
- configure release keystore and signing config
- verify `versionCode` and `versionName`
- confirm notification permission behavior on Android 13+
- review Data safety answers against the current build
- prepare phone screenshots and feature graphic if used
- upload short description, full description, and release notes from generated metadata draft

### macOS
- confirm signing and notarization requirements for your distribution path
- verify app icon and app name in Finder and Dock
- smoke test notifications, sound, and reminder editing on a real machine

## Operational Notes

### iOS
- Current validation includes device-style and simulator builds.
- The app intentionally avoids dependency patterns that triggered Flutter native-assets `SdkRoot` issues during iPhone deployment.
- Real device deployment still requires normal signing and provisioning setup in Xcode.

### Android
- `android/app/build.gradle.kts` pins a working NDK version in this environment.
- Core library desugaring is enabled because `flutter_local_notifications` requires it.
- Verify release signing before producing a store-ready artifact.

### macOS
- Current builds validate successfully.
- Third-party CocoaPods may still emit deployment-target warnings; monitor those during dependency upgrades.

## Attribution Review

Before public distribution:
- confirm Brett Froggatt attribution remains desired
- confirm public display of `brett@secondchancecolumbus.com` is approved

## Copy Review

Before release, review all supportive copy with product intent in mind:
- awareness over shame
- no punitive framing
- supportive but not saccharine
- explicit privacy/local-first framing
