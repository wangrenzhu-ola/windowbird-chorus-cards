# WindowBird Chorus Cards

WindowBird Chorus Cards is a native SwiftUI iOS app for lightweight backyard birdsong observation. The app avoids audio recording and species identification: users manually save the rhythm, direction, weather, mood, and private note for a window listen, then review those cards on a neighborhood sound map.

## Open in Xcode

Open the human-debuggable project:

```bash
open /Users/wangrenzhu/work/windowbird-chorus-cards/WindowBirdChorusCards.xcodeproj
```

Scheme: `WindowBirdChorusCards`

## Product scope

- App language: English (United States) / en-US.
- Platform: iOS native SwiftUI.
- Local-first: JSON persistence in Application Support.
- AI/backend: none.
- Microphone: not used.
- Premium: StoreKit 2 boundary for an optional Premium Dawn Pack; the free listen flow is never blocked.

## Required screens

1. Morning Chorus
2. Sound Shape Picker
3. Window Listen Detail
4. Neighborhood Sound Map
5. Badge Roost

## Acceptance coverage

- CRUD: create in Morning Chorus → choose shape → save/edit/archive/delete in Window Listen Detail.
- Persistence: saved cards are encoded to local JSON and reloaded by `ListenStore`.
- Visual slot: soft dawn gradient, illustrated bird silhouette cards, compass direction ring, and neighborhood sound dots.
- Empty state: Morning Chorus and Neighborhood Sound Map show starter actions.
- Error state: note length, simulated local save failure, missing StoreKit product, restore miss, and simulated IAP failure.
- Privacy: visible copy says no microphone recording is required and optional notes stay private on device.
- Premium: purchase, restore, failure, locked/unlocked states are visible in Badge Roost.

## Verification commands

```bash
cd /Users/wangrenzhu/work/windowbird-chorus-cards
xcodebuild -project WindowBirdChorusCards.xcodeproj -scheme WindowBirdChorusCards -destination 'platform=iOS Simulator,name=iPhone 17' build
xcodebuild -project WindowBirdChorusCards.xcodeproj -scheme WindowBirdChorusCards -destination 'platform=iOS Simulator,name=iPhone 17' test
```
