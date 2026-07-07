#!/usr/bin/env python3
from __future__ import annotations

import json
import re
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
APP = ROOT / "WindowBirdChorusCards"
TESTS = ROOT / "WindowBirdChorusCardsTests"
DOCS = ROOT / "Docs"
REQUIRED_SCREENS = [
    "Morning Chorus",
    "Sound Shape Picker",
    "Window Listen Detail",
    "Neighborhood Sound Map",
    "Chorus Credit Shop",
    "Badge Roost",
]
REQUIRED_MODELS = ["ListenCard", "BirdMoodCard", "SoundBadge"]
REQUIRED_VISUALS = [
    "softDawnGradient",
    "illustratedBirdSilhouetteCards",
    "compassLikeDirectionRing",
    "neighborhoodSoundDots",
]
REQUIRED_REQUIREMENTS = [
    "REQ-CRUD-001",
    "REQ-PERSIST-001",
    "REQ-VIS-001",
    "REQ-EMPTY-001",
    "REQ-ERROR-001",
    "REQ-PRIVACY-001",
    "REQ-PREMIUM-001",
]


def read_all(paths: list[Path]) -> str:
    chunks: list[str] = []
    for base in paths:
        for path in sorted(base.rglob("*")):
            if path.is_file() and path.suffix in {".swift", ".md"}:
                chunks.append(f"\n// FILE: {path.relative_to(ROOT)}\n")
                chunks.append(path.read_text(errors="ignore"))
    return "\n".join(chunks)


def run(cmd: list[str]) -> tuple[int, str]:
    proc = subprocess.run(cmd, cwd=ROOT, text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    return proc.returncode, proc.stdout


def main() -> int:
    source = read_all([APP, TESTS, DOCS]) + "\n" + (ROOT / "README.md").read_text(errors="ignore")
    app_source = read_all([APP])
    tests_source = read_all([TESTS])

    checks: dict[str, bool] = {}
    checks["xcodeproj_present"] = (ROOT / "WindowBirdChorusCards.xcodeproj" / "project.pbxproj").exists()
    checks["all_required_screens_present"] = all(screen in source for screen in REQUIRED_SCREENS)
    checks["all_required_models_present"] = all(model in app_source for model in REQUIRED_MODELS)
    checks["storekit2_boundary_present"] = "import StoreKit" in app_source and "Product.products" in app_source and "purchase()" in app_source
    checks["consumable_catalog_present"] = "IAPProductCatalog" in app_source and "473900" in app_source and "473926" in app_source
    checks["credit_save_cost_present"] = "saveCost = 10" in app_source and "initialBalance = 100" in app_source
    checks["consumable_transaction_dedup_present"] = "ProcessedTransactionStore" in app_source and "Transaction.unfinished" in app_source and ".consumable" in app_source
    checks["privacy_copy_present"] = "Listen cards, window view photos, and notes stay on this device." in source
    checks["att_request_present"] = "ATTrackingManager.requestTrackingAuthorization" in app_source
    checks["permission_descriptions_present"] = all(
        key in (ROOT / "WindowBirdChorusCards.xcodeproj" / "project.pbxproj").read_text(errors="ignore")
        for key in [
            "INFOPLIST_KEY_NSPhotoLibraryUsageDescription",
            "INFOPLIST_KEY_NSPhotoLibraryAddUsageDescription",
            "INFOPLIST_KEY_NSCameraUsageDescription",
            "INFOPLIST_KEY_NSMicrophoneUsageDescription",
            "INFOPLIST_KEY_NSUserTrackingUsageDescription",
        ]
    )
    checks["local_persistence_present"] = "JSONEncoder" in app_source and "JSONDecoder" in app_source and "applicationSupportDirectory" in app_source
    checks["crud_actions_present"] = all(term in app_source for term in ["Save Listen Card · 10 Credits", "Archive Card", "Delete Card", "Edit Latest Card"])
    checks["error_states_present"] = all(term in app_source for term in ["Simulate Save Failure", "Simulate IAP Failure", "note under 240 characters"])
    checks["shop_tab_present"] = 'Label("Shop"' in app_source and "ChorusCreditShopView" in app_source
    checks["listen_tab_present"] = 'Label("Listen"' in app_source and "AppTab.listen" in app_source
    checks["badges_tab_present"] = 'Label("Badges"' in app_source and "AppTab.badges" in app_source
    checks["visual_slots_present"] = all(slot in app_source for slot in REQUIRED_VISUALS)
    checks["acceptance_tests_present"] = all(req in tests_source or req in source for req in REQUIRED_REQUIREMENTS)
    checks["app_copy_has_no_han_characters"] = not bool(re.search(r"[\u4e00-\u9fff]", app_source))

    list_code, list_output = run(["xcodebuild", "-list", "-project", "WindowBirdChorusCards.xcodeproj"])
    checks["xcodebuild_list_succeeds"] = list_code == 0 and "Schemes:" in list_output and "WindowBirdChorusCards" in list_output

    report = {
        "app_dir": str(ROOT),
        "xcodeproj": str(ROOT / "WindowBirdChorusCards.xcodeproj"),
        "checks": checks,
        "passed": all(checks.values()),
    }
    print(json.dumps(report, indent=2, sort_keys=True))
    return 0 if report["passed"] else 1


if __name__ == "__main__":
    raise SystemExit(main())
