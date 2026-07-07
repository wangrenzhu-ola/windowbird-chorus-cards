# WindowBird Chorus Cards

WindowBird Chorus Cards is a native SwiftUI iOS app for lightweight backyard birdsong observation. The app avoids audio recording and species identification: users manually save the rhythm, direction, weather, mood, optional window view photo, and private note for a window listen, then review those cards on a neighborhood sound map.

## Open in Xcode

Open the human-debuggable project:

```bash
open WindowBirdChorusCards.xcodeproj
```

Scheme: `WindowBirdChorusCards`

## Product scope

- App language: English (United States) / en-US.
- Platform: iOS native SwiftUI.
- Local-first: JSON persistence in Application Support.
- AI/backend: none.
- Microphone: declared in Info.plist only; the listening flow does not prompt for microphone access.
- Credits: StoreKit 2 consumable Chorus Credits (27 packs). New listen cards cost 10 credits; editing is free. No restore purchases.

## Required screens

1. Morning Chorus
2. Sound Shape Picker (rhythm only — metadata on the next screen)
3. Window Listen Detail
4. Neighborhood Sound Map
5. Chorus Credit Shop (Shop tab)
6. Badge Roost (linked from Morning Chorus and Sound Map)

## Acceptance coverage

- CRUD: create in Morning Chorus → choose rhythm → complete metadata in Window Listen Detail → save/edit/archive/delete.
- Persistence: saved cards are encoded to local JSON and reloaded by `ListenStore`.
- Visual slot: soft dawn gradient, illustrated bird silhouette cards, compass direction ring, neighborhood sound dots, and window view photos.
- Empty state: Morning Chorus and Neighborhood Sound Map show starter actions.
- Error state: note length, simulated local save failure (Debug), missing StoreKit product, and simulated IAP failure (Debug).
- Privacy: visible copy says listen cards and window photos stay on device; legal links open in an in-app WebView.
- Credits: purchase, failure, and balance states are visible in Chorus Credit Shop without blocking free editing.

## Verification commands

```bash
xcodebuild -project WindowBirdChorusCards.xcodeproj -scheme WindowBirdChorusCards -destination 'platform=iOS Simulator,name=iPhone 17' build
xcodebuild -project WindowBirdChorusCards.xcodeproj -scheme WindowBirdChorusCards -destination 'platform=iOS Simulator,name=iPhone 17' test
python3 Scripts/acceptance_audit.py
```
