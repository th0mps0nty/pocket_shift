# Architecture

Pocket Shift uses a feature-first Flutter architecture with Riverpod-driven state and lightweight local repositories.

## Top-Level Layout

```text
lib/
  app/
    app.dart
    router.dart
    theme.dart
  core/
    constants/
    services/
    utils/
    widgets/
  features/
    onboarding/
    game/
    history/
    settings/
```

## App Layer

### `lib/app/app.dart`
Creates the root `MaterialApp.router` and connects theme + router.

### `lib/app/router.dart`
Owns route definitions, startup gate logic, and adaptive Material/Cupertino page behavior.

### `lib/app/theme.dart`
Defines the visual theme, bundled font usage, Material styling, and Cupertino override theme.

## Core Layer

### Constants
- app-wide persistence keys
- notification channel constants
- default coin count values

### Services
- `key_value_store.dart`: abstraction over `SharedPreferencesAsync`
- `notification_service.dart`: local notification scheduling and cancellation
- `sound_effects_service.dart`: app-owned method-channel sound playback

### Utils
- `date_utils.dart`: day keys, formatting, comparisons
- `clock.dart`: injectable clock provider for testability
- `platform_utils.dart`: platform-specific adaptive decisions

### Shared Widgets
- adaptive scaffolds and pickers
- shell/navigation widgets
- background and card primitives

## Feature Modules

### Onboarding
Responsibilities:
- determine whether onboarding has been completed
- mark onboarding as complete
- present lightweight onboarding flow

Key pieces:
- repository for onboarding completion flag
- async notifier controller
- simple presentation screen

### Game
Responsibilities:
- load or create current daily session
- move a coin
- undo the most recent move
- trigger rollover into a new session when the day changes
- render the home game experience

Key pieces:
- `DailySession` and `CoinMove` domain models
- `SessionRepository` for current session + history archive persistence
- `SessionController` async notifier for current gameplay state
- animated pocket UI and interaction widgets

### History
Responsibilities:
- combine current session and archived sessions into a timeline
- render a simple, supportive history view

Key pieces:
- timeline item model
- repository wrapper over session repository history
- future provider for timeline loading

### Settings
Responsibilities:
- store user configuration
- synchronize reminders when settings change
- expose adaptive settings UI
- expose the About/Credits screen

Key pieces:
- `AppSettings` domain model
- `CoinStyle` enum and metadata
- settings repository
- settings controller
- settings and about presentation screens

## State Management

Riverpod patterns used:
- `Provider` for stateless dependencies
- `FutureProvider` for derived async history/startup data
- `AsyncNotifierProvider` for settings and session state

Design goals:
- keep business logic out of widgets
- make repositories testable
- keep async loading and refresh behavior explicit

## Persistence Strategy

Storage is deliberately simple and local.

Mechanism:
- JSON-encoded models persisted through `SharedPreferencesAsync`

Current keys:
- onboarding complete flag
- app settings blob
- current session blob
- history list blob

## Notifications

Notification scheduling is handled centrally in `NotificationService`.

Approach:
- initialize plugin safely
- request permissions only when needed
- schedule/cancel one daily reminder notification
- use device timezone when available
- fail quietly on incomplete platform setup

## Sound

A single sound effect is played through a `MethodChannel` rather than a general-purpose audio package.

Reasoning:
- only one effect is needed
- native APIs are straightforward for this use case
- reduces dependency surface area and build fragility

Platform implementations:
- iOS: `AVAudioPlayer`
- macOS: `AVAudioPlayer`
- Android: `SoundPool`

## Adaptive UX

Pocket Shift intentionally adapts certain UI on Apple platforms.

Examples:
- Cupertino page transitions
- Cupertino tab bar
- Cupertino modal time picker
- Cupertino action sheet for coin style selection
- adaptive switches

## Testing Philosophy

The current test suite focuses on stable business logic and critical navigation.

Covered areas:
- daily session move logic
- undo logic
- remaining coin calculations
- rollover and archive behavior
- settings serialization/persistence
- about navigation flow

## Production Notes

Important implementation decisions:
- local bundled font instead of runtime font package
- local method-channel sound instead of heavier audio plugin
- feature-first organization over monolithic widget files
- no backend dependencies
