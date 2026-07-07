# Verification Report

Generated after implementation for WindowBird Chorus Cards.

## Project

- App directory: `windowbird-chorus-cards`
- Human-openable Xcode project: `WindowBirdChorusCards.xcodeproj`
- Scheme: `WindowBirdChorusCards`

## Build and test evidence

```bash
xcodebuild -list -project WindowBirdChorusCards.xcodeproj
# Result: PASS; scheme WindowBirdChorusCards is listed.

xcodebuild -project WindowBirdChorusCards.xcodeproj -scheme WindowBirdChorusCards -destination 'platform=iOS Simulator,name=iPhone 17' CODE_SIGNING_ALLOWED=NO test
# Result: ** TEST SUCCEEDED **
```

## Functional acceptance mapping

- REQ-CRUD-001: `ListenStoreAcceptanceTests.testCRUDPersistenceArchiveAndDeleteFlow` creates, edits, archives, and deletes a `ListenCard`; UI exposes Save/Edit/Archive/Delete actions.
- REQ-PERSIST-001: same test reloads a new `ListenStore` from local JSON and verifies the saved card remains.
- REQ-VIS-001: `VisualLocaleAcceptanceTests.testRequiredVisualSlotsAreImplemented` verifies soft dawn gradient, illustrated bird silhouette cards, compass-like direction ring, neighborhood sound dots, and window view photo slots.
- REQ-EMPTY-001: Morning Chorus and Neighborhood Sound Map include first-run empty states and starter actions in en-US.
- REQ-ERROR-001: `ListenStoreAcceptanceTests.testValidationAndSimulatedSaveFailureExposeRecoverableErrors` covers invalid note length and save failure; `ConsumableAcceptanceTests` covers IAP failure.
- REQ-PRIVACY-001: `AppCopy.privacyBoundary` is visible in Morning Chorus; legal WebView links appear in Morning Chorus and Chorus Credit Shop.
- REQ-PREMIUM-001: `ConsumableAcceptanceTests` covers consumable catalog, credit spend, purchase failure, and transaction deduplication; Chorus Credit Shop exposes purchase/failure UI.
- Locale: Python acceptance audit confirms app source has no Han characters; core UI/paywall/privacy copy is en-US.

## Acceptance audit

Run `python3 Scripts/acceptance_audit.py` after changes. Checks include required screens (including Chorus Credit Shop and Badge Roost), consumable IAP catalog, credit costs, ATT, permission keys, and debug-only simulate controls.

## Xcode/Simulator runtime acceptance

Runtime acceptance is backed by `RuntimeEvidence/xcode_runtime_report.json` and `RuntimeEvidence/xcode_runtime_ui_test.log`.

Runtime flow marker: `XCODE_RUNTIME_FLOW PASS: launched simulator app and walked Morning Chorus -> Sound Shape Picker -> Window Listen Detail save -> Neighborhood Sound Map readback -> Chorus Credit Shop consumable failure`.

This evidence is Xcode/Simulator runtime proof, not SwiftPM-only or source-grep evidence.
