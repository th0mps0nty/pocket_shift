# Pocket Shift

Pocket Shift is a production-oriented Flutter app built around a simple counseling exercise: start the day with coins in your left pocket, and move one to the right pocket whenever you notice yourself drifting into negativity.

The app is designed to feel light, private, supportive, and fast. It is about awareness, not shame.

## Product Summary

Pocket Shift helps a user:
- begin each day with a fixed number of coins
- move one coin with a single tap when they notice a negative thought pattern
- undo the most recent move
- roll into a fresh day automatically
- review past days locally in history
- customize reminders, sound, haptics, and coin style
- read the story and credits behind the exercise in a dedicated About screen

## Inspiration And Credit

Pocket Shift was inspired by a counseling exercise intended to build awareness and gently shift perspective.

With gratitude to Brett Froggatt of Second Chance Columbus for sharing the exercise that inspired this app.
Contact: `brett@secondchancecolumbus.com`

If this app is distributed publicly, confirm that this attribution and contact information remain appropriate for public release.

## Platforms

Currently supported and validated in this workspace:
- iOS
- Android
- macOS

The app also contains generated Flutter targets for web, linux, and windows, but the product has been actively tuned and validated primarily for iOS, Android, and macOS.

## Key Features

- lightweight onboarding
- game-first home screen
- denim-inspired left/right pocket visuals
- one-tap coin transfer
- animated coin flip and landing
- optional sound and haptics
- undo last move
- daily rollover with local history archive
- local persistence with modern `shared_preferences` async API
- daily reminder notifications with graceful failure handling
- adaptive Apple-style navigation and pickers where appropriate
- dedicated About/Credits screen
- editable reminder copy
- local export and reset tools
- generated App Store and Play Store metadata drafts

## Tech Stack

- Flutter
- `flutter_riverpod`
- `go_router`
- `shared_preferences`
- `flutter_local_notifications`
- `flutter_animate`
- built-in `HapticFeedback`
- native platform sound playback via `MethodChannel`

## Project Structure

```text
lib/
  app/
  core/
  features/
    onboarding/
    game/
    history/
    settings/
```

See [docs/ARCHITECTURE.md](/Users/tylerthompson/Developer/_flutter-appz/pocket_shift/docs/ARCHITECTURE.md) for a more detailed breakdown.

## Setup

### Prerequisites

- Flutter `3.41.1` or compatible stable toolchain
- Xcode for iOS/macOS development
- Android Studio or Android SDK for Android development

### Install

```bash
cd /Users/tylerthompson/Developer/_flutter-appz/pocket_shift
flutter pub get
```

## Run

### macOS

```bash
flutter run -d macos
```

### iOS simulator

```bash
flutter run -d "iPhone 17 Pro Max"
```

### iOS device

```bash
flutter run -d <device-id>
```

### Android

```bash
flutter run -d android
```

## Validation

### Static analysis

```bash
flutter analyze
```

### Tests

```bash
flutter test
```

### Build checks

```bash
flutter build ios --debug --no-codesign
flutter build ios --simulator --debug --no-codesign
flutter build macos --debug
flutter build apk --debug
```

## Notifications

Pocket Shift uses local notifications for daily reminders.

Behavior:
- reminders are optional and disabled by default
- enabling reminders requests notification permission where possible
- changing reminder time reschedules the daily reminder
- disabling reminders cancels the scheduled notification
- setup failures fail quietly so the app remains usable

## Persistence Model

Pocket Shift stores data locally on device only.

Stored data includes:
- onboarding completion state
- app settings
- current daily session
- archived session history

No backend, auth, analytics SDK, or cloud sync is included.

## Sound Implementation Note

Coin landing sound is implemented through a small app-owned `MethodChannel` bridge instead of a heavier audio plugin.

Why:
- it keeps playback simple for a single effect
- it avoids extra plugin complexity
- it avoids an iOS native-assets toolchain issue encountered during device deployment

## Font Implementation Note

The app uses a bundled local `Manrope` font asset instead of runtime font packages.

Why:
- keeps typography deterministic offline
- reduces dependency surface area
- avoids transitive native-assets/tooling issues on iOS builds

## Design Notes

Current visual direction:
- calm sand background
- deep denim blue pocket area
- warm coin palette with selectable coin styles
- supportive copy throughout
- Apple-adaptive pickers and navigation where it improves fit on iOS/macOS

## Known Operational Notes

- Android build is pinned to a working local NDK version in `android/app/build.gradle.kts`.
- Android enables core library desugaring because `flutter_local_notifications` requires it.
- macOS builds may emit third-party CocoaPods deployment target warnings; current validated builds still complete successfully.

## Release Guidance

Read [docs/RELEASE.md](/Users/tylerthompson/Developer/_flutter-appz/pocket_shift/docs/RELEASE.md) before preparing a store or production release build. Store listing drafts live in [store_metadata/generated/app_store_connect.md](/Users/tylerthompson/Developer/_flutter-appz/pocket_shift/store_metadata/generated/app_store_connect.md) and [store_metadata/generated/play_store.md](/Users/tylerthompson/Developer/_flutter-appz/pocket_shift/store_metadata/generated/play_store.md).

## Assets

Important bundled assets:
- app icon: [assets/branding/pocket_shift_icon.png](/Users/tylerthompson/Developer/_flutter-appz/pocket_shift/assets/branding/pocket_shift_icon.png)
- splash image: [assets/branding/pocket_shift_splash.png](/Users/tylerthompson/Developer/_flutter-appz/pocket_shift/assets/branding/pocket_shift_splash.png)
- sound effect: [assets/audio/coin_ching.wav](/Users/tylerthompson/Developer/_flutter-appz/pocket_shift/assets/audio/coin_ching.wav)
- bundled font: [assets/fonts/Manrope-Variable.ttf](/Users/tylerthompson/Developer/_flutter-appz/pocket_shift/assets/fonts/Manrope-Variable.ttf)

## Testing Coverage

Current automated coverage includes:
- coin move logic
- undo logic
- remaining count logic
- daily rollover logic
- settings serialization/persistence basics
- settings to About navigation flow

## Future Work

Good next candidates for v2:
- optional encrypted export file support instead of clipboard-only export
- richer reminder scheduling options beyond a single daily time
- import/restore flow for local backups
- deeper VoiceOver and TalkBack rotor actions
- screenshot automation for store submissions
