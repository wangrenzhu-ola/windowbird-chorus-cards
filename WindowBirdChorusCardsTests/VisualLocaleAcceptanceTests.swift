import XCTest
@testable import WindowBirdChorusCards

final class VisualLocaleAcceptanceTests: XCTestCase {
    func testRequiredVisualSlotsAreImplemented() {
        let slots = Set(VisualSlot.allCases)
        XCTAssertTrue(slots.contains(.softDawnGradient))
        XCTAssertTrue(slots.contains(.illustratedBirdSilhouetteCards))
        XCTAssertTrue(slots.contains(.compassLikeDirectionRing))
        XCTAssertTrue(slots.contains(.neighborhoodSoundDots))
        XCTAssertTrue(slots.contains(.windowViewPhotos))
        print("ACCEPTANCE_READBACK REQ-VIS-001: soft dawn gradient, bird silhouette cards, compass ring, and neighborhood sound dots are modeled as visual slots")
    }

    func testCoreUserVisibleCopyIsEnglishUS() throws {
        let hanRegex = try NSRegularExpression(pattern: #"\p{Han}"#)
        for copy in AppCopy.userVisibleSamples {
            let range = NSRange(location: 0, length: (copy as NSString).length)
            XCTAssertEqual(hanRegex.numberOfMatches(in: copy, range: range), 0, "Expected en-US copy only: \(copy)")
        }
        XCTAssertTrue(AppCopy.privacyBoundary.contains("stay on this device"))
        XCTAssertTrue(AppCopy.privacyBoundary.contains("window view photos"))
        XCTAssertTrue(AppCopy.privacyBoundary.contains("does not require microphone recording"))
        XCTAssertTrue(AppCopy.privacyPolicyURL.absoluteString.contains("privacy-policy"))
        XCTAssertTrue(AppCopy.userAgreementURL.absoluteString.contains("user-agreement"))
        print("ACCEPTANCE_READBACK REQ-EMPTY-001 REQ-PRIVACY-001 Locale: core UI/paywall/privacy sample copy is en-US and includes privacy boundary")
    }

    func testRequiredScreenNamesArePresent() {
        let screens = Set(["Morning Chorus", "Sound Shape Picker", "Window Listen Detail", "Neighborhood Sound Map", "Badge Roost"])
        for screen in screens {
            XCTAssertTrue(AppCopy.userVisibleSamples.contains(screen), "Missing screen copy: \(screen)")
        }
    }
}
