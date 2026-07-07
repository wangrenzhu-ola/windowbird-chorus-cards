import XCTest

final class WindowBirdCoreFlowUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testMorningToPickerDetailMapAndConsumableShopRuntimeFlow() throws {
        let app = XCUIApplication()
        app.launchArguments = ["--windowbird-ui-test-store", "--reset-windowbird-store"]
        app.launch()

        XCTAssertTrue(app.staticTexts["WindowBird Chorus Cards"].waitForExistence(timeout: 8))
        XCTAssertTrue(app.staticTexts["Chorus Credits"].waitForExistence(timeout: 5))
        addScreenshot(named: "01-morning-chorus", app: app)

        tapFirstExistingButton(in: app, labels: ["Start a new window listen", "Start a Listen"])
        XCTAssertTrue(app.navigationBars["Sound Shape Picker"].waitForExistence(timeout: 5))
        tapFirstExistingButton(in: app, labels: ["Select Two-note Chirp", "Two-note Chirp"])
        addScreenshot(named: "02-sound-shape-picker", app: app)

        tapFirstExistingButton(in: app, labels: ["Continue to Window Listen Detail", "Continue to Listen Card"])
        XCTAssertTrue(app.navigationBars["Window Listen Detail"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Save this new card for 10 credits."].waitForExistence(timeout: 5))
        tapFirstExistingButton(in: app, labels: [
            "Save Listen Card for 10 credits",
            "Save Listen Card · 10 Credits"
        ])
        XCTAssertTrue(
            app.staticTexts.matching(
                NSPredicate(format: "label CONTAINS %@", "Saved. This card will reappear after reopening the app.")
            ).firstMatch.waitForExistence(timeout: 5)
        )
        addScreenshot(named: "03-window-listen-detail-saved", app: app)

        tapFirstExistingButton(in: app, labels: ["Open Neighborhood Sound Map"])
        XCTAssertTrue(app.navigationBars["Neighborhood Sound Map"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Two-note Chirp"].waitForExistence(timeout: 5))
        addScreenshot(named: "04-neighborhood-sound-map", app: app)

        app.tabBars.buttons["Shop"].tap()
        XCTAssertTrue(app.navigationBars["Chorus Credit Shop"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Recommended Packs"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Simulate IAP Failure"].waitForExistence(timeout: 5))
        tapFirstExistingButton(in: app, labels: ["Simulate IAP Failure"])
        XCTAssertTrue(app.staticTexts["Purchase could not be completed. Your saved listen cards and current credits are still available."].waitForExistence(timeout: 5))
        addScreenshot(named: "05-chorus-credit-shop-failure", app: app)

        print("XCODE_RUNTIME_FLOW PASS: launched simulator app and walked Morning Chorus -> Sound Shape Picker -> Window Listen Detail save -> Neighborhood Sound Map readback -> Chorus Credit Shop consumable failure")
    }

    private func tapFirstExistingButton(in app: XCUIApplication, labels: [String], file: StaticString = #filePath, line: UInt = #line) {
        for label in labels {
            let button = app.buttons[label]
            if button.waitForExistence(timeout: 3) {
                button.tap()
                return
            }
            let staticText = app.staticTexts[label]
            if staticText.waitForExistence(timeout: 1) {
                staticText.tap()
                return
            }
        }
        XCTFail("None of the expected controls existed: \(labels)", file: file, line: line)
    }

    private func addScreenshot(named name: String, app: XCUIApplication) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
