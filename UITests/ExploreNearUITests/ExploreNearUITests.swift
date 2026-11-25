import XCTest

final class ExploreNearUITests: XCTestCase {
    func testPrimaryIdentifiers() {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.buttons["explore.category.coffee"].exists)
        XCTAssertTrue(app.buttons["explore.category.restaurants"].exists)
        XCTAssertTrue(app.buttons["explore.category.parks"].exists)
        XCTAssertTrue(app.buttons["explore.category.museums"].exists)
        XCTAssertTrue(app.descendants(matching: .any)["explore.map"].exists)
        XCTAssertTrue(app.descendants(matching: .any)["explore.places"].exists)
        XCTAssertTrue(app.descendants(matching: .any)["explore.fallbackBanner"].exists)
        XCTAssertTrue(app.descendants(matching: .any)["explore.status"].exists)
    }
}
