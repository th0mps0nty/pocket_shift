# Release Notes And Operational Checklist

This document captures the practical things to verify before shipping Pocket Shift beyond local development.

## Pre-Release Validation

Run all of the following from the project root:

```bash
flutter clean
flutter pub get
flutter analyze
flutter test
flutter build ios --debug --no-codesign
flutter build ios --simulator --debug --no-codesign
flutter build macos --debug
flutter build apk --debug
```

For a real release, also perform release-mode validation on each target you plan to ship.

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

### Settings
- daily coin count persists
- sound toggle persists
- haptics toggle persists
- reminder toggle persists
- reminder time persists
- coin style persists
- About screen opens and back navigation works

### Notifications
- enabling reminders requests permission where supported
- changing reminder time updates the next scheduled reminder
- disabling reminders cancels the reminder
- notification failure does not crash the app

### Platform-specific UX
- iOS/macOS use Cupertino-style navigation/tab/time picker flows
- Android uses Material equivalents
- app icon and splash screen look correct on each platform
- sound effect plays once per move without stacking oddly

## iOS Notes

- Current validation includes device-style and simulator builds.
- The app intentionally avoids dependency patterns that triggered Flutter native-assets `SdkRoot` issues during iPhone deployment.
- Real device deployment still requires normal signing and provisioning setup in Xcode.

## Android Notes

- `android/app/build.gradle.kts` pins a working NDK version in this environment.
- Core library desugaring is enabled because `flutter_local_notifications` requires it.
- Verify release signing before producing a store-ready artifact.

## macOS Notes

- Current debug build validates successfully.
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

## Recommended Next Release Tasks

- configure release signing for iOS and Android
- create app store screenshots and metadata
- verify notification behavior on physical devices
- run a dynamic type/accessibility pass
- run a VoiceOver/TalkBack pass
- test background/foreground transitions repeatedly on device
- test date rollover around midnight on device
