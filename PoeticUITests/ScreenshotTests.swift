//
//  ScreenshotTests.swift
//  PoeticUITests
//
//  App Store screenshot runner. Not shipped — drives the app on a simulator,
//  seeds favorites/quotes with famous poems, and attaches full-resolution
//  screenshots to the test result bundle for extraction with xcresulttool.
//
//  Appearance (dark/light) is controlled externally via `simctl ui appearance`
//  before each test invocation; the app follows the system theme by default.
//

// swiftlint:disable file_length
// App Store screenshot automation: one long, linear script per scene reads
// better than helpers split for the sake of length limits.
import XCTest

// swiftlint:disable:next type_body_length
final class ScreenshotTests: XCTestCase {

    private var app: XCUIApplication!

    private struct Seed {
        let query: String          // typed into search
        let fragment: String       // substring of the result cell label
        let quoteLine: String      // exact (trimmed) poem line to long-press
    }

    private static let seeds: [Seed] = [
        Seed(query: "The Tyger",
             fragment: "The Tyger",
             quoteLine: "Tyger, tyger, burning bright"),
        Seed(query: "the thing with feathers",
             fragment: "feathers",
             quoteLine: "\"Hope\" is the thing with feathers --"),
        Seed(query: "I Wandered Lonely",
             fragment: "I Wandered Lonely",
             quoteLine: "I wandered lonely as a cloud"),
        Seed(query: "Ozymandias",
             fragment: "Ozymandias",
             quoteLine: "Look on my works, ye Mighty, and despair!'"),
        Seed(query: "She Walks in Beauty",
             fragment: "She Walks in Beauty",
             quoteLine: "She walks in Beauty, like the night"),
        Seed(query: "Sonnet 18",
             fragment: "Shall I compare thee",
             quoteLine: "Shall I compare thee to a summer's day?")
    ]

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        // NSArgumentDomain overrides UserDefaults.standard, so the "New in
        // Poetic" sheet never fires regardless of stored state.
        app.launchArguments += [
            "-hasSeenWidgetAnnouncement", "YES",
            // Must match ContentView.currentAnnouncement, or the "New in
            // Poetic" sheet covers the screenshots.
            "-lastSeenAnnouncementVersion", "3.1"
        ]
    }

    // MARK: - Tests

    func testA_seedAndCaptureDark() {
        app.launch()
        dismissAnnouncementIfPresent()
        waitForHome()
        snap("home-initial")

        for seed in Self.seeds {
            search(seed.query)
            openResult(containing: seed.fragment)
            XCTAssertTrue(
                app.staticTexts[seed.quoteLine].waitForExistence(timeout: 10),
                "poem body missing for \(seed.fragment)"
            )
            tapFavorite()
            saveQuote(line: seed.quoteLine)
            goBack()
        }
        cancelSearchIfActive()

        openTab("Favorites")
        settle()
        snap("favorites-dark")

        openTab("Quotes")
        settle()
        snap("quotes-dark")

        openTab("Explore")
        settle()
        snap("explore-dark")

        // Author page for today's poet: slot 1 of Featured Authors is badged.
        let poetCard = app.buttons
            .matching(NSPredicate(format: "label CONTAINS[c] 'Poet of the Day'")).firstMatch
        if poetCard.waitForExistence(timeout: 5) {
            poetCard.tap()
            settle(2)
            snap("author-dark")
            goBack()
        } else {
            dump("explore-poet-card-missing")
        }

        openTab("Home")
        settle()
        snap("home-dark")

        openDetailFromRecents(containing: "Sonnet 18")
        settle()
        snap("detail-dark")
    }

    func testB_captureLight() {
        app.launch()
        dismissAnnouncementIfPresent()
        waitForHome()
        settle()
        snap("home-light")

        openTab("Favorites")
        settle()
        snap("favorites-light")

        openTab("Home")
        settle()
        openDetailFromRecents(containing: "Sonnet 18")
        settle()
        snap("detail-light")
    }

    // swiftlint:disable function_body_length
    /// Best-effort springboard automation: add the Poem of the Day widget to
    /// the home screen and screenshot it. Dump-heavy so failures are debuggable.
    func testC_widgetBoard() {
        // Run the app once so the widget payload (daily.json) is fresh.
        app.launch()
        dismissAnnouncementIfPresent()
        waitForHome()

        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        XCUIDevice.shared.press(.home)
        sleep(1)

        // Remove any Poetic widget left over from a previous run.
        // Widgets are Icon elements labeled by app name with value "Widget".
        var attempts = 0
        while attempts < 3 {
            let widget = springboard.icons
                .matching(NSPredicate(format: "label == 'Poetic' AND value == 'Widget'")).firstMatch
            guard widget.exists else { break }
            widget.press(forDuration: 1.5)
            let remove = springboard.buttons["Remove Widget"]
            if remove.waitForExistence(timeout: 3) {
                remove.tap()
                let confirm = springboard.alerts.buttons["Remove"]
                if confirm.waitForExistence(timeout: 3) {
                    confirm.tap()
                }
                sleep(1)
            } else {
                dump("remove-widget-menu-missing", of: springboard)
                break
            }
            attempts += 1
        }

        // Enter jiggle mode from a long-press on empty wallpaper.
        springboard.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.75))
            .press(forDuration: 3.0)
        dump("springboard-after-longpress", of: springboard)

        let edit = springboard.buttons["Edit"]
        if edit.waitForExistence(timeout: 4) {
            edit.tap()
            let addWidget = springboard.buttons["Add Widget"]
            XCTAssertTrue(addWidget.waitForExistence(timeout: 4), "Add Widget menu item missing")
            addWidget.tap()
        } else {
            // Older flow: "+" button appears directly in jiggle mode.
            let plus = springboard.buttons["Add widget"]
            XCTAssertTrue(plus.waitForExistence(timeout: 4), "no Edit or Add widget button")
            plus.tap()
        }

        // Widget gallery: search for the app.
        let field = springboard.searchFields.firstMatch
        XCTAssertTrue(field.waitForExistence(timeout: 5), "widget gallery search missing")
        field.tap()
        field.typeText("Poetic")
        sleep(1)
        dump("springboard-gallery-search", of: springboard)

        let result = springboard.cells
            .matching(NSPredicate(format: "label CONTAINS[c] 'Poetic'")).firstMatch
        if result.waitForExistence(timeout: 4) {
            sleep(1) // let the results list finish animating
            if result.isHittable {
                result.tap()
            } else {
                result.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
            }
        } else {
            let alt = springboard.staticTexts
                .matching(NSPredicate(format: "label CONTAINS[c] 'Poetic'")).firstMatch
            XCTAssertTrue(alt.waitForExistence(timeout: 4), "Poetic not in widget gallery")
            alt.tap()
        }
        sleep(1)
        dump("springboard-gallery-detail", of: springboard)

        // The size carousel starts on systemSmall; two swipes reach systemLarge,
        // which is the only size that renders the poem excerpt block.
        springboard.swipeLeft()
        sleep(1)
        springboard.swipeLeft()
        sleep(1)

        let add = springboard.buttons[" Add Widget"].exists
            ? springboard.buttons[" Add Widget"]
            : springboard.buttons["Add Widget"]
        XCTAssertTrue(add.waitForExistence(timeout: 4), "Add Widget confirm missing")
        add.tap()
        sleep(1)

        // Leave jiggle mode and let the widget render its timeline.
        XCUIDevice.shared.press(.home)
        sleep(3)
        snap("widget-home")
    }
    // swiftlint:enable function_body_length

    /// App Preview choreography — no screenshots, just a paced walk through
    /// the app while `simctl io recordVideo` captures from the host.
    func testD_videoChoreography() {
        app.launch()
        dismissAnnouncementIfPresent()
        waitForHome()
        sleep(2)

        // Home: drift down to the Recent list, open Sonnet 18.
        app.swipeUp()
        sleep(2)
        openDetailFromRecents(containing: "Sonnet 18")
        sleep(3)

        // Save a quote on camera: long-press a famous line.
        let line = app.staticTexts["Rough winds do shake the darling buds of May,"]
        if line.waitForExistence(timeout: 5) {
            line.press(forDuration: 1.5)
            sleep(2)
            let save = app.buttons["Highlight and Save"]
            if save.waitForExistence(timeout: 3) {
                save.tap()
            }
            sleep(2)
        }
        goBack()

        openTab("Quotes")
        sleep(3)
        openTab("Favorites")
        sleep(3)
        openTab("Explore")
        sleep(3)
        openTab("Home")
        sleep(3)
    }

    // MARK: - Helpers

    private func snap(_ name: String) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    private func dump(_ name: String, of element: XCUIElement? = nil) {
        let attachment = XCTAttachment(string: (element ?? app).debugDescription)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    private func settle(_ seconds: UInt32 = 1) {
        sleep(seconds)
    }

    private func waitForHome() {
        XCTAssertTrue(
            app.staticTexts["Poet of the Day"].waitForExistence(timeout: 30),
            "home never loaded"
        )
        sleep(2) // recommended cards decode from the catalog async
    }

    private func dismissAnnouncementIfPresent() {
        let later = app.buttons["Maybe later"]
        if later.waitForExistence(timeout: 3) {
            later.tap()
            sleep(1)
        }
    }

    private func openTab(_ name: String) {
        let tab = app.tabBars.buttons[name]
        if tab.waitForExistence(timeout: 5) {
            tab.tap()
            return
        }
        let alt = app.buttons[name]
        XCTAssertTrue(alt.waitForExistence(timeout: 5), "tab \(name) not found")
        alt.tap()
    }

    /// iOS 26 search UI: a "Close" button sits beside the active field
    /// (older versions used "Cancel").
    private func cancelSearchIfActive() {
        for label in ["Cancel", "Close"] {
            let button = app.navigationBars.buttons[label]
            if button.exists && button.isHittable {
                button.tap()
                sleep(1)
                return
            }
        }
    }

    private func search(_ query: String) {
        openTab("Explore")
        let field = app.searchFields.firstMatch
        XCTAssertTrue(field.waitForExistence(timeout: 5), "search field missing")
        field.tap()
        let clear = app.buttons["Clear text"]
        if clear.exists && clear.isHittable {
            clear.tap()
        }
        field.typeText(query)
        sleep(1)
    }

    private func openResult(containing fragment: String) {
        let predicate = NSPredicate(
            format: "label CONTAINS[c] %@ AND NOT label BEGINSWITH 'No Results'", fragment
        )
        let button = app.buttons.matching(predicate).firstMatch
        if button.waitForExistence(timeout: 8) {
            button.tap()
            return
        }
        let text = app.staticTexts.matching(predicate).firstMatch
        if text.waitForExistence(timeout: 4) {
            text.tap()
            return
        }
        dump("no-result")
        XCTFail("no search result containing \(fragment)")
    }

    private func tapFavorite() {
        let bar = app.navigationBars.firstMatch
        for id in ["star", "Star", "Favorite", "Add to Favorites", "star.fill"] {
            let candidate = bar.buttons[id]
            if candidate.exists && candidate.isHittable {
                candidate.tap()
                return
            }
        }
        if bar.exists && bar.buttons.count >= 2 {
            bar.buttons.element(boundBy: 1).tap()
            return
        }
        dump("favorite-button-missing")
        XCTFail("favorite button not found")
    }

    private func saveQuote(line: String) {
        let text = app.staticTexts[line].firstMatch
        XCTAssertTrue(text.waitForExistence(timeout: 8), "line not found: \(line)")
        var swipes = 0
        while !text.isHittable && swipes < 6 {
            app.swipeUp()
            swipes += 1
        }
        text.press(forDuration: 1.5)
        let save = app.buttons["Highlight and Save"]
        if save.waitForExistence(timeout: 4) {
            save.tap()
        } else {
            dump("context-menu-missing")
            XCTFail("context menu didn't appear for: \(line)")
        }
        sleep(1)
    }

    private func goBack() {
        let back = app.navigationBars.buttons.element(boundBy: 0)
        if back.exists && back.isHittable {
            back.tap()
        } else if app.buttons["Back"].exists {
            app.buttons["Back"].tap()
        } else {
            dump("back-button-missing")
            XCTFail("no back button")
        }
        sleep(1)
    }

    private func openDetailFromRecents(containing fragment: String) {
        let predicate = NSPredicate(format: "label CONTAINS[c] %@", fragment)
        let cell = app.buttons.matching(predicate).firstMatch
        var swipes = 0
        while !(cell.exists && cell.isHittable) && swipes < 6 {
            app.swipeUp()
            swipes += 1
        }
        XCTAssertTrue(cell.exists, "recent cell \(fragment) not found")
        cell.tap()
        sleep(1)
        // Scroll back so the poem starts from the top for the screenshot.
        app.swipeDown()
    }
}
